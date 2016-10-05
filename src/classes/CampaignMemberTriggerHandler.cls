/**
* @description: Trigger Handler class for Campaign member Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 18/04/16  T.Sotiraki        Created class
*/
public with sharing class CampaignMemberTriggerHandler {
	
	public static void onAfterInsert(List<CampaignMember> members){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				for(CampaignMember cm : members){
					CampaignMemberUtil.createOBIJSONMessageRequest(cm.Id, 'CampaignMemberPost');
				}
			}
		}
		catch(Exception ex){
			System.debug('Error onAfterInsert: ' + ex.getMessage());
		}
	}

	/*public static void onAfterUpdate(List<CampaignMember> members){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				for(CampaignMember cm : members){
					ContactUtil.createOBIJSONMessageRequest(c.Id, 'ContactPost');
				}
		}
		catch(Exception ex){
			System.debug('Error onAfterUpdate: ' + ex.getMessage());
		}
	}*/

	public static void onBeforeDelete(List<CampaignMember> members){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				for(CampaignMember cm : members){
					CampaignMemberUtil.createOBIJSONMessageRequest(cm.Id, 'CampaignMemberDelete');
				}
			}
		}
		catch(Exception ex){
			System.debug('Error onBeforeDelete: ' + ex.getMessage());
		}
	}
}