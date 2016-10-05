@isTest
private class CampaignMemberUtil_Test {
	
	@isTest static void CampaignMemberUtil_method() {
		// Implement test code

		TungstenTestDataFactory.createCustomSettingTriggerStatus();
        TungstenTestDataFactory.createCustomSetting();
        TungstenTestDataFactory.createPricebookentry();

        test.startTest();

        CampaignMemberUtil campUtil = new CampaignMemberUtil();


        Test.setMock(HttpCalloutMock.class, new MockObjects());
       
        User u = new User (LastName = 'Integration', FirstName = 'Sales', IsActive=true, Email = 'test.smo2@tungsten-network.com', Alias='sinte', UserName='test.smo2@tungsten-network.com.temp', 
                CommunityNickName='sinte2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId = UserInfo.getProfileId());
        insert u;

        RecordType BuyerRT = [Select Id from RecordType where SObjectType = 'Account' and Name = 'Buyer'];

    	//contact cc = TungstenTestDataFactory.utilityContact();
		//insert cc;
	
		Campaign cmp = new Campaign();


		Account A1 = New Account();
        A1.Name = 'First Call Account Name';
        A1.OBI_Entity_Id__c = '3325617';
        A1.RecordTypeId = BuyerRT.Id;
        insert A1;

		cmp.Name = 'Test Campaign';
		cmp.IsActive = true;
		cmp.StartDate = System.Today();
		cmp.EndDate = System.Today().addDays(10);
		cmp.Buyer_Account__c = A1.Id;
		Insert cmp;

        Campaign cmp2 = new Campaign();
        cmp2.Name = 'Test Campaign 2';
        cmp2.IsActive = true;
        cmp2.StartDate = System.Today();
        cmp2.EndDate = System.Today().addDays(10);
        cmp2.Buyer_Account__c = A1.Id;
        Insert cmp2;

	

        AAA_Number__c AA2 = new AAA_Number__c();
        AA2.Name = 'AAA115075913';
        AA2.Account__c = A1.Id;
        AA2.Type__c = 'Supplier';
        AA2.Type__c = 'Buyer';
        insert AA2;
    
		 contact c = new contact();
         c.FirstName = 'Test Cont';
         c.LastName = 'Test Cont Last Name';
         c.Title = 'Mr';
         c.Email = 'Joe.Blog@tungsten.com';
         c.Fax = '0002223456';
         c.HomePhone  = '07689865478';
         c.Salutation = 'PM';
         c.Phone = '078675123456';
         c.AccountId = A1.Id;
         c.MobilePhone =  '07689865478';     
         insert c;

            contact c1 = new contact();
         c1.FirstName = 'Test Cont';
         c1.LastName = 'Test Cont Last Name';
         c1.Title = 'Mr';
         c1.Email = 'Joe.Blog@tungsten.com';
         c1.Fax = '0002223456';
         c1.HomePhone  = '07689865478';
         c1.Salutation = 'PM';
         c1.Phone = '078675123456';
         c1.AccountId = A1.Id;
         c1.MobilePhone =  '07689865478';     
         insert c1;


         CampaignMember cmpMem = new CampaignMember();
         cmpMem.CampaignId = cmp.Id;
         cmpMem.ContactId = c.id;
        // cmpMem.Country = 'United Kingdom';
         //cmpMem.FirstName = 'Test CmpMember';
         //cmpMem.LastName = 'Test CmpMember';
        insert cmpMem; 
         
        delete cmp2;

        CampaignMember cmpMem2Del = new CampaignMember();
         cmpMem2Del.CampaignId = cmp.Id;
         cmpMem2Del.ContactId = c1.id;
        // cmpMem.Country = 'United Kingdom';
         //cmpMem.FirstName = 'Test CmpMember';
         //cmpMem.LastName = 'Test CmpMember';
        insert cmpMem2Del;
        Delete cmpMem2Del; 			
		

        test.stopTest();



	}
	

	
}