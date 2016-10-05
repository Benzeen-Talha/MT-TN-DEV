@isTest
private class AAANumberTriggerTEST {

    static testMethod void myUnitTest() {
        
           test.startTest();
            test.setMock(HttpCalloutMock.class, new MockObjects());
          
            TungstenTestDataFactory.createCustomSetting();
            TungstenTestDataFactory.createPricebookentry();

        
        AAA_Number__c aaa1 = new AAA_Number__c();
        aaa1.Name = 'AAAAA';
        aaa1.Type__c = 'Buyer';
        
                
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Invoice_Value__c = 999;
        acc.Invoice_Volume__c = 999;
        acc.Vendor_Code__c = '999';
        acc.Vat_Registration_Number__c = '888';
        
        insert acc;
        
        aaa1.Account__c = acc.Id;
        
        Insert aaa1;
        
          Test.StopTest();
    }
}