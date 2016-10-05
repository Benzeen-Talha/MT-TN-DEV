public with sharing class NoteUtil {
	
	/**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void createOBIJSONMessageRequest(Id oppId, String obiSaleId, String content, String settingInstance){
        
        HttpRequest req;
        String result = '';

        // Create a JSON generator object
        JSONGenerator gen = JSON.createGenerator(true);
                
        gen.writeStartObject();
                gen.writeStringField('note', TungstenUtil.GetStringValue(content));
                gen.writeNumberField('type', 3);
                gen.writeNumberField('visibility', 1);
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
        il.Opportunity__c = oppId;
        il.Request_Type__c= 'Opportunity Note';

        insert il;

        sendRequest(body,String.valueOf(il.Id), settingInstance, obiSaleId);
        
        
    }

    @future(callout=true)
    public static void sendRequest(String req, String logId, String settingInstance, String oppId){


        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();

        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];
        
        String endpoint = obi.Endpoint__c;

        endpoint = endpoint.replace('{userId}', TungstenUtil.GetStringValue(runningUser.Email));
        endpoint = endpoint.replace('{saleId}', TungstenUtil.GetStringValue(oppId));

        r.setEndpoint(endpoint);
        r.setHeader('Authorization', obi.Authorisation__c);
        r.setHeader('Content-Type', obi.Content_Type__c);
        r.setMethod(obi.Method__c);
        r.setHeader('external-request-identifier', logId);
        r.setBody(req);


        ////////////////////////////////
        ///HTTP Response
        ////////////////////////////////
        HTTP h = new HTTP();
        HTTPResponse resp = new HttpResponse();
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