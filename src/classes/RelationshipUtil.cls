/**
* @Name:  RelationshipUtil
* @description: Utilities class for Relationship Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 24/02/16    T.Sotiraki      Created Trigger   
*/
public with sharing class RelationshipUtil {
    

    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    public static void createOBIJSONMessageRequest(Relationship__c rel, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        Relationship__c re = new Relationship__c();

        re = [Select Id, Attachment_Settings__c, Authorisation_Contact_for_RTB__c, Buyer_Account__c,
                     Campaign__c, Campaign__r.Name, ePHI__c, Opportunity__c, PO_Required__c, PO_Validation__c, Relationship_Status__c, 
                     Supplier_Account__c, Vendor_Code__c, Authorisation_Contact_for_RTB__r.Email, Authorisation_Contact_for_RTB__r.FirstName,
                     Authorisation_Contact_for_RTB__r.LastName, RTB_Reason_Code__c, Additional_Notes__c, Opportunity__r.OBI_Sale_Id__c, 
                     Supplier_AAA_Number__r.Name, OBI_Status_Code__c, Supplier_AAA_Number__r.OBI_Account_ID__c, Buyer_AAA_Number__r.Name, Off_Hold_Date__c,
                     On_Hold_Reason__c, RTB_Notes__c, OBI_Relationship_Id__c, Authorisation_Contact_for_No_Potential__r.Email, 
                     Authorisation_Contact_for_No_Potential__r.LastName, Authorisation_Contact_for_No_Potential__r.FirstName, 
                     No_Potential_Reason_Code__c, OBI_No_Potential_Reason_Code__c, Campaign__r.OBI_Object_ID__c, Invoice_Value__c, Invoice_Volume__c, 
                     Authorisation_Contact_for_On_Hold__c, Authorisation_Contact_for_On_Hold_Email__c
             From Relationship__c
             Where Id = :rel.Id];

        if(re != null){
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
            
            ///////////////////////
            ///Integer Mapping
            ///////////////////////
            Integer poRequired;
            Integer attachmentSettings;
            Integer poValidation;
            
            if(re.PO_Required__c == 'Not Needed'){
                poRequired = 0;
            }
            if(re.PO_Required__c == 'Invoice only'){
                poRequired = 1;
            }
            if(re.PO_Required__c == 'Invoices & Credit Notes'){
                poRequired = 2;
            }
            if(re.PO_Validation__c == 'Range'){
                poValidation = 1;
            }
            if(re.PO_Validation__c == 'Instance'){
                poValidation = 2;
            }
            if(re.Attachment_Settings__c == 'No'){
                attachmentSettings = 0;
            }
            if(re.Attachment_Settings__c == 'Supplier will indicate'){
                attachmentSettings = 1;
            }
            if(re.Attachment_Settings__c == 'OB10 expects attachments'){
                attachmentSettings = 2;
            }

            if(settingInstance == 'RelationshipPost'){
                gen.writeStartObject();
                gen.writeFieldName('details');
                    gen.writeStartArray();
                       
                gen.writeStartObject();
                    gen.writeStringField('buyeraaa', re.Buyer_AAA_Number__r.Name);
                    gen.writeNumberField('releaseid', 0);
                    gen.writeNumberField('saleid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Opportunity__r.OBI_Sale_Id__c)));
                    gen.writeStringField('reasoncode', '0');
                    gen.writeStringField('supplieraaa', TungstenUtil.GetStringValue(re.Supplier_AAA_Number__r.Name));
                    gen.writeNumberField('campaignid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Campaign__r.OBI_Object_ID__c)));
                    gen.writeStringField('vendorcode', TungstenUtil.GetStringValue(re.Vendor_Code__c));
                    gen.writeNumberField('porequired', TungstenUtil.GetIntegerValue(poRequired));
                    gen.writeNumberField('attachmentrequired', TungstenUtil.GetIntegerValue(attachmentSettings));
                    gen.writeNumberField('povalidation', TungstenUtil.GetIntegerValue(poValidation));
                    gen.writeNumberField('status', 2);
                    gen.writeStringField('salesforceid', re.Id);
                gen.writeEndObject();
                gen.writeEndArray();
                gen.writeEndObject();
            }

            if(settingInstance == 'CampaignRelationshipPost'){
                gen.writeStartObject();
                gen.writeFieldName('details');
                    gen.writeStartArray();

                gen.writeStartObject();
                    gen.writeStringField('salesforceid', re.Id);
                    gen.writeNumberField('status', TungstenUtil.GetIntegerValue(Integer.valueOf(re.OBI_Status_Code__c)));
                    gen.writeStringField('supplieraaa', TungstenUtil.GetStringValue(re.Supplier_AAA_Number__r.Name));
                    gen.writeNumberField('saleid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Opportunity__r.OBI_Sale_Id__c)));
                    gen.writeNumberField('volume', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Invoice_Volume__c)));
                    gen.writeNumberField('value', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Invoice_Value__c)));
                gen.writeEndObject();

                gen.writeEndArray();
                gen.writeEndObject();
            }



            if(settingInstance == 'RTBPost'){
                gen.writeStartObject();
                    gen.writeStringField('reasonCode', re.RTB_Reason_Code__c.left(6));
                    gen.writeStringField('email', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_RTB__r.Email) );
                    gen.writeStringField('firstName', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_RTB__r.FirstName));
                    gen.writeStringField('lastName', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_RTB__r.LastName));
                    gen.writeStringField('note', TungstenUtil.GetStringValue(re.RTB_Notes__c));
                gen.writeEndObject();
            }

            if(settingInstance == 'RelationshipPut'){
                gen.writeStartObject();
                    gen.writeStringField('vendorcode', TungstenUtil.GetStringValue(re.Vendor_Code__c));
                    gen.writeNumberField('porequired', TungstenUtil.GetIntegerValue(poRequired));
                    gen.writeNumberField('attachmentrequired', TungstenUtil.GetIntegerValue(attachmentSettings));
                    gen.writeNumberField('povalidation', TungstenUtil.GetIntegerValue(poValidation));
                    gen.writeNumberField('status', 2);
                gen.writeEndObject();
            }

            if(settingInstance == 'OnHoldPost'){
                 gen.writeStartObject();
                    gen.writeFieldName('details');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('offHoldDate', String.valueOf(re.Off_Hold_Date__c));
                            gen.writeStringField('note', TungstenUtil.GetStringValue(re.On_Hold_Reason__c));
                            gen.writeStringField('reasonCode', 'HLD001'); //this is the only reason code available at the moment, so this is fixed
                            gen.writeStringField('email', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_On_Hold_Email__c)); //supplier contact email
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            }

            if(settingInstance == 'OffHoldPost'){
                gen.writeStartObject();
                    gen.writeStringField('note', 'sample note');
                gen.writeEndObject();
            }

            if(settingInstance == 'NoPotentialPost'){
                 gen.writeStartObject();
                    gen.writeFieldName('details');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('reasonCode', TungstenUtil.GetStringValue(re.OBI_No_Potential_Reason_Code__c));
                            gen.writeStringField('note', 'sample note');
                            gen.writeStringField('email', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_No_Potential__r.Email));
                            gen.writeStringField('firstName', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_No_Potential__r.FirstName));
                            gen.writeStringField('LastName', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_No_Potential__r.LastName));
                            gen.writeNumberField('saleid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Opportunity__r.OBI_Sale_Id__c)));
                            gen.writeStringField('campaignsalesforceid', TungstenUtil.GetStringValue(re.Campaign__c));
                            gen.writeStringField('userId', TungstenUtil.GetStringValue(runningUser.Email));
                            gen.writeStringField('salesforceid', TungstenUtil.GetStringValue(re.Id));
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            }
            
            result = gen.getAsString();
        }

        String body = result;
        
        ///////////////////////////////
        ///Create Log
        ///////////////////////////////
        
        Integration_Log__c il = new Integration_Log__c();
        il.Integration_Service__c = 'OBI';
        il.Log_Type__c = 'Request';
        il.Relationship__c = re.Id;
        il.Opportunity__c = re.Opportunity__c;
        il.Campaign__c = re.Campaign__c;

        if(settingInstance == 'RelationshipPost'){
            il.Request_Type__c = 'Relationship Insert';
        }

        if(settingInstance == 'RelationshipPut'){
            il.Request_Type__c = 'Relationship Update';
        }

        if(settingInstance == 'CampaignRelationshipPost'){
            il.Request_Type__c = 'Campaign Relationship Insert';
        }

        if(settingInstance == 'OffHoldPost'){
            il.Request_Type__c = 'Relationship Off Hold';
        }

        if(settingInstance == 'OnHoldPost'){
            il.Request_Type__c = 'Relationship On Hold';
        }

        if(settingInstance == 'RTBPost'){
            il.Request_Type__c = 'Relationship RTB';
        }

        if(settingInstance == 'NoPotentialPost'){
            il.Request_Type__c = 'Relationship Non Potential';
        }

        insert il;

        if(settingInstance == 'CampaignRelationshipPost'){
             sendRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), String.valueOf(re.Opportunity__r.OBI_Sale_Id__c), re.Campaign__c, null, null, settingInstance);
        }

        if(settingInstance == 'RelationshipPost'){
            sendRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), String.valueOf(re.Opportunity__r.OBI_Sale_Id__c), re.Campaign__c, re.Supplier_AAA_Number__r.OBI_Account_ID__c, null, settingInstance);
        }

        if(settingInstance == 'RTBPost'){
            sendRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), String.valueOf(re.Opportunity__r.OBI_Sale_Id__c), re.Campaign__c, re.Supplier_AAA_Number__r.OBI_Account_ID__c, re.OBI_Relationship_Id__c, settingInstance);
        }

        if(settingInstance == 'OnHoldPost'){
            sendRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), String.valueOf(re.Opportunity__r.OBI_Sale_Id__c), re.Campaign__c, re.Supplier_AAA_Number__r.OBI_Account_ID__c, re.OBI_Relationship_Id__c, settingInstance);
        }

        if(settingInstance == 'NoPotentialPost'){
            sendRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), String.valueOf(re.Opportunity__r.OBI_Sale_Id__c), re.Campaign__c, re.Supplier_AAA_Number__r.OBI_Account_ID__c, re.OBI_Relationship_Id__c, settingInstance);
        }
        
    }



    @future(callout=true)
    public static void sendRequest(String email, String req, String logId, String oppId, String campaignId, String accountId, String relationshipId, String settingInstance){


        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();
        
        String endpoint = obi.Endpoint__c;
        
        if(settingInstance == 'RTBPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            endpoint = endpoint.replace('{SaleId}', TungstenUtil.GetStringValue(oppId));
            //endpoint = endpoint.replace('{CampaignId}', TungstenUtil.GetStringValue(campaignid));
            endpoint = endpoint.replace('{CampaignId}', TungstenUtil.GetStringValue(campaignid));
        }
        if(settingInstance == 'RelationshipPut'){
            endpoint = endpoint.replace('{userId}', TungstenUtil.GetStringValue(email));
            endpoint = endpoint.replace('{accountId}', TungstenUtil.GetStringValue(accountId));
            endpoint = endpoint.replace('{relationshipId}', TungstenUtil.GetStringValue(relationshipId));
        }

        if(settingInstance == 'CampaignRelationshipPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            endpoint = endpoint.replace('{CampaignId}', TungstenUtil.GetStringValue(campaignId));
        }

        if(settingInstance == 'RelationshipPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            endpoint = endpoint.replace('{AccountId}', TungstenUtil.GetStringValue(accountId));
        }

        if(settingInstance == 'OnHoldPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            endpoint = endpoint.replace('{SaleId}', TungstenUtil.GetStringValue(oppId));
            endpoint = endpoint.replace('{CampaignId}', TungstenUtil.GetStringValue(campaignid));
        }

        if(settingInstance == 'OffHoldPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            endpoint = endpoint.replace('{SaleId}', TungstenUtil.GetStringValue(oppId));
            endpoint = endpoint.replace('{CampaignId}', TungstenUtil.GetStringValue(campaignid));
        }

        if(settingInstance == 'NoPotentialPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            endpoint = endpoint.replace('{SaleId}', TungstenUtil.GetStringValue(oppId));
            endpoint = endpoint.replace('{SalesforceCampaignId}', TungstenUtil.GetStringValue(campaignid));
        }
        
        r.setEndpoint(endpoint);
        r.setHeader('Authorization', obi.Authorisation__c);
        r.setHeader('Content-Type', obi.Content_Type__c);
        r.setHeader('external-request-identifier', logId);
        r.setMethod(obi.Method__c);
        r.setBody(req);
        r.setTimeout(60000);
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


    /**
     * [updateMostPositiveStatus description]
     * @param relationships [description]
     */
    public static void updateMostPositiveStatus(List<Relationship__c> relationships){
        

        if(relationships.size() > 0){
            Set<Id> accounts = new Set<Id>();

            for(Relationship__c r : relationships){
                accounts.add(r.Supplier_Account__c);
            }

            List<Relationship__c> r = new List<Relationship__c>();
            List<Account> supplierAccounts = new List<Account>();
            Map<Account, List<Relationship__c>> supplierToRelationshipMap = new Map <Account, List<Relationship__c>>();

            r = [Select Id, Relationship_Status__c, Supplier_Account__c
                 From Relationship__c
                 Where Supplier_Account__c  IN :accounts];

            supplierAccounts = [Select Id 
                                From Account
                                Where Id IN :accounts];

            if(r.size() > 0){
                for(Account a : supplierAccounts){

                    List<Relationship__c> rs = new List<Relationship__c>();
                    for(Relationship__c rel : r){
                        if(a.Id == rel.Supplier_Account__c){
                            rs.add(rel);
                        }
                    }
                    supplierToRelationshipMap.put(a, rs);
                }

                List<Account> accountsToUpdate = new List<Account>();

                for(Account a : supplierToRelationshipMap.keyset()){
                    List<Relationship__c> supplierRelationships = new List<Relationship__c>();

                    supplierRelationships = supplierToRelationshipMap.get(a);

                    Boolean liveRelationshipsExist = false;
                    Boolean rttRelationshipsExist = false;
                    Boolean inImplementationRelationshipsExist = false;
                    Boolean inSalesRelationshipsExist = false;
                    Boolean onHoldRelationshipsExist = false;
                    Boolean rtbRelationshipsExist = false;
                    Boolean noPotentialRelationshipsExist = false;
                    Boolean knownRelationshipsExist = false;
                    Boolean onStopRelationshipsExist = false;
                    Boolean terminatedRelationshipsExist = false;
                    Boolean rejectedRelationshipsExist = false;
                    Boolean cancelledRelationshipsExist = false;
                    Boolean mergedRelationshipsExist = false;

                    for(Relationship__c k : supplierRelationships){
                        if(k.Relationship_Status__c == 'Merged'){
                            mergedRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'Cancelled'){
                            cancelledRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'Reject'){
                            rejectedRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'Terminated'){
                            terminatedRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'On Stop'){
                            onStopRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'Known'){
                            knownRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'Non Potential'){
                            noPotentialRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'Refer to Buyer'){
                            rtbRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'On Hold'){
                            onHoldRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'In Sales'){
                            inSalesRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'In Implementation'){
                            inImplementationRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'Ready To Transact'){
                            rttRelationshipsExist = true;
                        }
                        if(k.Relationship_Status__c == 'Live'){
                            liveRelationshipsExist = true;
                        }
                    }

                    if(mergedRelationshipsExist == true){
                        a.Account_Status__c = 'Merged';
                    }
                    if(cancelledRelationshipsExist == true){
                        a.Account_Status__c = 'Cancelled';
                    }
                    if(rejectedRelationshipsExist == true){
                        a.Account_Status__c = 'Reject';
                    }
                    if(terminatedRelationshipsExist == true){
                        a.Account_Status__c = 'Terminated';
                    }
                    if(onStopRelationshipsExist == true){
                        a.Account_Status__c = 'On Stop';
                    }
                    if(knownRelationshipsExist == true){
                        a.Account_Status__c = 'Known';
                    }
                    if(noPotentialRelationshipsExist == true){
                        a.Account_Status__c = 'Non Potential';
                    }
                    if(rtbRelationshipsExist == true){
                        a.Account_Status__c = 'Refer to Buyer';
                    }
                    if(onHoldRelationshipsExist == true){
                        a.Account_Status__c = 'On Hold';
                    }
                    if(inSalesRelationshipsExist == true){
                        a.Account_Status__c = 'In Sales';
                    }
                    if(inImplementationRelationshipsExist == true){
                        a.Account_Status__c = 'In Implementation';
                    }
                    if(rttRelationshipsExist == true){
                        a.Account_Status__c = 'Ready To Transact';
                    }
                    if(liveRelationshipsExist == true){
                        a.Account_Status__c = 'Live';
                    }

                    accountsToUpdate.add(a);
                }

                update accountsToUpdate;
            }

        }
    }


    /**
     * [newRelationships description]
     * @param relationships [description]
     */
    public static void updateOpportunityConfirmedRelationships(List<Relationship__c> relationships){

        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Relationship__c> oppRelationships = new List<Relationship__c>();
        Map<Id, List<Relationship__c>> opportunityIdToConfirmedRelationshipMap = new Map<Id, List<Relationship__c>>();

        for(Relationship__c r : relationships){
            opportunityIds.add(r.Opportunity__c);
        } 

        if(opportunityIds.size() > 0){

            opportunities = [Select Id, Confirmed_Relationships__c
                             From Opportunity
                             Where Id in :opportunityIds];

            oppRelationships = [Select Id, Confirmed__c, Opportunity__c
                             From Relationship__c
                             Where Opportunity__c in : opportunityIds];


            for(Opportunity o : opportunities){
                List<Relationship__c> confirmedRelationships = new List<Relationship__c>();

                for(Relationship__c r : oppRelationships){
                    if(r.Confirmed__c == true){
                        confirmedRelationships.add(r);
                    }
                }

                opportunityIdToConfirmedRelationshipMap.put(o.Id, confirmedRelationships);
            }

            for(Id i :  opportunityIdToConfirmedRelationshipMap.keySet()){
                Opportunity opp = new Opportunity();
                opp.Id = i;

                List<Relationship__c> rels = new List<Relationship__c>();

                rels = opportunityIdToConfirmedRelationshipMap.get(i);


                opp.Confirmed_Relationships__c = rels.size();

                opportunitiesToUpdate.add(opp);
            }

            if(opportunitiesToUpdate.size() > 0){
                update opportunitiesToUpdate;
            }


        }       

    }




    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    public static void createOBIJSONBulkRelaionshipRequest(List<Relationship__c> rels, String settingInstance){
        
        HttpRequest req;
        String result = '';
        System.debug('IIIIIIIIIn!');
        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        List<Relationship__c> relationships = new List<Relationship__c>();

        relationships = [Select Id, Attachment_Settings__c, Authorisation_Contact_for_RTB__c, Buyer_Account__c,
                     Campaign__c, Campaign__r.Name, ePHI__c, Opportunity__c, PO_Required__c, PO_Validation__c, Relationship_Status__c, 
                     Supplier_Account__c, Vendor_Code__c, Authorisation_Contact_for_RTB__r.Email, Authorisation_Contact_for_RTB__r.FirstName,
                     Authorisation_Contact_for_RTB__r.LastName, RTB_Reason_Code__c, Additional_Notes__c, Opportunity__r.OBI_Sale_Id__c, 
                     Supplier_AAA_Number__r.Name, OBI_Status_Code__c, Supplier_AAA_Number__r.OBI_Account_ID__c, Buyer_AAA_Number__r.Name, Off_Hold_Date__c,
                     On_Hold_Reason__c, RTB_Notes__c, OBI_Relationship_Id__c, Authorisation_Contact_for_No_Potential__r.Email, 
                     Authorisation_Contact_for_No_Potential__r.LastName, Authorisation_Contact_for_No_Potential__r.FirstName, 
                     No_Potential_Reason_Code__c, OBI_No_Potential_Reason_Code__c, Campaign__r.OBI_Object_ID__c,
                     Authorisation_Contact_for_On_Hold__c, Authorisation_Contact_for_On_Hold_Email__c
             From Relationship__c
             Where Id = :rels];

        if(relationships != null){

            Map<Id, List<Relationship__c>> campaignIdToRelationshipMap = new Map<Id, List<Relationship__c>>();

            for(Relationship__c r : relationships){

                if(campaignIdToRelationshipMap.containsKey(r.Campaign__c)){

                    List<Relationship__c> rs = new List<Relationship__c>();
                    rs = campaignIdToRelationshipMap.get(r.Campaign__c);
                    rs.add(r);
                    campaignIdToRelationshipMap.put(r.Campaign__c, rs);

                }else{
                    List<Relationship__c> rs = new List<Relationship__c>();

                    rs.add(r);

                    campaignIdToRelationshipMap.put(r.Campaign__c, rs);
                }
            }



            for(Id i : campaignIdToRelationshipMap.keySet()){

            List<Relationship__c> relats = new List<Relationship__c>();

            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);

            relats = campaignIdToRelationshipMap.get(i);

            if(settingInstance == 'RelationshipPost'){
                gen.writeStartObject();
                gen.writeFieldName('details');
                    gen.writeStartArray();
                for(Relationship__c re : relats){
                    gen.writeStartObject();
                        gen.writeStringField('buyeraaa', re.Buyer_AAA_Number__r.Name);
                        gen.writeNumberField('releaseid', 0);
                        gen.writeNumberField('saleid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Opportunity__r.OBI_Sale_Id__c)));
                        gen.writeStringField('reasoncode', '0');
                        gen.writeStringField('supplieraaa', TungstenUtil.GetStringValue(re.Supplier_AAA_Number__r.Name));
                        gen.writeNumberField('campaignid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Campaign__r.OBI_Object_ID__c)));
                        gen.writeStringField('vendorcode', TungstenUtil.GetStringValue(re.Vendor_Code__c));
                        gen.writeNumberField('porequired', 1);
                        gen.writeNumberField('attachmentrequired', 0);
                        gen.writeNumberField('povalidation', 0);
                        gen.writeNumberField('status', 2);
                        gen.writeStringField('salesforceid', re.Id);
                    gen.writeEndObject();
                }
                gen.writeEndArray();
                gen.writeEndObject();
            }

            if(settingInstance == 'CampaignRelationshipPost'){
                gen.writeStartObject();
                gen.writeFieldName('details');
                    gen.writeStartArray();

                    for(Relationship__c re : relats){
                         gen.writeStartObject();
                            gen.writeStringField('salesforceid', re.Id);
                            gen.writeNumberField('status', TungstenUtil.GetIntegerValue(Integer.valueOf(re.OBI_Status_Code__c)));
                            gen.writeStringField('supplieraaa', TungstenUtil.GetStringValue(re.Supplier_AAA_Number__r.Name));
                            gen.writeNumberField('saleid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Opportunity__r.OBI_Sale_Id__c)));
                        gen.writeEndObject();
                    }
                

                gen.writeEndArray();
                gen.writeEndObject();
            }

            if(settingInstance == 'NoPotentialPost'){
                gen.writeStartObject();
                gen.writeFieldName('details');
                    gen.writeStartArray();

                    for(Relationship__c re : relats){
                         gen.writeStartObject();
                            gen.writeStringField('reasonCode', TungstenUtil.GetStringValue(re.OBI_No_Potential_Reason_Code__c));
                            gen.writeStringField('note', 'sample note');
                            gen.writeStringField('email', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_No_Potential__r.Email));
                            gen.writeStringField('firstName', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_No_Potential__r.FirstName));
                            gen.writeStringField('LastName', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_No_Potential__r.LastName));
                            gen.writeNumberField('saleid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Opportunity__r.OBI_Sale_Id__c)));
                            gen.writeStringField('campaignsalesforceid', TungstenUtil.GetStringValue(re.Campaign__c));
                            gen.writeStringField('userId', TungstenUtil.GetStringValue(runningUser.Email));
                            gen.writeStringField('salesforceid', TungstenUtil.GetStringValue(re.Id));
                        gen.writeEndObject();
                    }
                

                gen.writeEndArray();
                gen.writeEndObject();
            }

            if(settingInstance == 'OnHoldPost'){
                 gen.writeStartObject();
                    gen.writeFieldName('details');
                    gen.writeStartArray();
                        for(Relationship__c re : relats){
                            gen.writeStartObject();
                                gen.writeNumberField('saleid', TungstenUtil.GetIntegerValue(Integer.valueOf(re.Opportunity__r.OBI_Sale_Id__c)));
                                gen.writeStringField('campaignsalesforceid', TungstenUtil.GetStringValue(re.Campaign__c));
                                gen.writeStringField('reasonCode', 'HLD001'); //this is the only reason code available at the moment, so this is fixed
                                gen.writeStringField('note', TungstenUtil.GetStringValue(re.On_Hold_Reason__c));
                                gen.writeStringField('offHoldDate', String.valueOf(re.Off_Hold_Date__c));
                                gen.writeStringField('email', TungstenUtil.GetStringValue(re.Authorisation_Contact_for_On_Hold_Email__c)); //supplier contact email
                            gen.writeEndObject();
                        }
                    gen.writeEndArray();
                gen.writeEndObject();
            }

            result = gen.getAsString();

             String body = result;

             ///////////////////////////////
            ///Create Log
            ///////////////////////////////
            
            Integration_Log__c il = new Integration_Log__c();
            il.Integration_Service__c = 'OBI';
            il.Log_Type__c = 'Request';
            //il.Campaign__c = i;

            if(settingInstance == 'RelationshipPost'){
                il.Request_Type__c = 'Relationship Insert Bulk';
            }

            if(settingInstance == 'CampaignRelationshipPost'){
                il.Request_Type__c = 'Campaign Relationship Insert Bulk';
            }

            if(settingInstance == 'OnHoldPost'){
                il.Request_Type__c = 'Relationship On Hold Bulk';
            }

            if(settingInstance == 'RTBPost'){
                il.Request_Type__c = 'Relationship RTB Bulk';
            }

            if(settingInstance == 'NoPotentialPost'){
                il.Request_Type__c = 'Relationship Non Potential Bulk';
            }


            insert il;

            if(settingInstance == 'CampaignRelationshipPost'){
                 //sendRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), String.valueOf(re.Opportunity__r.OBI_Sale_Id__c), re.Campaign__c, null, null, settingInstance);
            }

            if(settingInstance == 'RelationshipPost'){
                //sendRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), String.valueOf(re.Opportunity__r.OBI_Sale_Id__c), re.Campaign__c, re.Supplier_AAA_Number__r.OBI_Account_ID__c, null, settingInstance);
            }

            if(settingInstance == 'OnHoldPost'){
                sendBulkRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), settingInstance);
            }

            if(settingInstance == 'NoPotentialPost'){
                //sendRequest(String.valueOf(runningUser.Email),body,String.valueOf(il.Id), String.valueOf(re.Opportunity__r.OBI_Sale_Id__c), re.Campaign__c, re.Supplier_AAA_Number__r.OBI_Account_ID__c, re.OBI_Relationship_Id__c, settingInstance);
            }

            }

           }
   
    }




    @future(callout=true)
    public static void sendBulkRequest(String email, String req, String logId, String settingInstance){


        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();
        
        String endpoint = obi.Endpoint__c;
        
        if(settingInstance == 'RTBPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            //endpoint = endpoint.replace('{SaleId}', TungstenUtil.GetStringValue(oppId));
            //endpoint = endpoint.replace('{CampaignId}', TungstenUtil.GetStringValue(campaignid));
            //endpoint = endpoint.replace('{CampaignId}', TungstenUtil.GetStringValue(campaignid));
        }
        if(settingInstance == 'RelationshipPut'){
            endpoint = endpoint.replace('{userId}', TungstenUtil.GetStringValue(email));
            //endpoint = endpoint.replace('{accountId}', TungstenUtil.GetStringValue(accountId));
            //endpoint = endpoint.replace('{relationshipId}', TungstenUtil.GetStringValue(relationshipId));
        }

        if(settingInstance == 'CampaignRelationshipPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            //endpoint = endpoint.replace('{CampaignId}', TungstenUtil.GetStringValue(campaignId));
        }

        if(settingInstance == 'RelationshipPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            //endpoint = endpoint.replace('{AccountId}', TungstenUtil.GetStringValue(accountId));
        }

        if(settingInstance == 'OnHoldPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
        }

        if(settingInstance == 'NoPotentialPost'){
            endpoint = endpoint.replace('{UserId}', TungstenUtil.GetStringValue(email));
            //endpoint = endpoint.replace('{SaleId}', TungstenUtil.GetStringValue(oppId));
            //endpoint = endpoint.replace('{SalesforceCampaignId}', TungstenUtil.GetStringValue(campaignid));
        }
        
        r.setEndpoint(endpoint);
        r.setHeader('Authorization', obi.Authorisation__c);
        r.setHeader('Content-Type', obi.Content_Type__c);
        r.setHeader('external-request-identifier', logId);
        r.setMethod(obi.Method__c);
        r.setBody(req);
        r.setTimeout(60000);
        

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