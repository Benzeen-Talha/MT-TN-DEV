/**
* @description: Utility class for enforcing relationship status transition rules.
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 09/09/16  M.Barbarelli        Created class
*/

public class RelationshipStatusController {
    
    public static string IN_SALES = 'In Sales';
    public static string LIVE  = 'Live';
    public static string RTT  = 'Ready To Transact';
    public static string BLANK = '';
    public static string ON_HOLD = 'On Hold';
	public static string IN_IMPLEMENTATION = 'In Implementation'; 
    public static string RTB = 'Refer to Buyer';
    public static string ON_STOP = 'On Stop';
    
    public static void CheckTransition(Relationship__c r, String prevStage, String newStage, Boolean isSystemEvent){
        
        Boolean IS_OBI_INTEGRATION = ((UserInfo.getUserName() == System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() == System.Label.OBI_Integration_User_UAT));
		String currentUser = UserInfo.getUserName(); 
        
        if(newStage == LIVE && !IS_OBI_INTEGRATION){
            r.Relationship_Status__c.addError('This account cannot manually be set from ' + prevStage + ' to ' + newStage + '.');
        }

        if(newStage == RTT ){
            if(!IS_OBI_INTEGRATION){
                if(prevStage != IN_IMPLEMENTATION){
                  r.Relationship_Status__c.addError('This account cannot manually be set from ' + prevStage + ' to ' + newStage + '.');  
                }
            }
        }     
        
        // IN_SALES
        // --------
        
        // TO-DO: 
        // System driven events such as the following need to be captured. 
        // Must discuss with TS. 
        // 1. Ad hoc campaign creation
        // 2. Campaign load.
      
        if(newStage == IN_SALES ){
            if(prevStage != BLANK ||
               prevStage != ON_HOLD
              ){
                r.Relationship_Status__c.addError('This account cannot manually be set from ' + prevStage + ' to ' + newStage + '.');
            }
        }
        
        if(newStage == RTB ){
            if(prevStage != IN_SALES ||
               prevStage != ON_HOLD
              ){
                r.Relationship_Status__c.addError('This account cannot manually be set from ' + prevStage + ' to ' + newStage + '.');
            }
        }  
        
        if(newStage == ON_STOP ){
            if(!IS_OBI_INTEGRATION){
                r.Relationship_Status__c.addError('This account cannot manually be set to ' + newStage + '.  This status may only be communicated from OBi.');
            }
        }            
             
    }
    
}