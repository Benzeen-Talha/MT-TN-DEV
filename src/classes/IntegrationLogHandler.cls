/**
* @description: Trigger Handler for Integration Log Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 27/6/16    T.Sotiraki       Created Class/Re-engineered trigger   
*/
public with sharing class IntegrationLogHandler{

    

    public static void onAfterUpdate(List<Integration_Log__c> logs){
        
        List<Integration_Log__c> campIntLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> campMemberIntLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> accIntLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> contactLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> oppLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> aaaLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> relationshipLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> webformLinkLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> ctaLinkLogs = new List<Integration_Log__c>();

        for(Integration_Log__c iL : logs){
                
                if(il.Request_Type__c == 'Campaign Insert' && iL.Campaign__c != null){
                    campIntLogs.add(iL);
                }   

                if(il.Request_Type__c == 'Opportunity Insert' && iL.Opportunity__c != null){
                    oppLogs.add(iL);
                }    

                /* MB: Add Accounts to be handled */
                if(il.Request_Type__c == 'Account Insert' && iL.Account__c != null){
                    
                    accIntLogs.add(iL);
                    
                }   
                if(il.Request_Type__c == 'Contact Insert' && il.Contact__c != null){
                    contactLogs.add(il);
                }       

                if(il.Request_Type__c == 'AAA Insert' && il.AAA_Number__c != null){
                    aaaLogs.add(il);
                }  

                if(il.Request_Type__c == 'Relationship Insert' && il.Relationship__c != null){
                    relationshipLogs.add(il);
                } 
                if(il.Request_Type__c == 'Opportunity Create Web Form Link' && il.Opportunity__c != null){
                    webformLinkLogs.add(il);
                }      
                if(il.Request_Type__c == 'Opportunity Click To Accept Link' &&  il.Opportunity__c != null){
                    ctaLinkLogs.add(il);
                }
                
            
            }
            
            if(campIntLogs.size() > 0){
            
                IntegrationLogUtil.updateCampaignId(campIntLogs); 
            }
            
            if(accIntLogs.size() > 0){
            
                IntegrationLogUtil.updateAccountEntityId(accIntLogs); 
            }

            if(contactLogs.size() > 0){
                IntegrationLogUtil.updateContactId(contactLogs);
            }

            if(oppLogs.size() > 0){
                IntegrationLogUtil.updateOpportunitySaleId(oppLogs);
            }

            if(aaaLogs.size() > 0){
                IntegrationLogUtil.updateAAANumbers(aaaLogs);
            }

            if(relationshipLogs.size() > 0){
                IntegrationLogUtil.updateRelationshipId(relationshipLogs);
            }

            if(webformLinkLogs.size() > 0){
                IntegrationLogUtil.updateOpportunityWebFormLink(webformLinkLogs);
            }

            if(ctaLinkLogs.size() > 0){
                IntegrationLogUtil.updateOpportunityCTALink(ctaLinkLogs);
            }
        
        
    }


 
    
    
   

    

    
    
   
    

}