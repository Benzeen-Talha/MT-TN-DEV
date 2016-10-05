/**
* @Name:  RelationshipTriggerHandler
* @description: Trigger handler class for Relationship Object trigger
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 24/02/16    T.Sotiraki      Created Class   
*/
public with sharing class RelationshipTriggerHandler {

    // RelationshipStatusController.CheckTransition(a, oldMap.get(a.Id).Account_Status__c, a.Account_Status__c);  
	/*public static void onBeforeUpdate(List<Relationship__c> relationships, Map<Id, Relationship__c> oldMap){
        
        for(Relationship__c r : relationships){
             try{
                //RelationshipStatusController.CheckTransition(r, oldMap.get(r.Id).Relationship_Status__c, r.Relationship_Status__c, false);
              } catch(exception ex){
                System.debug('Error onAfterInsert: ' + ex.getMessage());
              }
        }
    }*/
    
    public static void onAfterUpdate(List<Relationship__c> oldrelationships, List<Relationship__c> newRelationships){
        try{
            if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
            
                List<Relationship__c> onHoldRelationships = new List<Relationship__c>();

            ////////////////////////////////////
            ///Update to most positive status
            /////////////////////////////////////
            
          //  RelationshipUtil.updateMostPositiveStatus(newRelationships);

            //////////////////////////////////////////////////
            ///Update confirmed relationships on Opportunity
            //////////////////////////////////////////////////
            
            //RelationshipUtil.updateOpportunityConfirmedRelationships(newRelationships);


            for(Relationship__c r : oldrelationships){
                for(Relationship__c rl : newRelationships){
                    if(r.Id == rl.Id){
                        ///////////////////////////////////
                        ////Check for On Hold Status update
                        ///////////////////////////////////
                        if(rl.Relationship_Status__c == 'On Hold' && r.Relationship_Status__c != 'On Hold'){
                            //RelationshipUtil.createOBIJSONMessageRequest(rl, 'OnHoldPost');
                            System.debug('About to go in!');
                            onHoldRelationships.add(rl);
                        }

                        /////////////////////////////////////////////////
                        ////No Status update but remaining fields update
                        /////////////////////////////////////////////////
                        if(rl.Relationship_Status__c == r.Relationship_Status__c && 
                            (
                                rl.Vendor_Code__c != r.Vendor_Code__c ||
                                rl.PO_Required__c != r.PO_Required__c ||
                                rl.PO_Validation__c != r.PO_Validation__c ||
                                rl.Attachment_Settings__c != r.Attachment_Settings__c
                            )
                            ){
                            //RelationshipUtil.createOBIJSONMessageRequest(rl, 'RelationshipPut');
                        }
                        /////////////////////////////////
                        ////Check for RTB Status update
                        /////////////////////////////////
                        if(rl.Relationship_Status__c == 'Refer To Buyer' && r.Relationship_Status__c != 'Refer To Buyer'){
                            //RelationshipUtil.createOBIJSONMessageRequest(rl, 'RTBPost');
                        }
                        

                        ///////////////////////////////////
                        ////Check for Off Hold Status update
                        ///////////////////////////////////
                        if(rl.Relationship_Status__c == 'In Sales' && r.Relationship_Status__c == 'On Hold'){
                            //RelationshipUtil.createOBIJSONMessageRequest(rl, 'OffHoldPost');
                        }

                        /////////////////////////////////////////
                        ////Check for No Potential Status update
                        /////////////////////////////////////////
                        if(rl.Relationship_Status__c == 'Non Potential' && r.Relationship_Status__c != 'Non Potential'){
                            //RelationshipUtil.createOBIJSONMessageRequest(rl, 'NoPotentialPost');
                        }
                    }
                }
            }

            if(onHoldRelationships.size() > 0){
                System.debug('About to go in!');
                RelationshipUtil.createOBIJSONBulkRelaionshipRequest(onHoldRelationships, 'OnHoldPost');
            }
            
        }
        }
        catch(Exception ex){
            System.debug('Error onAfterUpdate: ' + ex.getMessage());
        }
    }

    public static void onAfterInsert(List<Relationship__c> newRelationships){
        try{
            ////////////////////////////////////
            ///Update to most positive status
            /////////////////////////////////////
            
            RelationshipUtil.updateMostPositiveStatus(newRelationships);
            
            //////////////////////////////////////////////////
            ///Update confirmed relationships on Opportunity
            //////////////////////////////////////////////////
            
            //RelationshipUtil.updateOpportunityConfirmedRelationships(newRelationships);


            if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
                for(Relationship__c r : newRelationships){
                    RelationshipUtil.createOBIJSONMessageRequest(r, 'CampaignRelationshipPost');
                    RelationshipUtil.createOBIJSONMessageRequest(r, 'RelationshipPost');
                }
            
            }
            
            
        }
        catch(Exception ex){
            System.debug('Error onAfterInsert: ' + ex.getMessage());
        }
    }

}