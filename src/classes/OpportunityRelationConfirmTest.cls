/**

 */
@isTest
private class OpportunityRelationConfirmTest {

	@testSetup static void methodName() {
	  UserRole ur = [Select Id, Name From UserRole Where Name = 'Supplier Sales Rep' LIMIT 1];
    	Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Supplier Sales' LIMIT 1];
    	    	
    	//Create default user
    	User u = new User (LastName = 'Integration', FirstName = 'Sales', IsActive=true, Email = 'test.smo111@tungsten-network.com', Alias='sinte', UserName='test.smo111@tungsten-network.com', 
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
       
        Test.setMock(HttpCalloutMock.class, new MockObjects());
    	TungstenTestDataFactory.createCustomSetting();
    	TungstenTestDataFactory.CreatePricebookEntry();
    	
    	User u = [Select Id from User Where UserName = 'test.smo111@tungsten-network.com'];
    	User salesUser = [Select Id from User where UserName = 'john.doe@tungsten-network.com.temp'];    	
    	//Create the custom setting for the default user
    	Opportunity_Default_Owner__c newCustomSetting = new Opportunity_Default_Owner__c(Name='Sales Integration', User_Id__c = u.Id);
    	insert newCustomSetting;
    	
       //Create Buyer Account
	   Account a1 = TungstenTestDataFactory.createBuyerAccount('Buyer Account');
	   insert a1;
	   
	   //Create Buyer Account Campaign
	   
	   
	   //Create Supplier Account
	   Account a2 = TungstenTestDataFactory.createSupplierAccount('Supplier Account');
	   insert a2;
	   
	   AAA_Number__c aaa = new AAA_Number__c();
        aaa.Type__c = 'Supplier';
        aaa.Account__c = a1.Id;
        aaa.OBI_Account_ID__c = '12345';
        aaa.Name = 'AAAAA';
        insert aaa;
        
	   //Create Supplier Opportunity
	   Opportunity o1 = TungstenTestDataFactory.createSupplierOpportunity(a2.Id, 'Supplier Opportunity','New Business');
	   o1.AAA_Number__c = aaa.Id;
	   insert o1;
	   
	   //Create Relationship between Buyer Account and Supplier Account
	   Relationship__c r1 = new Relationship__c();
	   r1.Supplier_Account__c = a2.Id;
	   r1.Buyer_Account__c = a1.Id;
	   r1.Opportunity__c = o1.Id;
	   insert r1;
       
       //Get the Opportunity
        Opportunity o = [Select Id, Name From Opportunity Where Name=: 'Supplier Opportunity'];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        OpportunityRelationConfirm tController = new OpportunityRelationConfirm(sc);       
        
        OpportunityRelationConfirm.tRelation tempObject = new OpportunityRelationConfirm.tRelation();
                
        List<OpportunityRelationConfirm.tRelation> tList = tController.tRelList;
        
        tController.ProcessRelation();
        
        system.AssertEquals(tList.Size(), 1);
        tController.tRelList[0].selected = true;
        
        tController.ProcessRelation();
        
    }
}