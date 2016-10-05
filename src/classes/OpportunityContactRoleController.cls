public with sharing class OpportunityContactRoleController {
    public Opportunity opportunity;
    public set<Id> ContactIdList{get;set;}
    
    public OpportunityContactRoleController(ApexPages.StandardController stdController)
    {
    	this.opportunity = (Opportunity)stdController.getRecord();
    	
    	this.opportunity = [Select Id, Name, AccountId 
    							From Opportunity Where Id =: this.opportunity.Id];
    }
    
    public List<OpportunityContactRole> contactRoleList{
    	get{
    		if(contactRoleList == null){
    			contactRoleList = new List<OpportunityContactRole>();
    			
    			contactRoleList = [Select Id, OpportunityId, isPrimary, ContactId, Contact.InActive__c, Contact.AccountId, contact.Name, contact.Email, 
    								contact.Phone, contact.Account.Name, Role	   
    								From OpportunityContactRole Where OpportunityId =: this.opportunity.Id AND Contact.InActive__c = false];
    		}
    		return contactRoleList;
    	}
    	set;
    }
    
    public pageReference newPage(){
    	pageReference returnPage = new pageReference('/apex/ContactRoleEdit?Id=' + this.Opportunity.Id);
    	returnPage.setRedirect(true);
    	return returnPage;
    }
    	
}