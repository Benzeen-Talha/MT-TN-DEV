/**
 @Name:  OpportunityHandlerTest
* @description: Test class for Opportunity trigger
* 
* Change Log 
*
* Date        Author            Change Description
* -----------------------------------------------------------------------------
* 25/07/16    Rasesh Dave      Created Class  
 */
 
 @isTest
private class OpportunityHandlerTest {
    
    
    @testSetup static void methodName() {
    	UserRole ur = [Select Id, Name From UserRole Where Name = 'Supplier Sales Rep' LIMIT 1];
    	Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Supplier Sales' LIMIT 1];
    	    	
    	//Create default user
    	User u = new User (LastName = 'Integration', FirstName = 'Sales', IsActive=true, Email = 'test.smo@tungsten-network.com', Alias='sinte', UserName='test.smo@tungsten-network.com.temp', 
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

    
    static testmethod void defaultOpportunityOwner(){
    	
    	//Set the custom settins end points.
    	TungstenTestDataFactory.createCustomSetting();
    	TungstenTestDataFactory.createPricebookentry();
    	Test.setMock(HttpCalloutMock.class, new MockObjects());
    	
    	User u = [Select Id from User Where UserName= 'test.smo@tungsten-network.com.temp'];
    	
    	//Create the custom setting for the default user
    	Opportunity_Default_Owner__c newCustomSetting = new Opportunity_Default_Owner__c(Name='Sales Integration', User_Id__c = u.Id);
    	insert newCustomSetting;
    	
    	
    	//Create Supplier Opportunity
    	Account a = TungstentestDataFactory.createSupplierAccount('Test Account');
    	insert a;
    	
    	AAA_Number__c aaa = new AAA_Number__c();
        aaa.Type__c = 'Supplier';
        aaa.Account__c = a.Id;
        aaa.OBI_Account_ID__c = '12345';
        aaa.Name = 'AAAAA';
        insert aaa;
    	
    	Opportunity o = TungstentestDataFactory.createSupplierOpportunity(a.Id, 'Test Opportunity', 'New Business');
    	Opportunity o1 = TungstenTestDataFactory.createSupplierOpportunity(a.Id, 'New Test Opportunity', 'New Business');
    	Opportunity o2 = TungstenTestDataFactory.createSupplierOpportunity(a.Id, 'Newly Test Opportunity', 'New Business');
    	o.AAA_Number__c = aaa.Id;
    	o1.AAA_Number__c = aaa.Id;
    	o2.AAA_Number__c = aaa.Id;
    	List<Opportunity> oInsert = new List<Opportunity>{o, o1, o2};
    	insert oInsert;
    	
    	//Check if the Owner of the Opportunity is the Sales Integration user
    	o = [Select Id, Name, OwnerId From Opportunity Where Id =: o.Id];
    	System.assertEquals(o.OwnerId, u.Id);
    	
    	
    	
    	User salesUser = [Select Id from User Where UserName = 'john.doe@tungsten-network.com.temp'];
    	
    	//Create a user with Sales Rep role. Assign the Opportunity to this user
    	o.OwnerId = salesUser.Id;
    	update o;
    	
    	
    	//Create a new Opportunity for the Account.
    	//Opportunity o1 = TungstenTestDataFactory.createSupplierOpportunity(a.Id, 'New Test Opportunity', 'New Business');
    	//insert o1;
    	
    	
    	//check if the owner of this new opportunity is the existing sales rep.
    	o1 = [Select Id, name, Ownerid from Opportunity where Id =: o1.Id];
    	
    	//System.assertEquals(o1.OwnerId, salesuser.Id);
    	
    	User salesUser1 = [Select Id from User Where UserName = 'john.doe1@tungsten-network.com.temp'];
    	
    	o.OwnerId = salesUser1.Id;
    	o1.OwnerId = salesUser1.Id;
    	List<Opportunity> oList = new List<Opportunity>{o, o1};
    	//update oList;
    	
    	
    	//Create a new opportunity for the account.
    	//Opportunity o2 = TungstenTestDataFactory.createSupplierOpportunity(a.Id, 'Newly Test Opportunity', 'New Business');
    	//insert o2;
    	
    	//Check if the owner of the new opportunity is Sales Integration user
    	o2 = [Select Id, name, OwnerId From Opportunity where id=: o2.id];
    	
    	//System.assertEquals(o2.OwnerId, u.Id);
    	
    	
    	
    }
}