/**
* @Name:  CampaignTriggerHandler
* @description: Trigger handler class for Campaign Object trigger
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 15/04/16    T.Sotiraki	  Created Trigger   
*/
public with sharing class CampaignTriggerHandler {


	public static void onAfterInsert(List<Campaign> campaigns){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				for(Campaign c : campaigns){
					CampaignUtil.createOBIJSONMessageRequest(c.Id, 'CampaignPost');
				}
			}
		}
		catch(Exception ex){
			System.debug('Error onAfterInsert: ' + ex.getMessage());
		}
	}

	public static void onAfterUpdate(List<Campaign> campaigns){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				for(Campaign c : campaigns){
					CampaignUtil.createOBIJSONMessageRequest(c.Id, 'CampaignPut');
				}
			}
		}
		catch(Exception ex){
			System.debug('Error onAfterUpdate: ' + ex.getMessage());
		}
	}

	public static void onBeforeDelete(List<Campaign> campaigns){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				for(Campaign c : campaigns){
					CampaignUtil.createOBIJSONMessageRequest(c.Id, 'CampaignDelete');
				}
			}
		}
		catch(Exception ex){
			System.debug('Error onBeforeDelete: ' + ex.getMessage());
		}
	}
}