public with sharing class OpportunityHandler{
    
    /**
     * [onBeforeUpdate description]
     * @param opps      [description]
     * @param oldOppMap [description]
     */
     
    public static void onBeforeInsert(List<Opportunity> opps){
        if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
            //check the opportunity Account details and set the initial owner.
            System.debug('Before insert Opportunity');
           OpportunityUtil.setOpportunityOwner(opps);
        }
    }  
     
     
    public static void onBeforeUpdate(List<Opportunity> opps, Map<Id, Opportunity> oldOppMap){
        if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
            try{
                System.debug('Before update Opportunity');
                List<Opportunity> updatedStageOpps = new List <Opportunity>();
                List<Opportunity> pendingEngagedOpps = new List<Opportunity>();
                List<Opportunity> postEngagedOpps = new List<Opportunity>();
                List<Opportunity> productCheckOpps = new List<Opportunity>();
                Set<Opportunity> oppsToUpdateToWebFormLinkSent = new Set<Opportunity>();
                List<Opportunity> oppsToCheckConfirmedRelationships = new List<Opportunity>();

                
                for(Opportunity o : opps){

                    if(o.Campaign_Type__c == 'Web Form' && oldOppMap.get(o.Id).StageName == 'Web Form Registration Link Sent' && o.StageName == 'Web Form Registration Complete'){
                                oppsToCheckConfirmedRelationships.add(o);

                    }
                    
                    if(o.StageName == 'Release To Implementation' && oldOppMap.get(o.Id).StageName != 'Release To Implementation'){
                            updatedStageOpps.add(o);
                    }
                        
                    if(o.Campaign_Type__c == 'Web Form' && oldOppMap.get(o.Id).Campaign_Type__c == 'Integrated Solution'){
                            oppsToUpdateToWebFormLinkSent.add(o);
                    }

                    
                        
                    

                    Opportunity oldOpportunity = oldOppMap.get(o.ID);
                
                    if (o.StageName != oldOpportunity.StageName && o.StageName == 'Add contact details') {
                
                        updatedStageOpps.add(o);
                   
                    }

                    if(o.StageName == 'Engaged' && oldOpportunity.StageName == 'First Call'){
                        pendingEngagedOpps.add(o);
                    }


                    if((o.StageName == 'Add contact details' || o.StageName == '' ) && oldOpportunity.StageName == 'Engaged'){
                        postEngagedOpps.add(o);
                    }

                    if (o.StageName != oldOpportunity.StageName && o.StageName == 'Terms Accepted') {
                
                        productCheckOpps.add(o);
                   
                    }

                    


                
                }

                if(oppsToCheckConfirmedRelationships.size() > 0){
                    OpportunityUtil.updateOpportunityConfirmedRelationships(oppsToCheckConfirmedRelationships);
                }

                if(updatedStageOpps.size() > 0){
                    OpportunityUtil.StageChangeHandler(updatedStageOpps);
                }

                if(productCheckOpps.size() > 0){
                    OpportunityUtil.opportunityProductCheck(productCheckOpps);
                }
                if(pendingEngagedOpps.size() > 0){
                    OpportunityUtil.hasFirstCallTaskBeenCompleted(pendingEngagedOpps);
                }
                if(oppsToUpdateToWebFormLinkSent.size() > 0){
                    OpportunityUtil.updateOpportunityStage('Web Form Registration Link Sent', oppsToUpdateToWebFormLinkSent);
                }

                OpportunityUtil.scheduleFirstCallStageStart(opps);

                OpportunityUtil.checkServiceType(opps);
                
                //Stage Change timestamp code
                Map <Opportunity, String> stageChangeOppsMap = new Map <Opportunity, String>();
                
                for(Opportunity opp : opps){
                	
                	if(opp.stageName != oldOppMap.get(opp.Id).StageName){
                		
                		stageChangeOppsMap.put(opp, oldOppMap.get(opp.Id).StageName);
                		
                	}
                	
                }
                
                OpportunityUtil.stageChangeTimestamp(stageChangeOppsMap);
               
            }
            catch(Exception ex){
                System.debug('Error onBeforeUpdate: ' + ex.getMessage());
            }
        }
    }

    /**
     * [onAfterUpdate description]
     * @param opps      [description]
     * @param oldOppMap [description]
     */
    public static void onAfterUpdate(List<Opportunity> opps, Map<Id, Opportunity> oldOppMap){
        if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
            try{
                System.debug('After update Opportunity');
                List<Opportunity> oppsServiceChange = new List<Opportunity>();
                for(Opportunity o : opps){
                
                        ////////////////////////////////////////////////
                        ///Common Callouts [WF & IS]
                        ////////////////////////////////////////////////
                        
                        if(oldOppMap.get(o.Id).StageName == 'Schedule First Call' && o.StageName == 'Schedule First Call' && o.OBI_Sale_Id__c != null){
                            System.debug('Schedule First Call');
                            OpportunityUtil.completeTask(o.Id, 'Schedule First Call');
                           
                        }
                        /*if(oldOppMap.get(o.Id).StageName == 'Schedule First Call' && o.StageName == 'First Call' && o.OBI_Sale_Id__c != null){
                            OpportunityUtil.completeTask(o.Id, 'First Call');
                        }*/

                        if(oldOppMap.get(o.Id).StageName == 'First Call' && o.StageName == 'Engaged' && o.OBI_Sale_Id__c != null){
                            OpportunityUtil.completeTask(o.Id, 'Engaged');
                        }




                        /////////////////////////////////////////////////
                        ///IS Callouts
                        /////////////////////////////////////////////////
                        
                        if(oldOppMap.get(o.Id).StageName == 'Engaged' && o.StageName == 'Add Contact Details' && o.OBI_Sale_Id__c != null){
                            OpportunityUtil.completeTask(o.Id, 'Add Contact Details');
                            //OpportunityUtil.UpdatePrimaryContact(o.Id);
                        }

                        if(oldOppMap.get(o.Id).StageName == 'Add Contact Details' && o.StageName == 'Select Tariff' && o.OBI_Sale_Id__c != null){
                            OpportunityUtil.completeTask(o.Id, 'Select Tariff');
                           // OpportunityUtil.UpdatePrimaryContact(o.Id);

                        }

                        if(oldOppMap.get(o.Id).StageName == 'Select Tariff' && o.StageName == 'Send IS Registration Link'){
                            OpportunityUtil.completeTask(o.Id, 'Send Portal Registration Link');
                            OpportunityUtil.createOBITariffUpdate(o.Id, 'TariffPost');
                            OpportunityUtil.createCTALinkMessageRequest(o.Id, 'CTALinkPost');
                           // OpportunityUtil.UpdatePrimaryContact(o.Id);
                            
                        }

                        if(oldOppMap.get(o.Id).StageName == 'Terms Accepted' && o.StageName == 'Send Confirmation Email'){
                            OpportunityUtil.completeTask(o.Id, 'Send Confirmation Email');
                           // OpportunityUtil.UpdatePrimaryContact(o.Id);
                        }                        

                        if(oldOppMap.get(o.Id).StageName == 'Send Confirmation Email' && o.StageName == 'Release To Implementation'){
                            OpportunityUtil.completeTask(o.Id, 'Release To Implementation');
                           OpportunityUtil.createOBIReleaseToImplementationMessageRequest(o.Id, 'ReleaseToImplementationPost');
                        }
                    
                        if(o.Campaign_Type__c == 'Web Form' && oldOppMap.get(o.Id).Campaign_Type__c == 'Integrated Solution'){
                            OpportunityUtil.createWebFormLinkMessageRequest(o.Id, 'CreateWebFormLinkPost'); 

                        }

                        if(o.Campaign_Type__c == 'Integrated Solution' && 
                                ((o.Payment_Methods_OBI_Value__c != oldOppMap.get(o.Id).Payment_Methods_OBI_Value__c) ||  
                                 (o.Payment_Terms_OBI_Value__c != oldOppMap.get(o.Id).Payment_Terms_OBI_Value__c)) ){
                                OpportunityUtil.UpdateCommercialInfo(o.Id);
                        }

                

                if(o.Campaign_Type__c != oldOppMap.get(o.Id).Campaign_Type__c){
                
                    oppsServiceChange.add(o);
                    
                }
            }


            if(oppsServiceChange.size() >0){
                priceBookAssignmentHandler.priceBookAssignmentSupplierSalesHandler(oppsServiceChange);
            }
            

            //EventTriggerHelper.ScheduleFirstCall_Opportunity_StageStartUpdate(opps,oldOppMap); //MT Updated 11-Aug-2016
            
            /////////////////////////////////////////////////////////
            ///First Call Notification - Moved from Process Builder
            //////////////////////////////////////////////////////////
            OpportunityUtil.createSalesRepOverdueScheduleFirstCallTasks(opps);

            }
            catch(Exception ex){
                System.debug('Error onAfterUpdate: ' + ex.getMessage());
            }
        }
    }

    /**
     * [onAfterInsert description]
     * @param opps [description]
     */
    public static void onAfterInsert(List<Opportunity> opps){
        try{
            if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
                System.debug('After insert Opportunity');
             //EventTriggerHelper.ScheduleFirstCall_Opportunity_StageStartInsert(opps); //MT Updated 11-Aug-2016
                priceBookAssignmentHandler.priceBookAssignmentSupplierSalesHandler(opps);

                for(Opportunity o : opps){
                    OpportunityUtil.createOBISaleMessageRequest(o.Id, 'OpportunityPost');
                }
            }
                
               
            
        }
        catch(Exception ex){
            System.debug('Error onAfterInsert: ' + ex.getMessage());
        }
    }
    
    
    
}