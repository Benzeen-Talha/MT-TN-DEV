public with sharing class OpportunityContactRoleTriggerHandler {
	

	public static void onAfterInsert(List<Opportunity_Contact_Role__c> roles){
        try{

        }
        catch(Exception ex){
        	 System.debug('Error onAfterInsert: ' + ex.getMessage());
        }
    }

    public static void onAfterUpdate(List<Opportunity_Contact_Role__c> roles, Map<Id, Opportunity_Contact_Role__c> oldMap){
        try{

        }
        catch(Exception ex){
        	 System.debug('Error onAfterUpdate: ' + ex.getMessage());
        }
    }
}