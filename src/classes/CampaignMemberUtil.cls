/**
* @description: Utilities class for Campaign member Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 18/04/16  T.Sotiraki        Created class
*/
public with sharing class CampaignMemberUtil {
	

	/**
	 * [createOBIJSONMessageRequest description]
	 * @param  contact       [Contact record to process]
	 * @param  method 		 [description]
	 * @return void		     [void]
	 */
	
	public static void createOBIJSONMessageRequest(Id memberId, String settingInstance){
		
		HttpRequest req;
		String result = '';
		
		CampaignMember cm = new CampaignMember();

		cm = [Select Id, Name, CampaignId, ContactId, Campaign.Owner.Email, Campaign.Buyer_Account__c
			 From CampaignMember
			 Where Id = :memberId];

		if(cm != null){
			// Create a JSON generator object
	        JSONGenerator gen = JSON.createGenerator(true);
	        	
	        Contact c = [Select Id, AccountID
	        			From Contact
	        			Where Id = :cm.ContactId];

	        AAA_Number__c aaa = new AAA_Number__c();

	        aaa = [Select Id, Name, Account__c, OBI_Account_ID__c, Service_Type__c, Type__c
	        	   From AAA_Number__c
	        	   Where Account__c = : cm.Campaign.Buyer_Account__c
	        	   And Type__c = 'Buyer'];

	        gen.writeStartObject();
		        gen.writeStringField('campaignsalesforceid', TungstenUtil.GetStringValue(cm.CampaignId));
		        gen.writeStringField('buyeraaa',  TungstenUtil.GetStringValue(aaa.Name));
		        gen.writeStringField('userId',  TungstenUtil.GetStringValue(cm.Campaign.Owner.Email));
		        gen.writeStringField('salesforceid', TungstenUtil.GetStringValue(cm.Id));
		      
	        gen.writeEndObject();
	       
	           result = gen.getAsString();
		}

		
        
        /////////////////////////////////
        ///Message Body
        /////////////////////////////////
        String body = result;

        

		///////////////////////////////
		///Create Log
		///////////////////////////////
		
		Integration_Log__c il = new Integration_Log__c();
		il.Integration_Service__c = 'OBI';
		il.Log_Type__c = 'Request';
		il.Campaign__c = cm.CampaignId;
		il.Contact__c = cm.ContactId;

		if(settingInstance == 'CampaignMemberPost'){
			il.Request_Type__c = 'Campaign Member Insert';
		}

		if(settingInstance == 'CampaignMemberDelete'){
			il.Request_Type__c = 'Campaign Member Delete';
		}

		insert il;

		if(settingInstance == 'CampaignMemberPost'){
			sendRequest(body,String.valueOf(il.Id), String.valueOf(cm.CampaignId), settingInstance);
		} 

		if(settingInstance == 'CampaignMemberDelete'){
			sendRequest(body,String.valueOf(il.Id), String.valueOf(cm.CampaignId), settingInstance);
		} 
		
		
	}

	@future(callout=true)
	public static void sendRequest(String req, String logId, String obiCampaignId, String settingInstance){


		///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();
        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        String endpoint = obi.Endpoint__c;
        endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(runningUser.Email));
        if(settingInstance == 'CampaignMemberPost' || settingInstance == 'CampaignMemberDelete'){
        	  endpoint = endpoint.replace('{CampaignId}', obiCampaignId);
        	  
        }
        
        r.setEndpoint(endpoint);
        r.setHeader('Authorization', obi.Authorisation__c);
        r.setHeader('Content-Type', obi.Content_Type__c);
        r.setMethod(obi.Method__c);
        r.setHeader('external-request-identifier', logId);
        r.setBody(req);
        r.setTimeout(60000);

        System.debug(r.getHeader('Content-Type'));
        System.debug(r.getHeader('Authorization'));
        System.debug(r.getHeader('external-request-identifier'));
        System.debug(r.getEndpoint());

		////////////////////////////////
        ///HTTP Response
        ////////////////////////////////
        HTTP h = new HTTP();

        HTTPResponse resp = h.send(r);

        System.debug(resp.getBody());
        System.debug(resp.getStatus());


        if(logId != null){
        	Integration_Log__c log = new Integration_Log__c();

        	log = [Select Id, Response_Body__c, Response_Status__c, Response_Status_Code__c, Header__c, Request__c
        		   From Integration_Log__c
        		   Where Id = :logId];

        	log.Response_Body__c = String.valueOf(resp.getBody());
	        log.Response_Status__c = resp.getStatus();
	        log.Response_Status_Code__c = String.valueOf(resp.getStatusCode());

	        log.Header__c = r.toString();
			log.Request__c = r.getBody();
	        update log;
        }


        
	}
}