/**
@Name:  AddressUtilTest
* @description: Test class for Address Util methods. 
* 
* Change Log 
*
* Date        Author            Change Description
* -----------------------------------------------------------------------------
* 20/07/16    Rasesh Dave      Created Class   
*/

@isTest
private class AddressUtilTest {

    static testMethod void testStateLookup() {
        
        string stateCode = AddressUtil.US_StateLookup('KS');
        
        System.AssertEquals(statecode, 'Kansas');
        
    }
}