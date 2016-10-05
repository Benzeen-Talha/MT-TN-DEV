public with sharing class TaskUtil {
	

	public static void updateOpportunityToFirstCall(List<Task> tasks){
      
    if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
      
      List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
      Set<Id> opportunityIdsForEngaged = new Set<Id>();

      List<Task> newTasks = [Select Id, Subject, Account.Name, WhatId, Status, Description 
                               From Task 
                               Where Id in :tasks];
      
      for(Task t : newTasks){
        if(t.Subject == 'First Call' && t.Description != null ){
            opportunityIdsForEngaged.add(t.WhatId);
            
        }
      }

      if(opportunityIdsForEngaged.size() > 0){
        List<Opportunity> opps = new List<Opportunity>();

        opps = [Select Id, StageName
                From Opportunity
                Where Id in :opportunityIdsForEngaged];

        if(opps.size() > 0){
          for(Opportunity o : opps){
            if(o.StageName == 'First Call'){
               o.StageName = 'Engaged';
              opportunitiesToUpdate.add(o);
            }
          }
        }
      }

      if(opportunitiesToUpdate.size() > 0){
        update opportunitiesToUpdate;
      }

    }

      
  }
}