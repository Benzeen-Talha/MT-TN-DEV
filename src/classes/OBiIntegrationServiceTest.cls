/**
 
 */
@isTest
private class OBiIntegrationServiceTest {

    static testMethod void myUnitTest() {
       OBiIntegrationService tClass = new OBiIntegrationService();
       
       OBiIntegrationService.HandlePost();
       Relationship__c r = new Relationship__c();
       
       map<string, Object> mList = new map<string, Object>();
       mList.put('SalesforceId', (sObject)r);
       
       OBiIntegrationService.relStatusChangeToLive(mList);
        
    }
}