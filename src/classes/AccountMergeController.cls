global with sharing class AccountMergeController {

	public static List<Account> accounts;
	
    public static List<AAA_Number__c> aaaNumbers {get;set;}
    public static String searchInput {get;set;}
    public static String selectedPrimaryAAA {get;set;}
    public static String selectedSecondaryAAA {get;set;}
    public static AAA_Number__c master {get;set;}
    public static AAA_Number__c slave {get;set;}
    
  
    
   
    public AccountMergeController(){
        
        selectedPrimaryAAA = null;
        selectedSecondaryAAA = null;
        master = new AAA_Number__c();
        slave = new AAA_Number__c();
       
        
    }
    

    @RemoteAction
    public static List<AAA_Number__c> search(String input){

        aaaNumbers = new List<AAA_Number__c>();

        if(input.length() > 0){
        
            aaaNumbers  = [Select Id, Name, Account__r.Name, Account__r.VAT_Registration_Number__c, Account__r.Account_Status__c, 
                                  Account__r.Domain_List__c
                           From AAA_Number__c
                           Where Name = :input
                           ];

            if(aaaNumbers.size() == 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There were no results for your query. Please try again.'));
            }
        }
        return aaaNumbers;
    }

    @RemoteAction
    public static String mergeAccounts(){

        String result = '';

        if(master.Name == null && slave.Name == null){
            return 'Please select a master and a secondary account to merge.';
        }
        

        if(master.Name == null){
            return 'Please select a master account to merge.';
        }

        if(slave.Name == null ){
            return 'Please select an account to be removed.';

        }

        if(master.Name == slave.Name){
            return 'An account cannot be both a master and a secondary account. Please try again.';
        }

        if(master.Account__c == slave.Account__c){
            return 'You cannot merge two AAA numbers belonging to the same account. Please try again.';
        }
        
        

        AAA_Number__c second = [Select Id, Name, Account__r.Id, Account__r.Name, Account__r.VAT_Registration_Number__c, Account__r.Account_Status__c,
                                       Account__r.Domain_List__c
                               From AAA_Number__c
                               Where Name = :slave.Name];

        if(second.Account__r.Account_Status__c ==  'Live'){
            return 'A Live account cannot be set as a secondary account.';
        }

        AAA_Number__c first = [Select Id, Name, Account__r.Id, Account__r.Name, Account__r.VAT_Registration_Number__c, Account__r.Account_Status__c,
                                      Account__r.Domain_List__c
                               From AAA_Number__c
                               Where Name = :master.Name];


        if(second.Account__r.Account_Status__c == 'Live' && first.Account__r.Account_Status__c == 'Live'){
            return 'Two live accounts cannot be merged.';
        }

        if(second.Account__r.VAT_Registration_Number__c != null && (second.Account__r.VAT_Registration_Number__c != first.Account__r.VAT_Registration_Number__c)){
           return 'These accounts cannot be merged. They do not have the same VAT Number.';
        }

        

        List<Opportunity> opportunitiesToMerge = new List<Opportunity>();

        opportunitiesToMerge = [Select Id, AccountId
                                From Opportunity
                                Where AccountId  = :second.Account__r.Id];

       if(opportunitiesToMerge.size() > 0 ){
            for(Opportunity o : opportunitiesToMerge){
                o.AccountId = first.Account__r.Id;
            }

            update opportunitiesToMerge;
       }

       List<Contact> contactsToMerge = new List<Contact>();

        contactsToMerge = [Select Id, AccountId
                           From Contact
                           Where AccountId  = :second.Account__r.Id];

       if(contactsToMerge.size() > 0 ){
            for(Contact c : contactsToMerge){
                c.AccountId = first.Account__r.Id;
            }

            update contactsToMerge;
       }


       List<Relationship__c> relationshipsToMerge = new List<Relationship__c>();

        relationshipsToMerge = [Select Id, Buyer_Account__c
                                From Relationship__c
                                Where Buyer_Account__c = :second.Account__r.Id];

       if(relationshipsToMerge.size() > 0 ){
            for(Relationship__c r : relationshipsToMerge){
                r.Buyer_Account__c = first.Account__r.Id;
            }

            update relationshipsToMerge;
       }

        Account merged = new Account();

        merged = [Select Id, Account_Status__c 
                  From Account
                  Where Id =:second.Account__r.Id
                  Limit 1];


        if(merged != null){
            merged.Account_Status__c = 'Merged';
            update merged;
        }

        String res = '';
        HttpRequest req;
    
        // Create a JSON generator object
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
               gen.writeStringField('masteraaa', TungstenUtil.GetStringValue(master.Name));
               gen.writeStringField('toremoveaaa', TungstenUtil.GetStringValue(slave.Name));
        gen.writeEndObject();
           
        res = gen.getAsString();
            


        /////////////////////////////////
        ///Message Body
        /////////////////////////////////
        String body = res;

        

        ///////////////////////////////
        ///Create Log
        ///////////////////////////////
        
        Integration_Log__c il = new Integration_Log__c();
        il.Integration_Service__c = 'OBI';
        il.Log_Type__c = 'Request';
        il.Request_Type__c = 'Account Merge';
        
        insert il;

        sendRequest(body,String.valueOf(il.Id), 'AccountMerge');

       result = 'The accounts were merged successfully!';

        return result;
    }

    
    @RemoteAction
    public static AAA_Number__c setAAAPrimary(String selectedAAA){
        
        //master = new AAA_Number__c();
        //master.Name = selectedAAA;

        master  = [Select Id, Name, Account__r.Name, Account__r.VAT_Registration_Number__c, Account__r.Account_Status__c, 
                          Account__r.Domain_List__c, Account__c
                   From AAA_Number__c
                   Where Name = :selectedAAA];


        return master;
    }

    @RemoteAction
    public static AAA_Number__c setAAASecondary(String selectedAAA){
        
        //slave = new AAA_Number__c();
        //slave.Name = selectedAAA;

        slave  = [Select Id, Name, Account__r.Name, Account__r.VAT_Registration_Number__c, Account__r.Account_Status__c,
                         Account__r.Domain_List__c, Account__c
                   From AAA_Number__c
                   Where Name = :selectedAAA];


        return slave;
    }



     @future(callout=true)
    public static void sendRequest(String req, String logId, String settingInstance){


        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();
        
        String endpoint = obi.Endpoint__c;
        endpoint = endpoint.replace('{UserId}', 'tsambika.sotiraki@tungsten-network.com');
   
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