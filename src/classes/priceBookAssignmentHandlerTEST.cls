@isTest
private class priceBookAssignmentHandlerTEST {
	
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
    	TungstenTestDataFactory.createCustomSetting();
    	TungstenTestDataFactory.createPricebookentry();
        Test.setMock(HttpCalloutMock.class, new MockObjects());
        
        User u = [Select Id from User Where UserName= 'test.smo111@tungsten-network.com.temp'];
    	
    	//Create the custom setting for the default user
    	Opportunity_Default_Owner__c newCustomSetting = new Opportunity_Default_Owner__c(Name='Sales Integration', User_Id__c = u.Id);
    	insert newCustomSetting;
        
       Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
       Id oppSupplierISRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supplier Sales-e-invoicing-IS').getRecordTypeId();
       Id oppSupplierWFRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supplier Sales-e-invoicing-WF').getRecordTypeId();
       


 
        tariffMapping__c objTM = new tariffMapping__c();
        objTM.Name = 'UNITED STATES';
        objTM.WF_Tariff__c = '5013'; 
        objTM.IS_Tariff__c = '5086';
        objTM.OBI_Country_Code__c = '';
        objTM.Ledger__c = 'US';
        objTM.Currency__c = 'USD';
        insert objTM;

        system.debug('========objTM======='+objTM);

        PriceBook2 objPB = new PriceBook2();
        objPB.Name = objTM.IS_Tariff__c;//'5086';  
        objPB.Sales_Type__c = 'Supplier'; 
        objPB.Service_Type__c = 'Integrated Solution';
        objPB.Country_Code__c ='GB';
        objPB.Sales_Type__c = 'Supplier';
        insert objPB;


        PriceBook2 objPB2 = new PriceBook2();
        objPB2.Name = '5013';  
        objPB2.Sales_Type__c = 'Supplier'; 
        objPB2.Service_Type__c = 'Integrated Solution';
        objPB2.Country_Code__c ='GB';
        objPB2.Sales_Type__c = 'Supplier';
        insert objPB2;



        PriceBook2 objPB3 = new PriceBook2();
        objPB3.Name = '5013';  
        objPB3.Sales_Type__c = 'Supplier'; 
        objPB3.Service_Type__c = 'Web Form';
        objPB3.Country_Code__c ='GB';
        objPB3.Sales_Type__c = 'Supplier';
        insert objPB3;

        
        Product2 objProduct_IS = new Product2();
        objProduct_IS.Bundle__c = false;
        objProduct_IS.CurrencyIsoCode = 'GBP';
        objProduct_IS.Description = '';
        objProduct_IS.Family = '';
        objProduct_IS.Name = 'Integrated Solution';
        objProduct_IS.IsActive = True;
        insert objProduct_IS;

        Product2 objProduct_WS = new Product2();
        objProduct_WS.Bundle__c = false;
        objProduct_WS.CurrencyIsoCode = 'GBP';
        objProduct_WS.Description = '';
        objProduct_WS.Family = '';
        objProduct_WS.Name = 'Web Form';
        objProduct_WS.IsActive = True;
        insert objProduct_WS;


        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = objProduct_IS.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;


        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = objProduct_IS.Id,
            UnitPrice = 12000,  IsActive = true);
        insert customPrice;

        List<Account> PBAcList = new    List<Account> ();
       
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
        acc.CurrencyIsoCode = 'GBP';
        
        
        insert acc;
        
   
        
        Account lstAccount = new Account();
        
        lstAccount.Name = 'Test Account 2';
        lstAccount.Invoice_Value__c = 109;
        lstAccount.Invoice_Volume__c = 129;
        lstAccount.Vendor_Code__c = '209';
        lstAccount.Vat_Registration_Number__c = '88008';
        lstAccount.BillingCountry = 'United Kingdom';
        lstAccount.RecordTypeId = supplierRecordTypeId;
        lstAccount.BillingStreet = 'test';
        lstAccount.BillingPostalCode = 'test';
        lstAccount.BillingState = 'California';
        lstAccount.BillingCity = 'test';
        lstAccount.BillingCountry = 'United States';
        lstAccount.Share_of_Capital__c = 'test';
        lstAccount.Type_of_company__c = 'test';
        lstAccount.Number_and_Court_of_Registration__c = 'test';
        lstAccount.Town_of_Registration__c = 'test';
        lstAccount.Chairman__c = 'test';
        lstAccount.Chairman_of_the_Board__c = 'test';
        lstAccount.Liable_Company__c = 'test';
        lstAccount.Business_Style__c = 'test';
        lstAccount.Profession__c = 'test';
        lstAccount.Tax_Regime__c = 'test';
        lstAccount.Liquidator_Name__c = 'test';
        lstAccount.Early_Payment_Discount__c = '1';
        lstAccount.Late_Payment_Penalty__c = 'test';
        lstAccount.Permit_Number__c = '1';
        lstAccount.Period_Start_Date__c = date.newInstance(2017, 3, 21);
        lstAccount.Certification_Number__c = '1';
        lstAccount.Has_Certification_Number__c = TRUE;
        lstAccount.CurrencyIsoCode = 'GBP';
        PBAcList.add(lstAccount);

        insert PBAcList;
        



        AAA_Number__c aaa = new AAA_Number__c();
        aaa.Type__c = 'Supplier';
        aaa.Account__c = acc.Id;
        aaa.Name = 'AAAAA';
        
        insert aaa;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', AAA_Number__c = aaa.Id, StageName = 'Schedule Fist Call', CloseDate = Date.today(), Account = acc, RecordTypeId = oppSupplierISRecordTypeId);
        
        Insert opp;
        
        opp.RecordTypeId = oppSupplierWFRecordTypeId;
        
        update opp;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.Add(opp);
        
        priceBookAssignmentHandler.ledgerAssignmentSupplierSalesHandler(PBAcList);

        priceBookAssignmentHandler.priceBookAssignmentSupplierSalesHandler(oppList);
        
    }
     
}