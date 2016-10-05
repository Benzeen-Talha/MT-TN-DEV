/**
 @Name:  OpportunityAssignmentController
* @description: Controller for OpportunityAssignment 
* 
* Change Log 
*
* Date        Author            Change Description
* -----------------------------------------------------------------------------
* 29/07/16    Rasesh Dave      Created Class  
 */
 
public with sharing class OpportunityAssignmentController {
 public string selectedSalesRep{get;set;}
 
 
 public PageReference processOpportunities(){
 	//Validation for User selection
 	System.debug(selectedSalesRep);
 	if(selectedSalesRep == '' || selectedSalesRep == null)
 	{
		Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR,'Please select a Sales Rep to assign the opportunities')); 	
		return null;	
 	}
 	
 	List<Opportunity> oppToUpdate = new List<Opportunity>();
 	
 	//iterate through each opportunity and see if it is selected
 	for(oppSection os : oppSectionList){
 		if(os.Selected){
 			os.Opportunity.OwnerId = (Id)selectedSalesRep;
 			oppToUpdate.Add(os.Opportunity);
 		}	
 	}
 	
 	System.Debug('~~~~~~~~~ ');
 	
 	if(opptoUpdate.size() > 0)
 	{update oppToUpdate;}
 	
 	
 	Apexpages.Pagereference returnPage = new ApexPages.PageReference('/apex/opportunityAssignment');
 	returnpage.setRedirect(true);
 	return returnPage;
 }
 
 public Pagereference cancel(){
 	return null;
 }
 
 //Populate the Sales rep dropdown
 public List<SelectOption> salesReps{
 	get{
 		salesReps = new List<SelectOption>();
 		//Add the default  --none option
 		salesReps.Add(new SelectOption('', '-- None --'));
 		//Get all the users with "Supplier Sales Rep" role.
 		for(User u : [Select Id, Name, Profile.Name From User Where UserRole.DeveloperName = 'Supplier_Sales_Rep' ])
 		{
 			salesReps.add(New SelectOption(u.Id, u.Name));
 		}
 		return salesReps;
 	}
 	set;
 }
 
 //Create the list of opportunities owned by default SMO user.
 public List<oppSection> oppSectionList{
 	get{
 		
 		if(oppSectionList == null)
 		{
 			oppSectionList = new List<OppSection>();
 			//get the custom setting for the default SMO user
 			Opportunity_Default_Owner__c odo = new Opportunity_Default_Owner__c();
 			odo = [Select Id, Name, User_Id__c From Opportunity_Default_Owner__c LIMIT 1];
 			for(Opportunity o: [Select Id, Name, Account.Name, OwnerId From Opportunity Where OwnerId =: odo.User_Id__c])
 			{
 				//Default the selection as false
 				oppSectionList.Add(new OppSection(false, o));
 			}	 				
 		}
 		return oppSectionList;
 	}
 	set;
 }
 
 //Wrapper class for the list of Opportunity with checkbox selection flag
 public class oppSection{
 	public boolean selected{get;set;}
 	public Opportunity opportunity{get;set;}
 	
 	//Default constructor. 	
 	public oppSection(boolean selected, Opportunity o){
 		this.selected = selected;
 		this.opportunity = new Opportunity();
 		this.opportunity = o;
 	}
 }
 	   
}