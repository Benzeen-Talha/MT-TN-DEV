/**
* @description: Utility class for enforcing account status transition rules.
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 09/09/16  M.Barbarelli        Created class
*/


public class AccountStatusController {
    
    public static string IN_SALES = 'In Sales';
    public static string LIVE  = 'Live';
    public static string RTT  = 'Ready To Transact';
	public static string ON_HOLD  = 'On Hold';
    public static string ON_STOP = 'On Stop';
    
    public static void CheckTransition(Account a, String prevStage, String newStage, Boolean isSystemEvent){
        
        Boolean IS_OBI_INTEGRATION = ((UserInfo.getUserName() == System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() == System.Label.OBI_Integration_User_UAT));

        /*
        if(newStage == LIVE && !IS_OBI_INTEGRATION){
            a.Account_Status__c.addError('This account cannot manually be set from ' + prevStage + ' to ' + newStage + '.');
        }

        if(newStage == RTT && !IS_OBI_INTEGRATION){
            a.Account_Status__c.addError('This account cannot manually be set from ' + prevStage + ' to ' + newStage + '.');
        }     

        if((prevStage == ON_HOLD && newStage == IN_SALES) && !isOBiIntegrationUser){
            a.Account_Status__c.addError('This account cannot manually be set from ' + prevStage + ' to ' + newStage + '.');
        }           
    	*/
    }
    
}