/**
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
private class OpportunityAssignmentControllerTest {

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
        
        Test.setMock(HttpCalloutMock.class, new MockObjects());
        
        TungstenTestDataFactory.createCustomSetting();
    	TungstenTestDataFactory.createPricebookentry();
        
       //Set the custom settins end points.
    	TungstenTestDataFactory.createCustomSetting();
    	TungstenTestDataFactory.createPricebookentry();
    	
    	User u = [Select Id from User Where UserName = 'test.smo111@tungsten-network.com.temp'];
    	User salesUser = [Select Id from User where UserName = 'john.doe@tungsten-network.com.temp'];    	
    	//Create the custom setting for the default user
    	Opportunity_Default_Owner__c newCustomSetting = new Opportunity_Default_Owner__c(Name='Sales Integration', User_Id__c = u.Id);
    	insert newCustomSetting;
    	
        
    	//Create Supplier Opportunity
    	Account a = TungstentestDataFactory.createSupplierAccount('Test Account');
    	insert a;
        AAA_Number__c aaNumber = new AAA_Number__c();
        aaNumber.Account__c = a.Id;
        aaNumber.Type__c = 'Supplier';
        insert aaNumber;
        
    	List<Opportunity> oList = new List<Opportunity>();
    	
    	for(integer i = 0; i < 10; i++)
    	{
            Opportunity o = TungstentestDataFactory.createSupplierOpportunity(a.Id, 'Test Opportunity', 'New Business');
            o.AAA_Number__c = aaNumber.Id;
    		oList.Add(o);
    		
    	} 
    	insert oList;
       	
		OpportunityAssignmentController tController = new OpportunityAssignmentController();
		
		tController.Cancel();
		
		//Get the list of Sales Rep
		List<SelectOption> sOpt = tController.SalesReps;
		//Select one user to transfer the oppsd
		tController.selectedSalesRep = String.Valueof(salesUser.Id);
		
				
		List<OpportunityAssignmentController.oppSection> tList = tController.oppSectionList;
		
		//mark 1st opp as selected to be transferred to new user;
		if(tList.Size() > 0){
			tList[0].selected = true;
		}
		
		System.Debug('=========' + tList[0].Opportunity.OwnerId);
		System.Debug('=========' + tController.selectedSalesRep);
		
		//Call the process method
		tController.ProcessOpportunities();
		
		Opportunity resultOpp = [Select Id, OwnerId From Opportunity Where Id =: tList[0].Opportunity.Id];
		
		System.Assertequals(String.ValueOf(resultOpp.OwnerId),tcontroller.selectedSalesRep );
		
        
    }
}