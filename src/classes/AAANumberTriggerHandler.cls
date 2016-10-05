public with sharing class AAANumberTriggerHandler {
	


	public static void onAfterInsert(List<AAA_Number__c> numbers){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				for(AAA_Number__c a : numbers){
				
					if(a.Name == 'AAAAA'){
						AAAUtil.createOBIJSONMessageRequest(a.Id, 'AAAPost');
					}
				}
			}
		}
		catch(Exception ex){
			System.debug('Error onAfterInsert: ' + ex.getMessage());
		}
	}
}