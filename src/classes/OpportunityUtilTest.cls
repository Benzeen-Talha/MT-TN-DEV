/*
@Name:  OpportunityAssignmentControllerTest
* @description: Test class for Opportunity Assignment Controller
* 
* Change Log 
*
* Date        Author            Change Description
* -----------------------------------------------------------------------------
* 01/08/16    Rasesh Dave      Created Class  
 */
@isTest(seeAllData=false)
private class OpportunityUtilTest {
    
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
    
    static testMethod void myUnitTest() {
    	
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
       
       Account acc = TungstenTestDataFactory.createSupplierAccount('Test Account');
       insert acc;
        
        
    	Contact c = new Contact(FirstName='Test', LastName = 'Contact', AccountId = acc.Id);
    	insert c;
        
        AAA_Number__c aaa = new AAA_Number__c(Type__c = 'Supplier', Admin_Office__c = 'London', Service_Type__c = 'Integrated Solutions', Account__c = acc.Id,
        										OBI_Account_ID__c = '12345', Name = 'AAAAA');
        insert aaa;
        
        
        Opportunity opp = TungstenTestDataFactory.createSupplerOpportunity(acc.Id, aaa.Id, 'Test Opportunity', 'New Business');
        insert opp;
        
        Product2 prod = new Product2(Name='IS', IsActive=true);
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(Product2Id=prod.Id, Pricebook2Id = test.getStandardPricebookId(), UnitPrice = 1.0, IsActive = true);
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id);
        insert oli;
    	
    	OpportunityContactRole cr =  new OpportunityContactRole(OpportunityId = opp.Id, ContactId = c.Id, isPrimary = true, Role='Sales');
    	insert cr;
    	
    	Task t = new Task(Subject='First Call', whatId=Opp.Id, Status='completed', Description='Test',Priority='Normal');
    	//insert t;
    	
        Integration_Log__c il = new Integration_Log__c(); 
        insert il;
        
    	//OpportunityUtil.createCTALinkNMessageRequest(opp.Id, 'CTALinkPost');
    	OpportunityUtil.createOBISaleMessageRequest(opp.Id, 'OpportunityPost');
    	//OpportunityUtil.createOBIReleaseToImplementationNMessageRequest(opp.Id, 'ReleaseToImplementationPost');
    	OpportunityUtil.createWebFormLinkMessageRequest(opp.Id, 'CreateWebFormLinkPost');
    	OpportunityUtil.UpdateCommercialInfo(Opp.Id);
    	OpportunityUtil.UpdatePrimaryContact(Opp.Id);
    	OpportunityUtil.SendRequestCommercialInfo('Test Body',String.ValueOf(il.Id),String.ValueOf(acc.Id));
    	
    	OpportunityUtil.SendTariff('Test Body',String.ValueOf(il.id), String.Valueof(opp.Id), true, '');
    	OpportunityUtil.hasFirstCallTaskBeenCompleted(new List<Opportunity> {opp});
    	OpportunityUtil.hasEngagedTaskBeenCompleted(new List<Opportunity> {opp});
    	OpportunityUtil.StageChangeHandler(new List<Opportunity> {opp});
    	OpportunityUtil.opportunityProductCheck(new List<Opportunity> {opp});
    	OpportunityUtil.updateOpportunityStage('First call', new set<Opportunity>{opp});
    	
    	opportunityUtil.completeTask(opp.Id, 'First Call');
    	
    	opportunityUtil.completeTask(opp.Id, 'Engaged');
    	opportunityUtil.completeTask(opp.Id, 'Add Contact Details');
    	opportunityUtil.completeTask(opp.Id, 'Select Tariff');
    	opportunityUtil.completeTask(opp.Id, 'Terms Accepted');
    	opportunityUtil.completeTask(opp.Id, 'Send Confirmation Email');
    	opportunityUtil.completeTask(opp.Id, 'Release To Implementation');
    	
    	OpportunityUtil.updateOpportunityConfirmedRelationships(new List<Opportunity>{opp});
    	OpportunityUtil.SendFirstCall('Test Body',string.ValueOf(il.Id), String.ValueOf(opp.Id));
    	
    	OpportunityUtil.createOBITariffUpdate(opp.Id, 'Opportunity Select Tarif');
    	
    	oli.Band_A_Custom__c = 99;
    	update oli;
    	
    	OpportunityUtil.createOBITariffUpdate(opp.Id, 'Opportunity Select Tarif');
    	
    	
    	
    }
    
}