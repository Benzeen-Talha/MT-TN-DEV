/**
 @Name:  AccountTriggerHandlerTest
* @description: Test class for Account Trigger Handler
* 
* Change Log 
*
* Date        Author            Change Description
* -----------------------------------------------------------------------------
* 19/07/16    Rasesh Dave      Created Class  
 */
 
@isTest
private class AccountTriggerHandlerTest {

    static testMethod void testAccountInsert() {
        
           test.startTest();
            test.setMock(HttpCalloutMock.class, new MockObjects());
         
            TungstenTestDataFactory.createCustomSetting();
    
                
        Account newAccount = TungstenTestDataFactory.createSupplierAccount('Test Account');       
        insert newAccount;
        
        //Check if the integration log has been created.
        
        Integration_Log__c il = new Integration_Log__c();
        il = [Select Id, Log_type__c, Integration_Service__c From Integration_Log__c Where Account__c =: newAccount.Id];
        
        System.Debug(il);
        
        newAccount.BillingCity = 'London';
        update newAccount;
        
         Test.StopTest();
        
        
    }
}