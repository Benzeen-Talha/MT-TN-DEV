global class OverdueScheduleFirstCallTasks_Scheduler implements Schedulable {
	
   	global void execute(SchedulableContext sc) { 
  		if([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')] <5){
    	OverdueScheduleFirstCallTasks_Batch TaskBatch = new OverdueScheduleFirstCallTasks_Batch();
    	ID batchprocessid = Database.executeBatch(TaskBatch);  
    } else {

    //schedule this same schedulable class again in 30 mins
   
   OverdueScheduleFirstCallTasks_Scheduler TaskScheduler = new OverdueScheduleFirstCallTasks_Scheduler();
   Datetime scheduleDT = Datetime.now() + (0.024305); // i.e. 30 mins
   String timeForScheduler = scheduleDT.format('s m H d M \'?\' yyyy');
   Id schedId = System.Schedule('Assign First Call Task Batch Retry'+timeForScheduler,timeForScheduler,TaskScheduler);
       }

   }

}