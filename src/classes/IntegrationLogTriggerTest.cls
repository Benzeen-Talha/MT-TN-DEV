/**
* @Name:  IntegrationLogTriggerTest
* @description: Test class for integration log trigger. 
* 
* Change Log 
*
* Date        Author            Change Description
* -----------------------------------------------------------------------------
* 08/05/16    M.Barbarelli      Created Class   


* Date        Updated by            Change Description
* -----------------------------------------------------------------------------
* 06/09/16    M Talha               Modified Test Class   

*/

// TO_DO :
// 
// 1. Implement OBI callout as a class. 
// 2. Build Mock 
// 3. Use mock in test method, but which?  This?  Or for campaign util? 
// 4. Determine how responses are sent to Integration Log service. 

@isTest(seeAllData=false)
private class IntegrationLogTriggerTest {

    @isTest static void testCampaignLogEvent() {

        TungstenTestDataFactory.createCustomSettingTriggerStatus();
        TungstenTestDataFactory.createCustomSetting();
        TungstenTestDataFactory.createPricebookentry();

        Test.setMock(HttpCalloutMock.class, new MockObjects());
		Boolean result = false;         
        
        Campaign c = new Campaign(Name='Dummy Campaign', Description='Dummy Description', Number_of_Contacts__c=1, OBI_Object_ID__c='200');
        Insert c;
				
        Integration_Log__c il = [SELECT Id, Campaign__c From Integration_Log__c where Campaign__c = :c.Id];
    	
        if(il!=null){
            result = true; 
        }
        
        System.assertEquals(true, result);
         RecordType oppRT2 = [Select Id from RecordType where SobjectType = 'Opportunity' and  developerName = 'Integrated_Solutions_Sales'];
         RecordType supplierRT = [Select Id from RecordType where SobjectType = 'Account' and  Name = 'Supplier'];
         RecordType buyerRT = [Select Id from RecordType where SobjectType = 'Account' and  Name = 'Buyer'];


        TungstenTestDataFactory.createCampaing();


        Campaign camp1 = new Campaign();
        camp1.Name = 'Test My Camp';
        Insert Camp1;

        Account A1 = New Account(); //Supplier
        A1.Name = 'Interaction Log Supplier Ac';
        A1.RecordTypeId = supplierRT.Id;
        insert A1;

        
        Account A2 = New Account();
        A2.Name = 'Interaction Log Buyer Ac';
        A2.RecordTypeId = buyerRT.Id;
        insert A2;

        AAA_Number__c AA2 = new AAA_Number__c();
        AA2.Name = 'AAA115075913';
        AA2.Account__c = A1.Id;
        AA2.Type__c = 'Supplier';
        insert AA2;

        Integration_Log__c ilTest = new Integration_Log__c();
        ilTest.AAA_Number__c = AA2.Id;
        ilTest.Request_Type__c = '';
        insert ilTest;

        Integration_Log__c uilTest = New Integration_Log__c();
        uilTest.Id = ilTest.id;
        uilTest.AAA_Number__c = AA2.Id;
        uilTest.Request_Type__c = 'AAA Insert';
        update uilTest;

       Opportunity ilO = TungstenTestDataFactory.interactionLog_Opportunity('Test Opportunity','Supplier Sales-e-invoicing-IS');
        //insert ilO;

        Opportunity_Default_Owner__c defaultOwner = New Opportunity_Default_Owner__c();
        defaultOwner.Name = 'Sales Integration';
        defaultOwner.User_Id__c = UserInfo.getUserId();
        insert defaultOwner;

        Opportunity O3 = New Opportunity();
        O3.ownerId = defaultOwner.User_Id__c;
        O3.Name = 'Test Opt O3';
        O3.RecordTypeId = oppRT2.Id;
        O3.AccountId = A1.Id;
        O3.Type = 'Existing Business';      
        O3.StageName = 'Schedule First Call';
        O3.CurrencyIsoCode = 'GBP';
        O3.CloseDate = System.today().addDays(10);
        O3.AAA_Number__c = AA2.Id;
        Insert O3;


         Integration_Log__c ilTestOpp = new Integration_Log__c();
        ilTestOpp.Opportunity__c = O3.Id;
        ilTestOpp.Request_Type__c = '';     
        insert ilTestOpp;

        Integration_Log__c uilTestOpp = New Integration_Log__c();
        uilTestOpp.id = ilTestOpp.id;
        uilTestOpp.AAA_Number__c = AA2.Id;
        uilTestOpp.Request_Type__c = 'Opportunity Insert';
        update uilTestOpp;

        Contact cont_1 = TungstenTestDataFactory.interactionLog_Contact(A1.id);
        insert cont_1;

        Integration_Log__c ilTestOppCTA = new Integration_Log__c();
        ilTestOppCTA.Opportunity__c = O3.Id;
        ilTestOppCTA.Contact__c = cont_1.Id;
        ilTestOppCTA.Request_Type__c = '';       
        insert ilTestOppCTA;

        Integration_Log__c uilTestOppCTA = New Integration_Log__c();
        uilTestOppCTA.id = ilTestOppCTA.id;     
        uilTestOppCTA.Request_Type__c = 'Opportunity Click To Accept Link';
        update uilTestOppCTA;

        Integration_Log__c uilTestOppCTAWF = New Integration_Log__c();
        uilTestOppCTAWF.id = uilTestOppCTA.id;     
        uilTestOppCTAWF.Request_Type__c = 'Opportunity Create Web Form Link';
        update uilTestOppCTAWF;

        Integration_Log__c ilTestContact = new Integration_Log__c();
        ilTestContact.Account__c = A1.ID;
        ilTestContact.Opportunity__c = O3.Id;
        ilTestContact.Contact__c = cont_1.Id;
        ilTestContact.Request_Type__c = '';       
        insert ilTestContact;

        Integration_Log__c uilTestContact = new Integration_Log__c();
        uilTestContact.ID = ilTestContact.ID;

        uilTestContact.Request_Type__c = 'Contact Insert';       
        update uilTestContact;

        Relationship__c R1 = TungstenTestDataFactory.interactionLog_Relationship(A1.id,A2.Id,Camp1.id, O3.Id);
        Insert R1;


      //  if(il.Request_Type__c == 'Contact Insert' && il.Contact__c != null)


      //  List<Contact> contacts = [Select id, OBI_CTA_Link__c, OBI_Contact_ID__c FROM Contact WHERE id IN :contactIds];




       //  if(il.Request_Type__c == 'Opportunity Insert' && iL.Opportunity__c != null){
         //           oppLogs.add(iL);


      

    }




}