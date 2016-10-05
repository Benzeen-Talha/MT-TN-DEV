public with sharing class TaskTriggerHandler {
	
	public static void onAfterUpdate(List<Task> tasks, Map<Id, Task> oldMap){
        
        TaskUtil.updateOpportunityToFirstCall(tasks);
        
    }

    public static void onAfterInsert(List<Task> tasks, Map<Id, Task> oldMap){
        
        TaskUtil.updateOpportunityToFirstCall(tasks);
        
    }



}