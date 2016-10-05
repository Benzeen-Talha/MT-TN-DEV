/**
* @Name:  OverdueScheduleFirstCallTasks_Batch
* @description: Batch handler class to remind Opportunity owner to Scheduling first call after the deadline is breached
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 15/09/16    M Talha         Batch Apex   
*/
    




global class OverdueScheduleFirstCallTasks_Batch implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	
	global OverdueScheduleFirstCallTasks_Batch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

	   List<Opportunity> overdueOpportunities = new List<Opportunity>();
      for(Opportunity o : [Select Id, Name,AAA_Number__r.Name,Schedule_First_Call_Stage_Calculation__c,OwnerId,StageName from opportunity where StageName = 'Schedule First Call' and Schedule_First_Call_Stage_Calculation__c <> NUll]){               
          
          Integer  dateDifference = System.today().daysBetween(Date.valueOf(o.Schedule_First_Call_Stage_Calculation__c));       
          
          system.debug('========dateDifference======'+dateDifference);
          //&& exisingTaskMap.get(o.Name).Subject <> o.Name && exisingTaskMap.get(o.Owner.Id).OwnerId <> o.Owner.Id
           
            if(dateDifference <10){
                overdueOpportunities.add(o);
            }
        }


    system.debug('==========overdueOpportunities======='+overdueOpportunities);    
    query = 'Select Id, Name,AAA_Number__r.Name, Schedule_First_Call_Stage_Calculation__c,OwnerId,StageName from Opportunity where Id IN: overdueOpportunities'; 
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   			
        System.debug('======Scope========'+scope); 		 	
        List<Task> tasksToCreate = new List<Task>();   		 	
  		 	
        for(sObject sObj : scope) {       		
    		Opportunity o = (Opportunity)sObj;
    		Task t = new Task();
        t.Description = 'This task has been scheduled as a reminder.';
        t.OwnerId = o.OwnerId;
        t.WhatId = o.Id;
        t.Priority = 'Normal';
        t.Subject = 'You have not yet scheduled a call with a customer: ' + o.Name + ' - ' +o.AAA_Number__r.Name;
        t.Status = 'Open';
        tasksToCreate.add(t);

		}

		System.debug('========tasksToCreate======='+tasksToCreate);
         if(tasksToCreate.size() > 0){
              insert tasksToCreate;
            }

	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}