/**
* @Name:  EventTriggerHelper_Test
* @description: Test class for Event Trigger Test. 
* 
* Change Log 
*
* Date        Author            Change Description
* -----------------------------------------------------------------------------
* 08/05/16    M Talha      Created Class   
*/

// TO_DO :
// 
// 1. Opportunity First call scheduling from opportunity - validation rule 
// 2. Opportunity Stage change tracked in a field to calculate time in stage to send reminder to the opportunity owner







@isTest
private class EventTriggerHelper_Test {
    
    
  
  @isTest static void firstCallValidation_Opportunity() {
            test.startTest();
            test.setMock(HttpCalloutMock.class, new MockObjects());
           // Test.StopTest();

            TungstenTestDataFactory.createCustomSettingTriggerStatus();
            TungstenTestDataFactory.createCustomSettingBusinessHours();
            TungstenTestDataFactory.createCustomSetting();
            TungstenTestDataFactory.createPricebookentry();
                
            DateTime opportunityCreatedDate;
            DateTime opportunityAssignedData; 
         
        EventTriggerHelper oppHelp = new EventTriggerHelper();
      //  test.startTest();
        
      //Create default user
      User u = new User (LastName = 'Integration', FirstName = 'Sales', IsActive=true, Email = 'test.smo2@tungsten-network.com', Alias='sinte', UserName='test.smo2@tungsten-network.com.temp', 
                CommunityNickName='sinte2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId = UserInfo.getProfileId());
      insert u;
      
      //Create the custom setting for the default user
      Opportunity_Default_Owner__c newCustomSetting = new Opportunity_Default_Owner__c(Name='Sales Integration', User_Id__c = u.Id); 
      insert newCustomSetting;
        
      List<Opportunity> updateO1 = new List<Opportunity>();
       List<Opportunity> updateO2 = new List<Opportunity>();
        List<Opportunity> updateO3 = new List<Opportunity>();
    

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
        O3.ownerId = UserInfo.getUserId();
        O3.Name = 'Test Opt O3';
        O3.RecordTypeId = oppRT2.Id;
        O3.AccountId = A1.Id;
        O3.Type = 'Existing Business';      
        O3.StageName = 'Schedule First Call';
        O3.CurrencyIsoCode = 'GBP';
        O3.CloseDate = System.today().addDays(10);
        O3.AAA_Number__c = AA2.Id;
        Insert O3;
        

     // Opportunity O2 = [Select Id, Name, RecordType from Opportunity where recordTypeId =:oppRT.Id];

        opportunityCreatedDate = o3.CreatedDate;   

        o2.OwnerId = u.id;
        O2.StageName = 'Engaged';
        update o2;

        O2.StageName = 'Schedule First Call';
        update o2;


        Opportunity O4 = New Opportunity();
        O4.Id = O3.Id;
        O4.StageName = 'Engaged';
        update o4;


        Opportunity O5 = New Opportunity();
        O5.Id = O3.Id;
        O5.StageName = 'Schedule First Call';
        update O5;
      
       O3.StageName = 'Schedule First Call';
       update o3;




        List<OpportunityFieldHistory> optEventHistory = [SELECT Id,OpportunityId,CreatedDate,Field,NewValue,OldValue FROM OpportunityFieldHistory where Field = 'Owner' and OpportunityId =: O2.Id order by CreatedDate desc limit 1];           
        
       
        
        Event e1 = TungstentestDataFactory.createFirtCallEvent('Fist Call Event 1',System.Now().addDays(11),System.Now().addDays(11),o2.Id);
     // Event e1 = TungstentestDataFactory.createFirtCallEvent('Fist Call Event 1',opportunityCreatedDate.addDays(11),opportunityCreatedDate.addDays(11),o2.Id);
        try{
        insert e1;
        } catch(Exception ex){
            

            Boolean expectedExceptionThrown =  (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')? true : false);
         //   System.AssertEquals(expectedExceptionThrown, true); 
            System.debug('=======expectedExceptionThrown======'+ expectedExceptionThrown);       
            system.debug('====Esception e===='+ ex);
         //   System.Assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),1);
     
           // System.Assert(ex.getMessage().contains('Start and End date must be within 10 days of the Opportunity being assigned to a Supplier Sales rep.'),1);

            system.debug('=======Start and End date must be within 10 days of the Opportunity being assigned to a Supplier Sales rep.'+ ex);
        }
        
       if(optEventHistory.size()>0){
        opportunityAssignedData = optEventHistory[0].CreatedDate;  
        Event e2 = TungstentestDataFactory.createFirtCallEvent('Fist Call Event 1',opportunityAssignedData.addDays(9),opportunityAssignedData.addDays(9),o2.Id);
      
        try{
        insert e2;
        } catch(Exception ex){
            system.debug('=======Validation Error while setting strat or end date of first call'+ ex);
        }
       }  

        Test.StopTest();  
  
  }
  

}