/**
* @Name:  CampaignUtil
* @description: Utilities class for Campaign Object 
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 15/04/16    T.Sotiraki      Created Class   
*/
public with sharing class CampaignUtil {
    
    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void createOBIJSONMessageRequest(Id campaignId, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        Campaign c = new Campaign();

        c = [Select Id, Name, Buyer_Account__c, OBI_Object_ID__c
             From Campaign
             Where Id = :campaignId];

        
        
        if(c != null){
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
                gen.writeStringField('name', TungstenUtil.GetStringValue(c.Name));
                gen.writeStringField('buyerentitysalesforceid', TungstenUtil.GetStringValue(c.Buyer_Account__c));
                gen.writeNumberField('type', 1);
                gen.writestringfield('SalesforceId', TungstenUtil.GetStringValue(c.Id));
            gen.writeEndObject();
           
            result = gen.getAsString();

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
            il.campaign__c = c.Id;

            if(settingInstance == 'CampaignPost'){
                il.Request_Type__c = 'Campaign Insert';
            }
            if(settingInstance == 'CampaignPut'){
                il.Request_Type__c = 'Campaign Update';
            }
            if(settingInstance == 'CampaignDelete'){
                il.Request_Type__c = 'Campaign Delete';
            }
    
            insert il;
    
            if(settingInstance == 'CampaignPost' || settingInstance == 'CampaignPut'){
                sendRequest(body,String.valueOf(il.Id), TungstenUtil.GetStringValue(c.OBI_Object_ID__c), settingInstance);
            } 

            if(settingInstance == 'CampaignDelete'){
                sendRequest(body,String.valueOf(il.Id), TungstenUtil.GetStringValue(c.OBI_Object_ID__c), settingInstance);
            } 
        
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
        
        endpoint = endpoint.replace('{userId}', TungstenUtil.GetStringValue(runningUser.Email));
        if(settingInstance == 'CampaignPut' || settingInstance == 'CampaignDelete' ){
              endpoint = endpoint.replace('{campaignId}', obiCampaignId);
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

        HttpResponse resp = new HttpResponse();
		
		if(!test.isRunningTest())
        {resp = h.send(r);}

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