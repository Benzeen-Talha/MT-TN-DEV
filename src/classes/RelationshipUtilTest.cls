/**
* @Name:  RelationshipUtilTest
* @description: Utilities test class for Relationship Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 13/06/16    T.Sotiraki      Created Class   
*/
@isTest
private class RelationshipUtilTest {
	
	@testSetup static void methodName() {
		UserRole ur = [Select Id, Name From UserRole Where Name = 'Supplier Sales Rep' LIMIT 1];
    	Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Supplier Sales' LIMIT 1];
    	    	
    	//Create default user
    	User u = new User (LastName = 'Integration', FirstName = 'Sales', IsActive=true, Email = 'test.smo@tungsten-network.com', Alias='sinte111', UserName='test.smo111@tungsten-network.com.temp', 
    						CommunityNickName='sinte111', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId = UserInfo.getProfileId(), UserRoleId=ur.Id);
    	insert u;
    	
    	
    	//Create a new user with Sales Rep role
    	User salesUser = new User(LastName = 'Doe', FirstName = 'John', Email='john.doe@tungsten-network.com', IsActive=true, Alias='jdoe', UserName='john.doe@tungsten-network.com.temp',  
    						CommunityNickName='johndoe', Timezonesidkey='GMT', Localesidkey ='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId= profileId.Id);
    	insert salesUser;
	}
	
	static testmethod void test_method_one() {
		Test.setMock(HttpCalloutMock.class, new MockObjects());
    	TungstenTestDataFactory.createCustomSetting();
    	TungstenTestDataFactory.CreatePricebookEntry();
    	
    	Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
       Id oppSupplierISRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supplier Sales-e-invoicing-IS').getRecordTypeId();
       Id oppSupplierWFRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supplier Sales-e-invoicing-WF').getRecordTypeId();
    	
    	User u = [Select Id from User Where UserName = 'test.smo111@tungsten-network.com.temp']; 
        Opportunity_Default_Owner__c newCustomSetting = new Opportunity_Default_Owner__c(Name='Sales Integration', User_Id__c = u.Id);
    	insert newCustomSetting;
    	
    	//Create a Supplier Account
    	 Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Invoice_Value__c = 999;
        acc.Invoice_Volume__c = 999;
        acc.Vendor_Code__c = '999';
        acc.Vat_Registration_Number__c = '888';
        acc.BillingCountry = 'United Kingdom';
        acc.RecordTypeId = supplierRecordTypeId;
        acc.BillingStreet = 'test';
        acc.BillingPostalCode = 'test';
        acc.BillingState = 'California';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'United States';
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
        acc.OBI_Entity_Id__c = '12344567';
        
        insert acc;
        
        Contact c = new Contact();
        //c.Contact_Type__c = 'Buyer';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Gender__c = 'Male';
        c.Interested_In__c = 'e-invoicing';
        c.MailingCountryCode ='GB';
        c.Source__c = 'supplier';
        c.AccountId = acc.id;
        insert c;
        
        
        AAA_Number__c aaa = new AAA_Number__c();
        aaa.Type__c = 'Supplier';
        aaa.Account__c = acc.Id;
        aaa.OBI_Account_ID__c = '12345';
        aaa.Name = 'AAAAA';
        
        insert aaa;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', AAA_Number__c = aaa.Id, StageName = 'Schedule Fist Call', CloseDate = Date.today(), Account = acc, RecordTypeId = oppSupplierISRecordTypeId);
        opp.OBI_Sale_Id__c = 123456789;
        insert opp;
        
        Campaign cm = new Campaign();
        cm.IsActive = true;
        cm.Name = 'Test Campaign';
        cm.Status = 'In Progress';
        cm.OBI_Object_ID__c = '1234567';
        insert cm;
        
        Relationship__c rel = new Relationship__c();
        rel.Supplier_Account__c = acc.Id;
        rel.Opportunity__c = opp.id;
        rel.Buyer_AAA_Number__c = aaa.Id;
        rel.Supplier_AAA_Number__c = aaa.Id;
        rel.Vendor_Code__c = '12345';
        rel.RTB_Reason_Code__c = 'RTB055 - Request for Information';
        rel.Off_Hold_Date__c = Date.today();
        rel.On_Hold_Reason__c = 'Temporary block';
        rel.PO_Required__c = 'Not Needed';
        rel.Attachment_Settings__c = 'No';
        rel.PO_Validation__c = 'Range';
        rel.Campaign__c = cm.Id;
        insert rel;
        
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'RelationshipPost');
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'CampaignRelationshipPost');
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'RTBPost');
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'OnHoldPost');
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'OffHoldPost');
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'RelationshipPut');
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'NoPotentialPost');
        RelationshipUtil.updateOpportunityConfirmedRelationships(new List<Relationship__c>{rel});
        RelationshipUtil.createOBIJSONBulkRelaionshipRequest(new List<Relationship__c>{rel},'CampaignRelationshipPost');
        RelationshipUtil.createOBIJSONBulkRelaionshipRequest(new List<Relationship__c>{rel},'RelationshipPost');
        
        
        rel.PO_Required__c = 'Invoice Only';
        rel.Attachment_Settings__c = 'Supplier will indicate'; 
        update rel;
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'RelationshipPut');
        
        rel.PO_Required__c = 'Invoices & Credit Notes';
        rel.Attachment_Settings__c = 'OB10 expects attachments';
        update rel;
        RelationshipUtil.createOBIJSONMessageRequest(rel, 'RelationshipPut');
        
        
        //public static void sendRequest(String email, String req, String logId, String oppId, String campaignId, String accountId, String relationshipId, String settingInstance){
        Integration_Log__c il = new Integration_Log__c();
        insert il;
        
        RelationshipUtil.sendRequest('test@test.com','',String.ValueOf(il.id),string.ValueOf(Opp.Id),'',string.ValueOf(acc.Id), string.ValueOf(rel.Id),'RelationshipPost');
        	
        }
	
}