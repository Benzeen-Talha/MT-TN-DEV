/**
* @Name:  IntegrationLogUtil
* @description: Utilities class for Relationship Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 31/08/16    T.Sotiraki      Created class   
*/
public with sharing class IntegrationLogUtil {
	
	public static void updateAAANumbers(List<Integration_log__c> logs){

        Map<Id, AAA_Number__c> intLogAccountMap = new Map<Id, AAA_Number__c>();
        List<ID> aaaIds = new List<Id>();
        List<AAA_Number__c> aaaNumbersToUpdate = new list<AAA_Number__c>();

        for(Integration_log__c i : logs){
            aaaIds.add(i.AAA_Number__c);            
        }
        
        List<AAA_Number__c> numbers = [Select id, Name 
                                       FROM AAA_Number__c 
                                       WHERE id IN :aaaIds];
        
        for(AAA_Number__c a : numbers){
            intLogAccountMap.put(a.ID, a);
        }
        
        for(Integration_log__c i : logs){
            
            AAA_Number__c a = intLogAccountMap.get(i.AAA_Number__c);
            a.Name = i.New_AAANumber__c;
            a.OBI_Account_ID__c = i.New_OBI_Object_ID__c;
           
            aaaNumbersToUpdate.add(a);         
        }
        
        Update aaaNumbersToUpdate;
    
    
    }

    public static void updateAccountEntityId(List<Integration_log__c> logs){

        Map<Id, Account> intLogAccountMap = new Map<Id, Account>();
        List<ID> AccountIds = new List<ID>();
        List<Account> AccountsToUpload = new List<Account>();

        for(Integration_log__c intLog : logs){
            AccountIds.add(intLog.Account__c);            
        }
        
        list<Account> Accounts = [Select id, Name, Obi_Object_ID__c FROM Account WHERE id IN :AccountIds];
        
        for(Account a : Accounts){
            intLogAccountMap.put(a.ID, a);
        }
        
        for(Integration_log__c intLog : logs)
        {
            
            Account a = intLogAccountMap.get(intLog.Account__c);
            a.Obi_Object_ID__c = intLog.New_Obi_Object_ID__c;
            a.OBI_Entity_ID__c = intLog.New_Obi_Object_ID__c;
            
            AccountsToUpload.Add(a);         
        }
        
        Update AccountsToUpload;
    
    
    
    }

    public static void updateOpportunitySaleId(List<Integration_log__c> logs){

        	Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Set<Id> oppIds = new Set<ID>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();

            for(Integration_log__c il : logs){
                oppIds.add(il.Opportunity__c);            
            }
            
            List<Opportunity> opportunities = [Select id, OBI_Sale_Id__c 
                                                FROM Opportunity 
                                                WHERE id IN :oppIds];
            
            for(Opportunity o : opportunities){
                if(o.OBI_Sale_Id__c == null){
                    oppMap.put(o.ID, o);
                }
                
            }
            
            for(Integration_log__c il : logs){
                
                Opportunity c = oppMap.get(il.Opportunity__c);
                
                if(il.New_OBI_Object_ID__c != null){
                   // c.Web_Form_Link__c = il.New_OBI_Object_ID__c;
                    c.OBI_Sale_Id__c = TungstenUtil.GetIntegerValue(Integer.valueOf(il.New_OBI_Object_ID__c));
                }
                
                
                oppsToUpdate.add(c);         
            }
            
            if(oppsToUpdate.size() > 0)
            {Update oppsToUpdate;}
    
    
    }

    public static void updateOpportunityCTALink(List<Integration_log__c> logs){

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Set<Id> contactIds = new Set<ID>();
        List<Contact> contactsToUpdate = new List<Contact>();

            for(Integration_log__c il : logs){
                contactIds.add(il.Contact__c);            
            }
            
            List<Contact> contacts = [Select id, OBI_CTA_Link__c, OBI_Contact_ID__c FROM Contact WHERE id IN :contactIds];
            
            for(Contact c : contacts){
                contactMap.put(c.ID, c);
            }
            
            for(Integration_log__c il : logs){
                
                Contact c = contactMap.get(il.Contact__c);
                c.OBI_CTA_Link__c = TungstenUtil.GetStringValue(il.PortalCTALink__c);
                
                contactsToUpdate.add(c);         
            }
            if(contactsToupdate.size() > 0)
            {Update contactsToUpdate;}
    
    
    }

    public static void updateOpportunityWebFormLink(List<Integration_log__c> logs){

            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();

            for(Integration_log__c il : logs){
                oppIds.add(il.Opportunity__c);            
            }
            system.debug(logs);
            List<Opportunity> opportunities = [Select Id, Web_Form_Link__c
                                                FROM Opportunity 
                                                WHERE Id IN :oppIds];
            
            for(Opportunity o : opportunities){
                if(o.Web_Form_Link__c == null){
                     oppMap.put(o.Id, o);
                }
               
            }
            
            for(Integration_log__c il : logs){
                
                Opportunity c = oppMap.get(il.Opportunity__c);
                
                if(il.New_OBI_Object_ID__c != null){
                    c.Web_Form_Link__c = TungstenUtil.GetStringValue(il.New_OBI_Object_ID__c);
                }
                
                
                oppsToUpdate.add(c);         
            }
            
            if(oppsToUpdate.size() > 0){
                update oppsToUpdate;
            }
            
    
    
    }

    public static void updateCampaignId(List<Integration_log__c> logs){

        Map<Id, Campaign> intLogCampaignMap = new Map<Id, Campaign>();
        List<ID> CampaignIds = new List<ID>();
        List<Campaign> CampaignsToUpload = new List<Campaign>();

        for(Integration_log__c intLog : logs){
            CampaignIds.add(intLog.Campaign__c);            
        }
        
        List<Campaign> campaigns = [Select id, Name, Obi_Object_ID__c 
        							FROM Campaign 
        							WHERE id IN :CampaignIds];
        
        for(Campaign c : campaigns){
            intLogCampaignMap.put(c.ID, c);
        }
        
        for(Integration_log__c intLog : logs){
            
            Campaign c = intLogCampaignMap.get(intLog.Campaign__c);
            c.Obi_Object_ID__c = intLog.New_Obi_Object_ID__c;
            
            CampaignsToUpload.Add(c);         
        }
        
        Update CampaignsToUpload;
    
    }

    public static void updateContactId(List<Integration_log__c> logs){

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Set<Id> contactIds = new Set<ID>();
        List<Contact> contactsToUpdate = new List<Contact>();

            for(Integration_log__c il : logs){
                contactIds.add(il.Contact__c);            
            }
            
            List<Contact> contacts = [Select id, OBI_CTA_Link__c, OBI_Contact_ID__c FROM Contact WHERE id IN :contactIds];
            
            for(Contact c : contacts){
                contactMap.put(c.ID, c);
            }
            
            for(Integration_log__c il : logs){
                
                Contact c = contactMap.get(il.Contact__c);
                //c.OBI_CTA_Link__c = il.PortalCTALink__c;
                c.OBI_Contact_ID__c = il.New_OBI_Object_ID__c;
                
                contactsToUpdate.add(c);         
            }
            
            Update contactsToUpdate;
    
    }


    public static void updateRelationshipId(List<Integration_log__c> logs){

        Map<Id, Relationship__c> relationshipMap = new Map<Id, Relationship__c>();
        Set<Id> relationshipIds = new Set<ID>();
        List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
        Map<Id, String> relationshipIdToOBIRelationshipId = new Map<Id,String>();

        for(Integration_log__c il : logs){
            relationshipIds.add(il.Relationship__c); 

            if(il.New_OBI_Object_ID__c != null){
                List<RelationshipReturn> returned = (List<RelationshipReturn> )JSON.deserialize(il.New_OBI_Object_ID__c, List<RelationshipReturn>.class);

                if(returned.size() > 0){
                    for(RelationshipReturn rr : returned){
                        if(relationshipIdToOBIRelationshipId.containsKey(rr.salesforceid) == false){
                            relationshipIdToOBIRelationshipId.put(rr.salesforceid, rr.relationshipid);
                        }
                    }
                }
            }           
        }
            
        List<Relationship__c> rels = [Select Id, OBI_Relationship_Id__c 
            					 	  FROM Relationship__c 
            					 	  WHERE Id IN :relationshipIds];
            
        for(Relationship__c r : rels){
                relationshipMap.put(r.Id, r);
        }
            
        for(Id i : relationshipIdToOBIRelationshipId.keySet()){
                
                Relationship__c c = new Relationship__c();
                c.Id = i;
                c.OBI_Relationship_Id__c = relationshipIdToOBIRelationshipId.get(i);
                
                relationshipsToUpdate.add(c);         
            }
            
        if(relationshipsToUpdate.size() > 0){
            update relationshipsToUpdate;
        }
    
    }


    public class RelationshipReturn{
        String salesforceid;
        String relationshipid;

    }
}