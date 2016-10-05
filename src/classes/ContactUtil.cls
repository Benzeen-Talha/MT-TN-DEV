/**
* @Name:  ContactUtil
* @description: Utilities class for Contact Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 11/02/16    T.Sotiraki      Created Trigger   
*/
public with sharing class ContactUtil {
    

    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void createOBIJSONMessageRequest(Id contactId, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        Contact c = new Contact();

        c = [Select Id, FirstName, LastName, Title, Email, Fax, HomePhone, Salutation, Phone, 
                    AccountId, OBI_Account_ID__c, OBI_Contact_Id__c, MobilePhone, Account.OBI_Entity_Id__c
             From Contact
             Where Id = :contactId];

        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        if(c != null){
            // Create a JSON generator object
            JSONGenerator gen = JSON.createGenerator(true);
                
            gen.writeStartObject();
                gen.writeStringField('firstName', TungstenUtil.GetStringValue(c.FirstName));
                gen.writeStringField('lastName', TungstenUtil.GetStringValue(c.LastName));
                
                if(c.Salutation == null){
                    gen.writeStringField('salutation', TungstenUtil.GetStringValue('Mr.'));
                }else{
                    gen.writeStringField('salutation', TungstenUtil.GetStringValue(c.Salutation));
                
                }
                if(c.Phone == null){
                    gen.writeStringField('workPhone', TungstenUtil.GetStringValue(String.valueOf(000000000)));
                }else{
                    gen.writeStringField('workPhone', TungstenUtil.GetStringValue(String.valueOf(TungstenUtil.GetIntegerValue(Integer.valueOf(c.Phone)))));
                
                }
                if(c.HomePhone == null){
                    gen.writeStringField('homePhone', TungstenUtil.GetStringValue(String.valueOf(000000000)));
                }else{
                    gen.writeStringField('homePhone', TungstenUtil.GetStringValue(String.valueOf(TungstenUtil.GetIntegerValue(Integer.valueOf(c.HomePhone)))));
                
                }
                if(c.MobilePhone == null){
                    gen.writeStringField('mobilePhone', TungstenUtil.GetStringValue(String.valueOf(000000000)));
                }else{
                    gen.writeStringField('mobilePhone', TungstenUtil.GetStringValue(String.valueOf(TungstenUtil.GetIntegerValue(Integer.valueOf(c.MobilePhone)))));
                
                }

                if(c.Fax == null){
                    gen.writeStringField('fax', TungstenUtil.GetStringValue(String.valueOf(000000000)));
                }else{
                    gen.writeStringField('fax', TungstenUtil.GetStringValue(String.valueOf(TungstenUtil.GetIntegerValue(Integer.valueOf(c.Fax)))));
                
                }
                if(c.Email == null){
                    gen.writeStringField('email', TungstenUtil.GetStringValue('noemail@noemail.com'));
                }else{
                    gen.writeStringField('email', TungstenUtil.GetStringValue(c.Email));
                
                }
                if(c.Title == null){
                    gen.writeStringField('jobTitle', TungstenUtil.GetStringValue('N/A'));
                }else{
                    gen.writeStringField('jobTitle', TungstenUtil.GetStringValue(c.Title));
                
                }
                
                gen.writeStringField('salesforceid', TungstenUtil.GetStringValue(c.Id));
                
                
                
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
        il.Contact__c = c.Id;

        if(settingInstance == 'ContactPut'){
            il.Request_Type__c = 'Contact Update';
        }
        if(settingInstance == 'ContactDelete'){
            il.Request_Type__c = 'Contact Delete';
        }
        if(settingInstance == 'ContactPost'){
            il.Request_Type__c = 'Contact Insert';
        }

        insert il;

        if(settingInstance == 'ContactPut' || settingInstance == 'ContactDelete'){
            sendRequest(body,String.valueOf(il.Id), c.Account.OBI_Entity_Id__c, settingInstance, c.OBI_Contact_Id__c);
        }



        if(settingInstance == 'ContactPost'){
            sendRequest(body,String.valueOf(il.Id), c.Account.OBI_Entity_Id__c, settingInstance, String.valueOf(c.Id));
        }
        
        
    }

    @future(callout=true)
    public static void sendRequest(String req, String logId, String obiAccountId, String settingInstance, String contactId){


        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();
        
        String endpoint = obi.Endpoint__c;
        
        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        endpoint = endpoint.replace('{userId}', TungstenUtil.GetStringValue(runningUser.Email));
        endpoint = endpoint.replace('{entityId}', obiAccountId);
        if(contactId != null && (settingInstance == 'ContactPut' || settingInstance == 'ContactDelete')){
            endpoint = endpoint.replace('{contactId}', contactId);
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

    public static void updateDomainList(List<Contact> contacts){

        Set<Id> accountIdSet = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        Map<Account, List<String>> accountIdToDomainListMap = new Map<Account, List<String>>();

        for(Contact c : contacts){
            if(c.AccountId != null){
                accountIdSet.add(c.AccountId);
            }
        }

        List<Account> accounts = new List<Account>();
        List<Contact> allContacts = new List<Contact>();

        accounts = [Select Id, Domain_List__c
                    From Account
                    Where Id In :accountIdSet];

        allContacts = [Select Id, Email, AccountId
                       From Contact
                       Where AccountId In :accountIdSet];


        for(Account a : accounts){
            List<String> domains = new List<String>();

            String d = '';
            for(Contact c : allContacts){
                if(c.Email != null){
                    d = c.Email.split('@').get(1);
                    domains.add(d);
                }
            }

            accountIdToDomainListMap.put(a, domains);
            
        }


        for(Account a : accountIdToDomainListMap.keySet()){
            List<String> domains = accountIdToDomainListMap.get(a);
            
            String domainList = '';
            domainList = String.join(domains, ',');

            a.Domain_List__c = domainList;

            accountsToUpdate.add(a);
        }

        update accountsToUpdate;

    }


}