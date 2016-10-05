@isTest(seeAllData=false)
private class BulkOperationsControllerTest {
    static testMethod void myUnitTest() {
        BulkOperationsController tController = new BulkOperationsController();
        System.assertEquals(BulkOperationsController.updateRelationships('RTB'), 'RTB Success');
        System.assertEquals(BulkOperationsController.updateRelationships('No Potential'), 'No Potential Success');
        System.assertEquals(BulkOperationsController.updateRelationships('On Hold'), 'On Hold Success');
        
    }
}