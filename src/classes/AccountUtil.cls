/**
* @description: Utilities class for Account Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 18/04/16  T.Sotiraki        Created class
*/
public with sharing class AccountUtil {
    
    /**
     * [createOBIJSONMessageRequest description]
     * @param  contact       [Contact record to process]
     * @param  method        [description]
     * @return void          [void]
     */
    
    public static void createOBIJSONMessageRequest(Id accountId, String settingInstance){
        
        HttpRequest req;
        String result = '';
        
        Account a = new Account();

        a = [Select Id, Name, Vat_Registration_Number__c, Company_Registration_Number__c, Share_of_Capital__c,
                    Number_and_Court_of_Registration__c, Type_of_company__c, Town_of_Registration__c, Chairman__c, 
                    Chairman_of_the_Board__c, Liable_Company__c, Business_Style__c, Profession__c, Tax_Regime__c,
                    Liquidator_Name__c, Early_Payment_Discount__c, Late_Payment_Penalty__c, Permit_Number__c,
                    Permit_Date__c, Authority_to_Print_Number__c, Period_Start_Date__c, Certification_Number__c,
                    Has_Certification_Number__c, OBI_Entity_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                    BillingCountryCode
             From Account
             Where Id = :accountId];

        
        if(a != null){
            
            OBiEntity entity = new OBiEntity();
            entity.taxregistrationno = TungstenUtil.GetStringValue(a.Vat_Registration_Number__c);
            entity.companyregistrationno = TungstenUtil.GetStringValue(a.Company_Registration_Number__c);
            
            OBiEntity.Address address = new OBiEntity.Address();
            address.line1 = TungstenUtil.GetStringValue(a.BillingStreet);
            address.line2 = TungstenUtil.GetStringValue(' ');
            address.line3 = TungstenUtil.GetStringValue(' ');
            address.city =  TungstenUtil.GetStringValue(a.BillingCity);
            address.state = TungstenUtil.GetStringValue(a.BillingState);
            address.zipcode = TungstenUtil.GetStringValue(a.BillingPostalCode);
            address.countrycode = TungstenUtil.GetStringValue(a.BillingCountryCode);
            
            
            entity.registeredAddress = address;
            entity.tradingaddress = address;
            entity.liquidatoraddress = address;

            entity.sharecapital = TungstenUtil.GetStringValue(a.Share_of_Capital__c);
            entity.typeofcompany = TungstenUtil.GetStringValue(a.Type_of_company__c);
            entity.nocourtofregistration = TungstenUtil.GetStringValue(a.Number_and_Court_of_Registration__c);
            entity.townofregistration = TungstenUtil.GetStringValue(a.Town_of_Registration__c);
            entity.chairman = TungstenUtil.GetStringValue(a.Chairman__c);
            entity.chairmanofboard = TungstenUtil.GetStringValue(a.Chairman_of_the_Board__c);
            entity.liablecompany = TungstenUtil.GetStringValue(a.Liable_Company__c);
            entity.businessstyle = TungstenUtil.GetStringValue(a.Business_Style__c);
            entity.profession = TungstenUtil.GetStringValue(a.Profession__c);
            entity.taxregime = TungstenUtil.GetStringValue(a.Tax_Regime__c);
            entity.liquidator = TungstenUtil.GetStringValue(a.Liquidator_Name__c);
            entity.earlypaymentdisc = TungstenUtil.GetStringValue(a.Early_Payment_Discount__c);
            entity.latepaypenalty = TungstenUtil.GetStringValue(a.Late_Payment_Penalty__c);
            entity.permitno = TungstenUtil.GetStringValue(a.Permit_Number__c);
            if(a.Period_Start_Date__c != null){
                 entity.periodstartdate = a.Period_Start_Date__c;
            }else{
                 entity.periodstartdate = System.today();
            }
           
            entity.certificationno = TungstenUtil.GetStringValue(a.Certification_Number__c);
            entity.hascertificationno = a.Has_Certification_Number__c;

            entity.directors = new List<String> {'N/A'};
            entity.executivedirectors = new List<string> {'N/A'};
            entity.name = TungstenUtil.GetStringValue(a.Name);
            entity.salesforceid = TungstenUtil.GetStringValue(a.Id);


            
            if(settingInstance == 'AccountPut'){
                entity.entityid = integer.valueof(TungstenUtil.GetStringValue(a.OBI_Entity_ID__c));
            }else if(settingInstance == 'EntityPost'){
                entity.entityid = 0;
            }             
            
            result = JSON.serialize(entity);

            system.debug(result);
            
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
        iL.Account__c = a.Id;

        if(settingInstance == 'AccountPut'){
            il.Request_Type__c = 'Account Update';
        }

        if(settingInstance == 'EntityPost'){
            il.Request_Type__c = 'Account Insert';
        }

        insert il;

        if(settingInstance == 'AccountPut'){
            sendRequest(body,String.valueOf(il.Id), a.OBI_Entity_ID__c, settingInstance);
        }else if(settingInstance == 'EntityPost'){
            sendRequest(body,String.valueOf(il.Id), '', settingInstance);
        } 
    }

    @future(callout=true)
    public static void sendRequest(String req, String logId, String obiAccountId, String settingInstance){


        ///////////////////////////////
        ///Create HTTP Request
        ///////////////////////////////
        OBISyncSettings2__c obi = OBISyncSettings2__c.getInstance(settingInstance);

        HTTPRequest r = new HTTPRequest();
        
        User runningUser = [Select Id, Email From User Where Id = :UserInfo.getUserId()];

        String endpoint = obi.Endpoint__c;
        endpoint = endpoint.replace('{userId}', runningUser.Email);
        if(settingInstance == 'AccountPut'){
              endpoint = endpoint.replace('{entityId}', obiAccountId);
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
                                                                                            
}