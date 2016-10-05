/*
*@Name: LeadTriggerHandler
*
*@Description: Trigger handler class for the Lead object trigger.
*@Author Tsambika Sotiraki 
*@Version 1.0
*
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------------
* 26/01/2016  T.Sotiraki      Created class 
*
*/
public with sharing class LeadTriggerHandler {
	
	public static void onAfterUpdate(List<Lead> leads){
		try{

			Set<Id> salesQualifiedLeads = new Set<Id>();

			if(leads.size() > 0){
				for(Lead l : leads){
					if(l.Status == 'Sales Qualified Lead'){
						salesQualifiedLeads.add(l.Id);
					}
				}
			}

			if(salesQualifiedLeads.size() > 0){
				
					futureLeadReassign(salesQualifiedLeads);
			}
		}
		catch(Exception ex){
			system.debug('Error on onBeforeUpdate: ' + ex.getMessage());
		}
	}


	@future
	public static void futureLeadReassign(Set<Id> leads) {

		List<Lead> qLeads = new List<Lead>();

		qLeads = [SELECT Id, OwnerId From Lead Where Id =: leads];

	  	Database.DMLOptions dmo = new Database.DMLOptions();

	   			AssignmentRule ar = [SELECT Active,Id,Name,SobjectType 
									 FROM AssignmentRule 
									 WHERE SobjectType = 'Lead'
									 AND Active = true
									 AND Name = 'Leads Based on Location and Industry'];
				

				if(ar != null){

					for(Lead l : qLeads){
						dmo.AssignmentRuleHeader.AssignmentRuleId = ar.Id;
						l.setOptions(dmo);
						
					}
					
				}

	  try {update(qLeads);}
	  catch (DmlException e) { // do something useful like emailing the sysad or logging to sobject }
	}

}
}