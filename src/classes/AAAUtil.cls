public with sharing class AAAUtil {
	
	   public static void createOBIJSONMessageRequest(Id aaaID, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        AAA_Number__c a = new AAA_Number__c();

        a = [Select Id, Name, Account__r.OBI_Entity_ID__c, Admin_Office__c, Admin_Office_OBI_Value__c, 
        			Service_Type__c, Type__c, Account_Type_OBI_Value__c, OBI_Account_ID__c
             From AAA_Number__c
             Where Id = :aaaID];

        
        if(a != null){
            
     		// Create a JSON generator object
	        JSONGenerator gen = JSON.createGenerator(true);

	        gen.writeStartObject();
		       gen.writeNumberField('accounttype', a.Account_Type_OBI_Value__c);
		       gen.writeNumberField('adminoffice', a.Admin_Office_OBI_Value__c);
		       gen.writeNumberField('entityid', Integer.valueOf(a.Account__r.OBI_Entity_ID__c));
		       gen.writeStringField('salesforceid', a.Id);
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
        iL.AAA_Number__c = a.Id;
        il.Request_Type__c = 'AAA Insert';

        insert il;

        if(settingInstance == 'AAAPost'){
            sendRequest(body,String.valueOf(il.Id), settingInstance);
        } 
    }

    @future(callout=true)
    public static void sendRequest(String req, String logId, String settingInstance){


        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();
        
        String endpoint = obi.Endpoint__c;
        
        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(runningUser.Email));
        
        r.setEndpoint(endpoint);
        r.setHeader('Authorization', obi.Authorisation__c);
        r.setHeader('Content-Type', obi.Content_Type__c);
        r.setMethod(obi.Method__c);
        r.setHeader('external-request-identifier', logId);
        r.setBody(req);
        r.setTimeout(60000);

        ////////////////////////////////
        ///HTTP Response
        ////////////////////////////////
        HTTP h = new HTTP();

        HTTPResponse resp = new HttpResponse();
        if(!Test.isRunningTest())
        {resp = h.send(r);}

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