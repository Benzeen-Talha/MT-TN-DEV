@isTest
private class OverdueScheduleFirstCallTasksBatch_Test {
	
	@isTest static void OverdueScheduleFirstCallTasksBatch_method() {
		
		    test.startTest();
            test.setMock(HttpCalloutMock.class, new MockObjects());
           // Test.StopTest();


            TungstenTestDataFactory.createCustomSetting();
            TungstenTestDataFactory.createPricebookentry();
                
       List<Opportunity> updateFirstCallOpp = new List<Opportunity>();     
   
      //  test.startTest();
        
      //Create default user
      User u = new User (LastName = 'Integration', FirstName = 'Sales', IsActive=true, Email = 'test.smo2@tungsten-network.com', Alias='sinte', UserName='test.smo2@tungsten-network.com.temp', 
                CommunityNickName='sinte2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId = UserInfo.getProfileId());
      insert u;
      
      //Create the custom setting for the default user
    	Opportunity_Default_Owner__c newCustomSetting = new Opportunity_Default_Owner__c(Name='Sales Integration', User_Id__c = u.Id); 
    	insert newCustomSetting;

    	recordType oppRT2 = [Select Id from RecordType where SobjectType = 'Opportunity' and  developerName = 'Integrated_Solutions_Sales'];
     //Create Supplier Opportunity
    	Opportunity o2 = TungstentestDataFactory.createFirstCallOpportunity('Test Opportunity','Supplier Sales-e-invoicing-IS'); 
    	Insert o2; 

     	  Account A1 = New Account();
        A1.Name = 'First Call Account Name';
        insert A1;

        AAA_Number__c AA2 = new AAA_Number__c();
        AA2.Name = 'AAA115075913';
        AA2.Account__c = A1.Id;
        AA2.Type__c = 'Supplier';
        insert AA2;
        

        Opportunity O3 = New Opportunity();
        O3.Name = 'Test Opt O3';
        O3.RecordTypeId = oppRT2.Id;
        O3.AccountId = A1.Id;
        O3.Type = 'Existing Business';      
        O3.StageName = 'Schedule First Call';
        O3.CurrencyIsoCode = 'GBP';
        O3.CloseDate = System.today().addDays(10);
        O3.AAA_Number__c = AA2.Id;
        O3.OwnerId = u.id;
        updateFirstCallOpp.add(O3);
        Insert updateFirstCallOpp;


              /******* Archive Order Batch Test *****/
      	OverdueScheduleFirstCallTasks_Batch firstCallBatchRun = new OverdueScheduleFirstCallTasks_Batch();
        Database.QueryLocator ql = firstCallBatchRun.start(Null);       
        firstCallBatchRun.execute(Null, updateFirstCallOpp);       
        firstCallBatchRun.finish(null);       
        ID batchprocessid = Database.executeBatch(firstCallBatchRun); 
	

       test.stopTest();


	}
	

    
    @isTest static void assignTaskBatch_Scheduler_Test(){
              
    //createConfigData();  
        String CRON_EXP  = '0 0 23 * * ?';  
        Test.startTest();      
      
         
    system.schedule('First Call Task Schedule1' , CRON_EXP , new OverdueScheduleFirstCallTasks_Scheduler());      
         
        Test.stopTest();
   
    }


	
}