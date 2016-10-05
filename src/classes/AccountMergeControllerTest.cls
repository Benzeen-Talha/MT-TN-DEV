/**

 */
@isTest
private class AccountMergeControllerTest {
	
	@testSetup static void methodName() {
    	UserRole ur = [Select Id, Name From UserRole Where Name = 'Supplier Sales Rep' LIMIT 1];
    	Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Supplier Sales' LIMIT 1];
    	    	
    	//Create default user
    	User u = new User (LastName = 'Integration', FirstName = 'Sales', IsActive=true, Email = 'test.smo@tungsten-network.com', Alias='sinte', UserName='test.smo111@tungsten-network.com.temp', 
    						CommunityNickName='sintest', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId = UserInfo.getProfileId(), UserRoleId=ur.Id);
    	insert u;
    	
    	
    	//Create a new user with Sales Rep role
    	User salesUser = new User(LastName = 'Doe', FirstName = 'John', Email='john.doe@tungsten-network.com', IsActive=true, Alias='jdoe', UserName='john.doe@tungsten-network.com.temp',  
    						CommunityNickName='johndoe', Timezonesidkey='GMT', Localesidkey ='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId= profileId.Id);
    	insert salesUser;
    	
    	//De-activate the user.
    	User salesUser1 = new User(LastName = 'Doe', FirstName = 'John', Email='john.doe@tungsten-network.com', IsActive=false, Alias='jdoe1', UserName='john.doe1@tungsten-network.com.temp',  
    						CommunityNickName='johndoe1', Timezonesidkey='GMT', Localesidkey ='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId= profileId.Id);
    	insert salesUser1;
    	
    }
	
    static testMethod void myUnitTest() {
       AccountMergeController tcontroller = new AccountMergeController();
       
       OpportunityUtil tClass = new OpportunityUtil();
    	
    	Test.setMock(HttpCalloutMock.class, new MockObjects());
    	TungstenTestDataFactory.createCustomSetting();
    	TungstenTestDataFactory.CreatePricebookEntry();
        
       Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
       Id oppSupplierISRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supplier Sales-e-invoicing-IS').getRecordTypeId();
       Id oppSupplierWFRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supplier Sales-e-invoicing-WF').getRecordTypeId();
       
       User u = [Select Id from User Where UserName = 'test.smo111@tungsten-network.com.temp']; 
       Opportunity_Default_Owner__c newCustomSetting = new Opportunity_Default_Owner__c(Name='Sales Integration', User_Id__c = u.Id);
    	insert newCustomSetting;
       
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Invoice_Value__c = 999;
        acc.Invoice_Volume__c = 999;
        acc.Vendor_Code__c = '999';
        acc.Vat_Registration_Number__c = '888'; 
        acc.RecordTypeId = supplierRecordTypeId;
        acc.BillingStreet = 'test';
        acc.BillingPostalCode = 'test';
        acc.BillingStateCode = 'CA';
        acc.BillingCity = 'test';
        acc.BillingCountryCode = 'US';
        acc.Share_of_Capital__c = 'test';
        acc.Type_of_company__c = 'test';
        acc.Number_and_Court_of_Registration__c = 'test';
        acc.Town_of_Registration__c = 'test';
        acc.Chairman__c = 'test';
        acc.Chairman_of_the_Board__c = 'test';
        acc.Liable_Company__c = 'test';
        acc.Business_Style__c = 'test';
        acc.Profession__c = 'test';
        acc.Tax_Regime__c = 'test';
        acc.Liquidator_Name__c = 'test';
        acc.Early_Payment_Discount__c = '1';
        acc.Late_Payment_Penalty__c = 'test';
        acc.Permit_Number__c = '1';
        acc.Period_Start_Date__c = date.newInstance(2017, 3, 21);
        acc.Certification_Number__c = '1';
        acc.Has_Certification_Number__c = TRUE;
        acc.OBI_Entity_Id__c = '123456';
        insert acc;
        
        
    	Contact c = new Contact(FirstName='Test', LastName = 'Contact', AccountId = acc.Id, Email='test@test.com', Gender__c='Male', Phone='0123456789', Title='Mr');
    	insert c;
        
        AAA_Number__c aaa = new AAA_Number__c();
        aaa.Type__c = 'Supplier';
        aaa.Admin_Office__c = 'London';
        aaa.Service_Type__c = 'Integrated Solutions';
        aaa.Account__c = acc.Id;
        aaa.OBI_Account_ID__c = '12345';
        aaa.Name = 'AAAAA';
        insert aaa;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', AAA_Number__c = aaa.Id, StageName = 'Schedule Fist Call', CloseDate = Date.today(), 
        							Account = acc, RecordTypeId = oppSupplierISRecordTypeId, Description='Test', Campaign_type__c = 'Integrated Solution');
        opp.OBI_Sale_Id__c = 123456789;
        insert opp;
       
       AccountMergeController.search('AAA12345');
       AccountMergeController.mergeAccounts(); 
        
    }
}