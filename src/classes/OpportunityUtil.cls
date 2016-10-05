public with sharing class OpportunityUtil {
    public OpportunityUtil() {
        
    }

    public static void createCTALinkMessageRequest(Id opportunityId, String settingInstance){
        
        HttpRequest req;
        String result = '';
        Contact primaryContact = new Contact();

        Opportunity o = new Opportunity();

        o = [Select Id, StageName, OBI_Sale_Id__c, Owner.Email
             From Opportunity
             Where Id = :opportunityId];


         
        if(o != null){

            primaryContact = [select Id, Email, OBI_Contact_Id__c from Contact where Id IN (select contactId from OpportunityContactRole where OpportunityId =: o.Id and IsPrimary = true)];


            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
                
            gen.writeStartObject();
                gen.writeStringField('email', TungstenUtil.GetStringValue(primaryContact.Email));
                gen.writeStringField('language', 'en');
                gen.writeNumberField('saleid', o.OBI_Sale_Id__c);
                gen.writeStringField('userId', TungstenUtil.GetStringValue(o.Owner.Email));
                gen.writeStringField('salesforceid', TungstenUtil.GetStringValue(o.Id));
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
        il.Opportunity__c = o.Id;
        il.Contact__c = primaryContact.Id;
        il.Request_Type__c = 'Opportunity Click To Accept Link';
        insert il;

        if(settingInstance == 'CTALinkPost'){
            sendRequest2(body,String.valueOf(il.Id), String.valueOf(o.OBI_Sale_Id__c), 'CTALinkPost');
        }
        
        
    }

    

    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void createOBIReleaseToImplementationMessageRequest(Id opportunityId, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        Opportunity o = new Opportunity();

        o = [Select Id, StageName, OBI_Sale_Id__c, Supplier_Readiness_Notes__c
             From Opportunity
             Where Id = :opportunityId];

        if(o != null){
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
                
            gen.writeStartObject();
                gen.writeNumberField('saleid', o.OBI_Sale_Id__c);
                gen.writeStringField('notes', TungstenUtil.GetStringValue(o.Supplier_Readiness_Notes__c));
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
        il.Opportunity__c = o.Id;
        il.Request_Type__c = 'Release To Implementation';
        insert il;

        if(settingInstance == 'ReleaseToImplementationPost'){
            sendRequest2(body,String.valueOf(il.Id), '', 'ReleaseToImplementationPost');
        }
        
        
    }

    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void createOBISaleMessageRequest(Id opportunityId, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        Opportunity o = new Opportunity();

        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        o = [Select Id, StageName, OBI_Sale_Id__c, Owner.Email, Account.OBI_Entity_Id__c, 
                    AAA_Number__r.Account__r.OBI_Entity_Id__c, AAA_Number__r.OBI_Account_ID__c
             From Opportunity
             Where Id = :opportunityId];

        if(o != null && settingInstance == 'OpportunityPost'){
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
                
            gen.writeStartObject();
                //gen.writeStringField('ownerid', TungstenUtil.GetStringValue(o.Owner.Email));
                gen.writeStringField('ownerid', TungstenUtil.GetStringValue(runningUser.Email));
                gen.writeNumberField('status', 2);
                gen.writeNumberField('accountid', Integer.valueOf(o.AAA_Number__r.OBI_Account_ID__c));
                gen.writeStringField('userId', TungstenUtil.GetStringValue(runningUser.Email));
                gen.writeStringField('salesforceid', TungstenUtil.GetStringValue(o.Id));
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
        il.Opportunity__c = o.Id;
        il.Request_Type__c = 'Opportunity Insert';
        
        insert il;

        if(settingInstance == 'OpportunityPost'){
            sendRequest2(body,String.valueOf(il.Id), String.valueOf(o.OBI_Sale_Id__c), 'OpportunityPost');
        }
        
        
    }

    @future(callout=true)
    public static void sendRequest2(String req, String logId, String oppId, String settingInstance){


        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();
        
        String endpoint = obi.Endpoint__c;
        
        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(runningUser.Email));
        
        
        if(oppId != null && (settingInstance == 'CreateWebFormLinkPost')){
            endpoint = endpoint.replace('{SaleId}', oppId);
        }
        if(oppId != null && (settingInstance == 'CTALinkPost')){
            endpoint = endpoint.replace('{saleId}', oppId);
            endpoint = endpoint.replace('{userId}', TungstenUtil.GetStringValue(runningUser.Email));
        }
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
        HttpResponse resp = new HttpResponse();
        if(!test.isRunningTest())
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

     /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void createWebFormLinkMessageRequest(Id opportunityId, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        Opportunity o = new Opportunity();

        o = [Select Id, StageName, OBI_Sale_Id__c
             From Opportunity
             Where Id = :opportunityId];

        if(o != null){
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
                
            gen.writeStartObject();
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
        il.Opportunity__c = o.Id;
        il.Request_Type__c = 'Opportunity Create Web Form Link';
        insert il;

        if(settingInstance == 'CreateWebFormLinkPost'){
            sendRequest2(body,String.valueOf(il.Id), String.valueOf(o.OBI_Sale_Id__c), 'CreateWebFormLinkPost');
        }
        
        
    }

    public static void UpdateCommercialInfo(Id opportunityId){
        
        Opportunity o = new Opportunity();
        String result = '';

        o = [Select Id, StageName, OBI_Sale_Id__c, Payment_Methods_OBI_Value__c, AAA_Number__c, 
                    Payment_Terms_OBI_Value__c, Account.OBI_Entity_Id__c, AAA_Number__r.OBI_Account_ID__c
             From Opportunity
             Where Id = :opportunityId];

        if(o != null){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('paymentmethod', TungstenUtil.GetIntegerValue(Integer.valueOf(o.Payment_Methods_OBI_Value__c)));
            gen.writeNumberField('paymentterms', TungstenUtil.GetIntegerValue(Integer.valueOf(o.Payment_Terms_OBI_Value__c)));
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
        il.Opportunity__c = o.Id;
        il.Request_Type__c = 'Opportunity Update Commercial Info';

        insert il;

        SendRequestCommercialInfo(body, String.valueOf(il.Id), o.AAA_Number__r.OBI_Account_ID__c);

    }

    public static void UpdatePrimaryContact(Id opportunityId){
        

        List<OpportunityContactRole> roles = new List<OpportunityContactRole>();
        String result = '';

        Opportunity o = new Opportunity();

       
        o = [Select Id, StageName, OBI_Sale_Id__c, Owner.Email, Account.OBI_Entity_Id__c, 
                    AAA_Number__r.Account__r.OBI_Entity_Id__c, AAA_Number__r.OBI_Account_ID__c
             From Opportunity
             Where Id = :opportunityId];

        roles = [Select Id, OpportunityId, ContactId, IsPrimary, Role, Contact.OBI_Contact_Id__c
                 From OpportunityContactRole
                 Where OpportunityId = :opportunityId];

        if(roles != null){

            for(OpportunityContactRole ocr : roles){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('contacttype');
                gen.writeStartArray();
                if(ocr.Role == 'Sales'){
                    gen.writeNumber(2);
                }
                if(ocr.Role == 'Billing'){
                    gen.writeNumber(4);
                }
                if(ocr.Role == 'Technical'){
                    gen.writeNumber(3);
                }
                gen.writeEndArray();
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
                il.Opportunity__c = opportunityId;
                il.Request_Type__c = 'Opportunity Contact Role';

                insert il;

                SendPrimaryContact(body, String.valueOf(il.Id), o.AAA_Number__r.OBI_Account_ID__c, ocr.Contact.OBI_Contact_Id__c);

            
            }
        }

    }

    @future(callout=true)
    public static void SendRequestCommercialInfo(String req, String logId, String accountId){
        
        
        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance('CommercialInfoPut');

        HTTPRequest r = new HTTPRequest();
        
        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        String endpoint = obi.Endpoint__c;
        endpoint = endpoint.replace('{userId}', TungstenUtil.GetStringValue(runningUser.Email));     
        endpoint = endpoint.replace('{accountId}', accountId);

        r.setEndpoint(endpoint);
        r.setHeader('Authorization', obi.Authorisation__c);
        r.setHeader('Content-Type', obi.Content_Type__c);
        r.setMethod(obi.Method__c);
        r.setHeader('external-request-identifier', logId);
        r.setBody(req);

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


    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void createOBITariffUpdate(Id opportunityId, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        Opportunity o = new Opportunity();

        o = [Select Id, StageName, OBI_Sale_Id__c, AAA_Number__c, CurrencyIsoCode, Campaign_Type__c, 
                    Pricebook_Name__c, AAA_Number__r.Name
             From Opportunity
             Where Id = :opportunityId];

        OpportunityLineItem oli = new OpportunityLineItem();

        oli = [SELECT Archive_per_Invoice_per_month_Custom__c,
                    Band_A_Custom__c,
                    Band_B_Custom__c,
                    Band_C_Custom__c,
                    Band_D_Custom__c,
                    Band_E_Custom__c,
                    Band_A_Standard__c,
                    Band_B_Standard__c,
                    Band_C_Standard__c,
                    Band_D_Standard__c,
                    Band_E_Standard__c,
                    Buyer_Connection_Per_Buyer_Custom__c,
                    CurrencyIsoCode,
                    Default_Pricing__c,
                    Id,
                    Included_Transactions_Custom__c,
                    ListPrice,
                    Name,
                    OpportunityId,
                    Per_Remap_Custom__c,
                    PricebookEntryId,
                    Product2Id,
                    ProductCode,
                    TotalPrice,
                    UnitPrice,
                    Veteran_Association__c 
                    From OpportunityLineItem 
                    Where OpportunityId = :opportunityId
                    Limit 1];

        if(o != null){
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
                
            if(oli.Default_Pricing__c == true){
                gen.writeStartObject();
                gen.writeStringField('supplieraaano', o.AAA_Number__r.Name);
                gen.writeEndObject();
            }else{

                if(o.Campaign_Type__c == 'Integrated Solution'){
                    gen.writeStartObject();
                    gen.writeStringField('supplieraaano', o.AAA_Number__r.Name);
                    gen.writeStringField('currencycode', o.CurrencyIsoCode);
                    gen.writeNumberField('packagetype', 1);
                        
                    gen.writeFieldName('tariffs');
                    gen.writeStartArray();
                        gen.writeStartObject();
                        gen.writeNumberField('tarifftype', 1);
                        gen.writeNumberField('value', 0.0);
                        gen.writeNumberField('frequency', 0);
                        gen.writeFieldName('tariffbands');
                            gen.writeStartArray();
                            gen.writeStartObject();
                            gen.writeNumberField('limitto', 0);
                            gen.writeStringField('band', 'A');
                            if(oli.Band_A_Custom__c != null){
                                gen.writeNumberField('price', oli.Band_A_Custom__c);
                            }else{
                                gen.writeNumberField('price', oli.Band_A_Standard__c);
                            }
                            
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeNumberField('limitto', 0);
                            gen.writeStringField('band', 'B');
                            if(oli.Band_B_Custom__c != null){
                                gen.writeNumberField('price', oli.Band_B_Custom__c);
                            }else{
                                gen.writeNumberField('price', oli.Band_B_Standard__c);
                            }
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeNumberField('limitto', 0);
                            gen.writeStringField('band', 'C');
                            if(oli.Band_C_Custom__c != null){
                                gen.writeNumberField('price', oli.Band_C_Custom__c);
                            }else{
                                gen.writeNumberField('price', oli.Band_C_Standard__c);
                            }
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeNumberField('limitto', 0);
                            gen.writeStringField('band', 'D');
                            if(oli.Band_D_Custom__c != null){
                                gen.writeNumberField('price', oli.Band_D_Custom__c);
                            }else{
                                gen.writeNumberField('price', oli.Band_D_Standard__c);
                            }
                            gen.writeEndObject();
                            gen.writeStartObject();
                            gen.writeNumberField('limitto', 0);
                            gen.writeStringField('band', 'E');
                            if(oli.Band_E_Custom__c != null){
                                gen.writeNumberField('price', oli.Band_E_Custom__c);
                            }else{
                                gen.writeNumberField('price', oli.Band_E_Standard__c);
                            }
                            gen.writeEndObject();
                            gen.writeEndArray();
                        gen.writeNumberField('tariffmethod', 1);
                        gen.writeEndObject();
                    gen.writeEndArray();


                    gen.writeEndObject();
                }

                if(o.Campaign_Type__c == 'Web Form'){
                    gen.writeStartObject();
                    gen.writeStringField('supplieraaano', o.AAA_Number__r.Name);
                    gen.writeStringField('currencycode', o.CurrencyIsoCode);
                    gen.writeNumberField('packagetype', 2);
                    
                    gen.writeFieldName('tariffs');
                    gen.writeStartArray();
                        gen.writeStartObject();
                        gen.writeNumberField('tariffid', 0);
                        gen.writeNumberField('tarifftype', 4);
                        gen.writeNumberField('value', 0.0);
                        gen.writeNumberField('frequency', 0);
                        gen.writeFieldName('tariffbands');
                            gen.writeStartArray();
                            gen.writeStartObject();
                            gen.writeNumberField('limitto', 0);
                            gen.writeStringField('band', 'A');
                            gen.writeNumberField('price', 0);
                            gen.writeEndObject();
                            gen.writeEndArray();
                        gen.writeNumberField('tariffmethod', 2);
                        gen.writeEndObject();
                    gen.writeEndArray();

                    gen.writeEndObject();
                }
                
            }
            
           
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
        il.Opportunity__c = o.Id;
        il.Request_Type__c = 'Opportunity Select Tariff';
        insert il;

        if(oli.Default_Pricing__c == true){
            SendTariff(body,String.valueOf(il.Id), o.Id, true, o.Pricebook_Name__c);
        }else{
            SendTariff(body,String.valueOf(il.Id), o.Id, false, o.Pricebook_Name__c);
        }
        
     
        
        
    }

    @future(callout=true)
    public static void SendTariff(String req, String logId, String oppId, Boolean defaultPricing, String pricebookName){
        
        
        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance('TariffPost');

        HTTPRequest r = new HTTPRequest();
        

        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        String endpoint = obi.Endpoint__c;
        endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(runningUser.Email));     
        
        if(defaultPricing == true){
            endpoint = endpoint.replace('{PricebookName}', pricebookName);
            r.setMethod('PUT');
        }else{
            endpoint = endpoint.replace('{PricebookName}', '');
            r.setMethod('POST');
        }
        


        r.setEndpoint(endpoint);
        r.setHeader('Authorization', obi.Authorisation__c);
        r.setHeader('Content-Type', obi.Content_Type__c);

        r.setHeader('external-request-identifier', logId);
        r.setBody(req);

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



    public static string GetStringValue(String str){
        return (str == null ) ? '' : str; 
    }


    /**
     * [hasFirstCallTaskBeenCompleted description]
     * @param opportunities [description]
     */
    public static void hasFirstCallTaskBeenCompleted(List<Opportunity> opportunities){
        
        Boolean result = false;

        if(opportunities.size() > 0){
            Set<Id> opportunityIds = new Set<Id>();

            for(Opportunity o : opportunities){
                opportunityIds.add(o.Id);
            }

            List<Task> firstCallTasks = new List<Task>();

            firstCallTasks = [Select Id, IsClosed, Description, Status, Subject, WhatId
                              From Task
                              Where WhatId in :opportunityIds
                              And Subject = 'First Call'];

            if(firstCallTasks.size() > 0){
                Map<Opportunity, Task> opportunityToTaskMap = new Map<Opportunity, Task>();

                for(Opportunity o : opportunities){
                    for(Task t : firstCallTasks){
                        if(o.Id == t.WhatId){
                            opportunityToTaskMap.put(o, t);
                        }
                    }
                }

                for(Opportunity o : opportunityToTaskMap.keySet()){
                    Task t = opportunityToTaskMap.get(o);

                    if(t.Status == 'Open'){
                        o.addError('Please close the First Call Task before progressing to the next stage');
                    }
                }


            }
        }

     
    }

    /**
     * [hasEngagedTaskBeenCompleted description]
     * @param opportunities [description]
     */
    public static void hasEngagedTaskBeenCompleted(List<Opportunity> opportunities){
        
        Boolean result = false;

        if(opportunities.size() > 0){
            Set<Id> opportunityIds = new Set<Id>();

            for(Opportunity o : opportunities){
                opportunityIds.add(o.Id);
            }

            List<Task> engagedTasks = new List<Task>();

            engagedTasks = [Select Id, IsClosed, Description, Status, Subject, WhatId
                              From Task
                              Where WhatId in :opportunityIds
                              And Subject = 'Engaged'];

            if(engagedTasks.size() > 0){
                Map<Opportunity, Task> opportunityToTaskMap = new Map<Opportunity, Task>();

                for(Opportunity o : opportunities){
                    for(Task t : engagedTasks){
                        if(o.Id == t.WhatId){
                            opportunityToTaskMap.put(o, t);
                        }
                    }
                }

                for(Opportunity o : opportunityToTaskMap.keySet()){
                    Task t = opportunityToTaskMap.get(o);

                    if(t.Status == 'Open'){
                        o.addError('Please close the Engaged Task before progressing to the next stage');
                    }
                }


            }
        }

     
    }


    public static void StageChangeHandler (List <Opportunity> opps){
    
        List <ID> oppIDs = new list <ID>();
        
        for(Opportunity opp : opps){
        
            oppIDs.add(opp.Id);
        
        }
        
        Boolean roleFoundSales = FALSE;
        Boolean roleFoundBilling = FALSE;
        Boolean roleFoundTech = FALSE;
        Boolean productFound = false;
        Boolean primaryRoleFound = true;
        
        system.debug('in stage chagne hanlder');
        
        List <OpportunityContactRole> oppConRoles = [SELECT Id, Role, ContactId, IsPrimary, OpportunityId FROM OpportunityContactRole WHERE OpportunityId in: oppIDs];
       	
        //If there are Contact role, then atleast one has to be set as Primary contact role.
        if(oppconRoles.size() > 0)
        {primaryRolefound = false;}
        
        system.debug('oppConRoles size = ' + oppConRoles.size());
        
        for(Opportunity opp : opps){
        
        	for(OpportunityContactRole conRole : oppConRoles){
        		
        		if(conRole.OpportunityId == opp.Id){
        			
                    if(conRole.IsPrimary)
                    {primaryRoleFound = true;}
                    
	            	if(conRole.Role == 'Sales'){
	            		
	            		roleFoundSales = TRUE;
	            		system.debug('sales role found');
	                    
	                }
	                
	                if(conRole.Role == 'Billing'){
	                
	                	roleFoundBilling = TRUE;
	            		system.debug('billing role found');
	                	
	                }
	                
	                if(conRole.Role == 'Technical'){
	                
	                	roleFoundTech = TRUE;
	            		system.debug('tech role found');
	                	
	                }
                
        		}	
        		
        	}
             	
            	
	            if(opp.StageName == 'Add contact details'){
	            	
	            	if(roleFoundSales == FALSE){
	                
	                	Opp.addError('Please enter a Sales Contact Role before changing the stage to Add Contact Details');
	                	
	            	}
	                
	            }
	                
	            if(opp.StageName == 'Send IS Registration Link'){
                    
                    if(roleFoundBilling == FALSE){
                        
                        Opp.addError('Please enter a Billing Contact Role before changing the stage to Release To Implementation');
                    
                    }
                   
                    
                }
                if(opp.StageName == 'Release to Implementation'){
	                   
	                if(roleFoundTech == FALSE){
	                	
	                	Opp.addError('Please enter a Technical Contact Role before changing the stage to Release To Implementation');
	                
	                }
	                
	            }
            
        	
                
        }
        
   }
        
      

    public static void opportunityProductCheck(List <Opportunity> opps){
    
        List <ID> oppIDs = new list <ID>();
        
        for(Opportunity opp : opps){
        
            oppIDs.add(opp.Id);
        
        }
        
        Boolean productFound = false;

        List<OpportunityLineItem> oli = [Select Id, OpportunityId
                                         From OpportunityLineItem
                                         Where OpportunityId IN :oppIDs];

       
        for(Opportunity opp : opps){
            if(oli.size() > 0){
                 for(OpportunityLineItem o : oli){
            
                    if(opp.Id == o.OpportunityId){
                    
                        productFound = TRUE;
                    }
                }
            }

            if(productFound == FALSE){
            
                opp.addError('Please select a Product before changing the stage to Terms Accepted');
                
            }
           
        }
    
    }



    public static void  updateOpportunityStage(String stage, Set<Opportunity> opps){

        if (opps.size() > 0){
            for (Opportunity o : opps){
                o.StageName = stage;                
            }
            
        }
    }
    
    public static List<Opportunity> setOpportunityOwner(List<Opportunity> oppsInScope){
		
		//Get the User record for default user
		Opportunity_Default_Owner__c defaultOwner = [Select Id, Name, User_Id__c From Opportunity_Default_Owner__c Where Name = 'Sales Integration'];
		User u = [Select Id, name, IsActive from User Where Id =: defaultOwner.User_Id__c];
		
		
		//Get a list of Account Ids associated with the Opportunities in scope
		List<Id> AccountList = new List<Id>();
		
		for(Opportunity opp : oppsInScope){
			AccountList.Add(opp.AccountId);
		}
		
		List<Account> accountTList = [Select Id, Name From Account Where Id IN: AccountList];
		
		//get all accounts for all opportunities
		map<Id, Account> accountMap = new map<Id, Account>();
		for(Account a1 : accountTList){
			accountMap.put(a1.Id, a1);
		}
		
		//get all the related opportunities for all the accounts
		map<Id, map<Id, Opportunity>> oppMapByAccounts = new map<Id, map<Id, Opportunity>>();
		for(Opportunity opp: [Select Id, Name, Owner.IsActive, Owner.Id, Owner.Name, AccountId 
									From Opportunity 
									Where Account.Id IN: accountMap.Keyset() 
									and Owner.IsActive = true])
		{
			//get the Opp map by opp.Account.id
			map<Id, Opportunity> tMap = oppMapByAccounts.get(opp.Accountid);
			//If the map is null, instantiate it
			
			if(tMap == null)
			{tMap = new map<id, Opportunity>();}
			
			//add the opp to the tMap
			tMap.put(opp.AccountId, opp);
			
			//add the tMap to the related opp by account map.
			oppMapByAccounts.put(opp.Accountid, tMap);
		}
		
		
		//iterate through all the opportunities
		for(Opportunity o : oppsInScope){
			if(o.Type_of_Campaign__c == 'Managed') 
			{
				map<id, Opportunity> oppList = oppMapByAccounts.get(o.AccountId);
				//check if there are more opportunities with active owner.
				if(oppList != null && oppList.Values().size() > 0){
					o.OwnerId = oppList.Values()[0].OwnerId;
				}
				else{ 
					//There is no active owner of any opportunities. So assign it to default.
					o.OwnerId = u.Id;
				}
			}
			
		}
		return oppsInScope;
		
	}



    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void completeTask(Id opportunityId, String taskName){
        
        HttpRequest req;
        String result = '';
        
        Opportunity o = new Opportunity();

        o = [Select Id, StageName, OBI_Sale_Id__c
             From Opportunity
             Where Id = :opportunityId];

        if(o != null){

            

            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
            
            if(taskName == 'Schedule First Call'){
                gen.writeStartObject();
                gen.writeFieldName('tasknotes');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('taskname', 'Schedule_First_Call');
                            gen.writeStringField('note', 'Schedule_First_Call notes');
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            }

            if(taskName == 'Engaged'){
                List<Task> t = new List<Task>();

                t = [Select Id, Description, Subject, WhatId, Status
                     From Task
                     Where WhatId = :o.Id
                     And Subject = 'First Call'
                     And Status = 'Completed'
                     Limit 1];
                system.debug('First Call ' + t);
                if(t.size() > 0){
                    gen.writeStartObject();
                    gen.writeFieldName('tasknotes');
                        gen.writeStartArray();
                            gen.writeStartObject();
                                gen.writeStringField('taskname', 'First_Call');
                                gen.writeStringField('note', TungstenUtil.GetStringValue(t[0].Description));
                            gen.writeEndObject();
                            gen.writeStartObject();
                                gen.writeStringField('taskname', 'Engaged');
                                gen.writeStringField('note', 'Engaged Notes');
                            gen.writeEndObject();
                        gen.writeEndArray();
                    gen.writeEndObject();
                }
                
            }

            if(taskName == 'Add Contact Details'){

                List<OpportunityContactRole> roles = new List<OpportunityContactRole>();

                roles = [Select Id, ContactId, OpportunityId, Role, IsPrimary
                         From OpportunityContactRole
                         Where OpportunityId = :opportunityId];
                if(roles.size() > 0){
                    Boolean salesExists = false;
                    Boolean technicalExists = false;
                    Boolean billingExists = false;

                    for(OpportunityContactRole ocr : roles){
                        if(ocr.Role == 'Sales'){
                            salesExists = true;
                        }
                        if(ocr.Role == 'Technical'){
                            technicalExists = true;
                        }
                        if(ocr.Role == 'Billing'){
                            billingExists = true;
                        }
                    }

                    gen.writeStartObject();
                    gen.writeFieldName('tasknotes');
                        gen.writeStartArray();
                            if(salesExists == true){
                                gen.writeStartObject();
                                    gen.writeStringField('taskname', 'Add_Primary_Sales_Contact');
                                    gen.writeStringField('note', 'Add_Primary_Sales_Contact  Notes');
                                gen.writeEndObject();
                            }
                            if(technicalExists == true){
                                gen.writeStartObject();
                                    gen.writeStringField('taskname', 'Add_Primary_Billing_Contact');
                                    gen.writeStringField('note', 'Add_Primary_Billing_Contact  Notes');
                                gen.writeEndObject();
                            }
                            if(billingExists == true){
                                gen.writeStartObject();
                                    gen.writeStringField('taskname', 'Add_Primary_Technical_Contact');
                                    gen.writeStringField('note', 'Add_Primary_Technical_Contact   Notes');
                                gen.writeEndObject();   
                            }
                             
                        gen.writeEndArray();
                    gen.writeEndObject();

                }
                
            }

            if(taskName == 'Select Tariff'){
                gen.writeStartObject();
                gen.writeFieldName('tasknotes');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('taskname', 'Select_Tariff');
                            gen.writeStringField('note', 'Select_Tariff Notes');
                        gen.writeEndObject();
                        gen.writeStartObject();
                            gen.writeStringField('taskname', 'Select_Terms');
                            gen.writeStringField('note', 'Select_Terms Notes');
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            }

            if(taskName == 'Terms Accepted'){
                gen.writeStartObject();
                gen.writeFieldName('tasknotes');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('taskname', 'Terms_Accepted');
                            gen.writeStringField('note', 'Terms_Accepted Notes');
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            }

            if(taskName == 'Send Portal Registration Link'){
                gen.writeStartObject();
                gen.writeFieldName('tasknotes');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('taskname', 'Send_Portal_Registration_Link');
                            gen.writeStringField('note', 'Send Portal Registration Link Notes');
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            }

            if(taskName == 'Send Confirmation Email'){
                gen.writeStartObject();
                gen.writeFieldName('tasknotes');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('taskname', 'Send_Confirmation_Email');
                            gen.writeStringField('note', 'Send Confirmation Email Notes');
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            }
            
            if(taskName == 'Release To Implementation'){
                gen.writeStartObject();
                gen.writeFieldName('tasknotes');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('taskname', 'Release_to_Implementation');
                            gen.writeStringField('note', 'Release To Implementation Notes');
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            }
            
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
        il.Opportunity__c = o.Id;

        if(taskName == 'Schedule First Call'){
            il.Request_Type__c = 'Opportunity Schedule First Call';
        }
        /*if(taskName == 'First Call'){
            il.Request_Type__c = 'Opportunity First Call';
        }*/

        if(taskName == 'Add Contact Details'){
            il.Request_Type__c = 'Opportunity Add Contact Details';
        }

        if(taskName == 'Engaged'){
            il.Request_Type__c = 'Opportunity Engaged';
        }

        if(taskName == 'Select Tariff'){
            il.Request_Type__c = 'Opportunity Select Tariff';
        }

        if(taskName == 'Send Confirmation Email'){
            il.Request_Type__c = 'Opportunity Send Confirmation Email';
        }

        if(taskName == 'Send Portal Registration Link'){
            il.Request_Type__c = 'Opportunity Send Portal Registration Link';
        }

        if(taskName == 'Terms Accepted'){
            il.Request_Type__c = 'Opportunity Terms Accepted';
        }

        if(taskName == 'Release To Implementation'){
            il.Request_Type__c = 'Opportunity Release To Implementation';
        }


        
        insert il;

        
     
        SendFirstCall(body, String.valueOf(il.Id), String.valueOf(o.OBI_Sale_Id__c));
        
    }


    @future(callout=true)
    public static void SendFirstCall(String req, String logId, String oppId){
        
        
        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance('CompleteTaskSalePost');

        HTTPRequest r = new HTTPRequest();

        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];
        
        String endpoint = obi.Endpoint__c;
        endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(runningUser.Email));  
        endpoint = endpoint.replace('{SaleId}', TungstenUtil.GetStringValue(oppId));     
        
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


     @future(callout=true)
    public static void SendPrimaryContact(String req, String logId, String accountId, String contactId){
        
        
        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance('PrimaryContactPost');

        HTTPRequest r = new HTTPRequest();

        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];
        
        String endpoint = obi.Endpoint__c;
        endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(runningUser.Email));  
        endpoint = endpoint.replace('{AccountId}', TungstenUtil.GetStringValue(accountId));     
        endpoint = endpoint.replace('{ContactId}', TungstenUtil.GetStringValue(contactId));  

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
        
        HttpResponse resp = new HttpResponse();
        if(!test.isRunningTest())
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


    /**
     * [newRelationships description]
     * @param relationships [description]
     */
    public static void updateOpportunityConfirmedRelationships(List<Opportunity> opportunities){

        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Relationship__c> oppRelationships = new List<Relationship__c>();
        
        for(Opportunity o : opportunities){
            opportunityIds.add(o.Id);
        } 

        if(opportunityIds.size() > 0){

            oppRelationships = [Select Id, Confirmed__c, Opportunity__c
                             From Relationship__c
                             Where Opportunity__c in : opportunityIds];

            System.debug(oppRelationships);

            for(Opportunity o : opportunities){
                List<Relationship__c> confirmedRelationships = new List<Relationship__c>();

                for(Relationship__c r : oppRelationships){
                    if(r.Confirmed__c == true){
                        confirmedRelationships.add(r);
                    }
                }

                o.Confirmed_Relationships__c = confirmedRelationships.size();

                if(o.Confirmed_Relationships__c <= 0 || o.Confirmed_Relationships__c == null){
                    o.addError('Atleast one relationship needs to be confirmed.');

                }
                
            }
            
        }       

    }



    /**
     * [newRelationships description]
     * @param relationships [description]
     */
    public static void createSalesRepOverdueScheduleFirstCallTasks(List<Opportunity> opportunities){

        Set<Opportunity> overdueOpportunities = new Set<Opportunity>();
        
        List<Task> tasksToCreate = new List<Task>();
        
        for(Opportunity o : opportunities){
            Integer dateDifference = System.today().daysBetween(Date.valueOf(o.Schedule_First_Call_Stage_Calculation__c));
            if(o.StageName == 'Schedule First Call' && dateDifference >10){
                overdueOpportunities.add(o);
            }
            
        } 

        if(overdueOpportunities.size() > 0){

            for(Opportunity o : overdueOpportunities){
                Task t = new Task();

                t.Description = 'This task has been scheduled as a reminder.';
                t.WhoId = o.OwnerId;
                t.WhatId = o.Id;
                t.Priority = 'Normal';
                t.Subject = 'You have not yet scheduled a call with a customer: ' + o.Name;
                t.Status = 'Open';

                 tasksToCreate.add(t);
            }

            if(tasksToCreate.size() > 0){
                insert tasksToCreate;
            }
            
        }       

    }

    public static void scheduleFirstCallStageStart(List<Opportunity> opportunities){
        
      if(opportunities.size() > 0){  
            for(Opportunity opt:opportunities ){
                if(opt.StageName ==  'Schedule First Call'){
                    if(opt.Schedule_First_Call_Stage_Calculation__c == null){
                        opt.Schedule_First_Call_Stage_Calculation__c = System.Now();
                    }
                }
            }
    }

    }


     public static void checkServiceType(List<Opportunity> opportunities){
        
      if(opportunities.size() > 0){  
            Id isRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supplier Sales-e-invoicing-IS').getRecordTypeId();
            Id wfRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supplier Sales-e-invoicing-WF').getRecordTypeId();
            
            for(Opportunity opt:opportunities ){

                if(opt.Campaign_Type__c ==  'Integrated Solution' && opt.RecordTypeId != isRecordTypeId){
                    opt.RecordTypeId = isRecordTypeId;
                }

                if(opt.Campaign_Type__c ==  'Web Form' && opt.RecordTypeId != wfRecordTypeId){
                    opt.RecordTypeId = wfRecordTypeId;
                }
            }
        }
    }
    
    //Stage change timestamp code. Implimented to replace workflows due to callout errors
    public static void stageChangeTimestamp(Map<Opportunity, String> oppsOldStageMap){
       
      string oldStage;
        
      if(oppsOldStageMap.size() > 0){  
            
            for(Opportunity opp : oppsOldStageMap.keyset()){
            	
            	oldStage = oppsOldStageMap.get(opp);
            	
            	if(opp.No_of_Days_in_Banker__c == null){
            		
            		opp.No_of_Days_in_Banker__c = 0;
            		
            	}
            	if(opp.No_of_Days_in_In_Sales__c == null){
            		
            		opp.No_of_Days_in_In_Sales__c = 0;
            		
            	}
            	if(opp.No_of_Days_in_Likely__c == null){
            		
            		opp.No_of_Days_in_Likely__c = 0;
            		
            	}
            	if(opp.No_of_Days_in_Progressed__c == null){
            		
            		opp.No_of_Days_in_Progressed__c = 0;
            		
            	}
            	if(opp.No_of_Days_in_SQL__c == null){
            		
            		opp.No_of_Days_in_SQL__c = 0;
            		
            	}
            	
            	
            	if(oldStage == 'Banker'){
            		
            		Date now = system.now().date();
            		Date stageChangeDate = opp.Stage_Date_Change__c.date();
            		
            		opp.No_of_Days_in_Banker__c = opp.No_of_Days_in_Banker__c + opp.Days_Since_Last_Stage_Change__c;
            		
            	}
            	
            	if(oldStage == 'In Sales'){
            		
            		Date now = system.now().date();
            		Date stageChangeDate = opp.Stage_Date_Change__c.date();
            		
            		opp.No_of_Days_in_In_Sales__c = opp.No_of_Days_in_In_Sales__c + opp.Days_Since_Last_Stage_Change__c;
            		
            	}
            	
            	if(oldStage == 'Likely'){
            		
            		Date now = system.now().date();
            		Date stageChangeDate = opp.Stage_Date_Change__c.date();
            		
            		opp.No_of_Days_in_Likely__c = opp.No_of_Days_in_Likely__c + opp.Days_Since_Last_Stage_Change__c;
            		
            	}
            	
            	if(oldStage == 'Progressed'){
            		
            		Date now = system.now().date();
            		Date stageChangeDate = opp.Stage_Date_Change__c.date();
            		
            		opp.No_of_Days_in_Progressed__c = opp.No_of_Days_in_Progressed__c + opp.Days_Since_Last_Stage_Change__c;
            		
            	}
            	
            	if(oldStage == 'SQL'){
            		
            		Date now = system.now().date();
            		Date stageChangeDate = opp.Stage_Date_Change__c.date();
            		
            		opp.No_of_Days_in_SQL__c = opp.No_of_Days_in_SQL__c + opp.Days_Since_Last_Stage_Change__c;
            		
            	}
            	
            	opp.Stage_Date_Change__c = system.now();
            	
            }
            
        }
    
    
    }

 }