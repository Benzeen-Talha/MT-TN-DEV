@RestResource(urlMapping='/OBiIntegrationService/*')
global class OBiIntegrationService {
 
    public static string ACCOUNT_FROM_RTB = 'AccountStatusChange_FROM_RTB';
    public static string RELATIONSHIP_TO_RTT = 'RelStatusChange_TO_RTT';
    public static string PORTAL_ADMIN_CHANGE = 'PortalAdministratorChange';
    public static string UPDATE_PRIMARY_ADDRESS = 'UpdatePrimaryAddress';
    public static string REL_STATUS_CHANGE_TO_LIVE = 'RelStatusChange_To_Live'; 
    public static string ENTITY_TO_LIVE = 'Entity_To_Live';
    public static string NOTIFY_PORTAL_TERMS_ACCEPT = 'Notify_Portal_Terms_Acceptance';
    public static string CIPHER_TYPE = 'AES256';
        
	@HttpPost
    global static boolean HandlePost(){
        Boolean operation_result = false;

        
        if ((UserInfo.getUserName() == System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() == System.Label.OBI_Integration_User_UAT))
        {
            Blob decryptedBlob = CryptoUtil.Decrypt(RestContext.request.requestBody, CIPHER_TYPE);
            String strPostedData = decryptedBlob.toString().replaceAll('\n', '').replaceAll('\r', '').replaceAll('[\\x00-\\x09\\x11\\x12\\x14-\\x1F\\x7F]', '');
    
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strPostedData);
    
            String strJson = EncodingUtil.base64Decode((String)m.get('Payload')).toString();
    
            m = (Map<String, Object>)JSON.deserializeUntyped(strJson);
            String Event = (String)m.get('Event');
    
            if (Event == REL_STATUS_CHANGE_TO_LIVE)
            {
                operation_result = relStatusChangeToLive(m);
            }
    
            if (Event == RELATIONSHIP_TO_RTT)
            {
                operation_result = relationShipToRTT(m);
            }
    
            if (Event == ENTITY_TO_LIVE)
            {
                operation_result = entityToLive(m);
            }
    
            if (Event == ACCOUNT_FROM_RTB)
            {
                operation_result = accountFromRTB(m);
            }
    
            if (Event == NOTIFY_PORTAL_TERMS_ACCEPT)
            {
                operation_result = notifyPortalTermsAccept(m);
            }
    
            if (Event == PORTAL_ADMIN_CHANGE)
            {
                operation_result = portalAdminChange(m);
            }
    
            if (Event == UPDATE_PRIMARY_ADDRESS)
            {
                operation_result = updatePrimaryAddress(m);
            }
        }
    
        return operation_result;
    }
    
    // Action and Workflow functions
    
    global static boolean relationShipToRTT(Map<String, Object> m) {
        
        Boolean operation_result = false;
     	String salesforceId = (String) m.get('SalesforceId');
            
        if(salesforceId != ''){
           Relationship__c r = [SELECT Relationship_Status__c FROM Relationship__c where Id = :salesforceId];
           r.Relationship_Status__c = 'Ready To Transact';
           try{
                update r;  
           		operation_result = true;  
           } catch(exception e){
                operation_result = false; 
           }

        }             
        return operation_result; 
	}    
    
	global static boolean relStatusChangeToLive(Map<String, Object> m) {
        
		String oldStatus = 		(String) m.get('OldValue');
        String newStatus = 		(String) m.get('NewValue');
        String salesforceId = 	(String) m.get('SalesforceId');
		Boolean operation_result = false; 
        
        Relationship__c r = [SELECT Name, Relationship_Status__c FROM Relationship__c where Id=:salesforceId];
        r.Relationship_Status__c = 'Live';
        
        try{
            update r; 
            operation_result = true;
        } catch(exception e) {
            operation_result = false;
        }
        
        return operation_result; 
	}
    
	global static boolean entityToLive(Map<String, Object> m) {
        
        String salesforceId = 	(String) m.get('SalesforceId');
		Boolean operation_result = false; 
        
        Account a = [SELECT Name, Account_Status__c FROM Account where Id=:salesforceId];
        a.Account_Status__c = 'Live';

        try{
            update a;             
            operation_result = true;
        } catch(exception e) {
            operation_result = false;
        }
        
        return operation_result; 
	}     

	global static boolean updatePrimaryAddress(Map<String, Object> m) {

        Boolean operation_result = false;
        String AddressLine1 = (String)m.get('AddressLine1');    //Street info
        String AddressLine2 = (String)m.get('AddressLine2');    //Street info
        String AddressLine3 = (String)m.get('AddressLine3');    //Street info
        String AddressLine4 = (String)m.get('AddressLine4');    //City
        String AddressLine5 = (String)m.get('AddressLine5');    //State
        String AddressLine6 = (String)m.get('AddressLine6');    //Postcode
        String Country_ISO_CODE = (String)m.get('CountryISO'); //Country ISO code
        String CountryName = (String)m.get('CountryName');      //Country ISO code
        String AccountSFId = (String)m.get('SalesforceId');     //Account level SF Id	
    
        if (AccountSFId != '')
        {
    
            Account a = [Select Id, OBI_Entity_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountryCode From Account Where Id = :AccountSFId];
    
            if (a != null)
            {
                // clear pre-existing address 
                a.BillingStreet = '';
                a.BillingCity = '';
                a.BillingState = '';
                a.BillingCountry = '';
                a.BillingPostalCode = '';
                a.BillingCountryCode = '';
    
                if (CountryName.toUpperCase() == 'United States'.toUpperCase())
                {
                    a.BillingStreet = AddressLine1 + ' ' + AddressLine2 + ' ' + AddressLine3 + ' ' + AddressLine4;
                    AddressLine5 = AddressUtil.US_StateLookup(AddressLine5);
                    a.BillingState = AddressLine5;
                }
                else
                {
                    a.BillingStreet = AddressLine1 + ' ' + AddressLine2 + ' ' + AddressLine3 + ' ' + AddressLine4 + ' ' + AddressLine5;
                }
    
                //a.BillingCity = AddressLine4;  
                a.BillingPostalCode = AddressLine6;
                a.BillingCountry = AddressUtil.CountryLookup(CountryName);
                a.BillingCountryCode = Country_ISO_CODE;
    
                if ((UserInfo.getUserName() == System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() == System.Label.OBI_Integration_User_UAT))
                {
                    try
                    {
                        update a;
                        operation_result = true;
                    }
                    catch (exception e)
                    {
                        system.debug('Error: ' + e.getMessage());
                        operation_result = false;
                    }
                }
            }
        }
        return operation_result;
	}  
    
    global static boolean portalAdminChange(Map<String, Object> m) {
        Boolean operation_result = false;
        List<Contact> contacts = new List<Contact>();
    
        String sf_id_contact = (String)m.get('Contact_SF_ID');
        String sf_id_entity = (String)m.get('Entity_SF_ID');
        Boolean contact_exists = false;
    
        contacts = [SELECT Name, Portal_Administrator__c FROM Contact where AccountId = :sf_id_entity];
    
        for (Contact portal_user : contacts)
        {
            if (String.valueOf(portal_user.Id).contains(sf_id_contact) && sf_id_contact != '')
            {
                portal_user.Portal_Administrator__c = true;
                contact_exists = true;
            }
            else
            {
                portal_user.Portal_Administrator__c = false;
            }
        }
    
        update contacts;
    
        if (!contact_exists)
        {
            Contact c = new Contact();
    
            c.FirstName = (String)m.get('FirstName');
            c.LastName = (String)m.get('LastName');
            c.Phone = (String)m.get('WorkPhone');
            c.Title = (String)m.get('JobTitle');
            c.Email = (String)m.get('Email');
            c.Portal_Administrator__c = true;
            c.AccountId = sf_id_entity;
    
            try
            {
                insert c;
                operation_result = true;
            }
            catch (Exception e)
            {
                operation_result = false;
            }
    
        }
    
        return operation_result;
    }
    
	global static boolean notifyPortalTermsAccept(Map<String, Object> m){

        Boolean operation_result = false;
        Integer saleId = Integer.valueOf(m.get('SaleId'));
    
        Opportunity o = new Opportunity();
        o = [SELECT OwnerId, StageName, Name FROM Opportunity where OBI_Sale_Id__c = :saleId];
        o.StageName = 'Terms Accepted';
    
        try
        {
            update o;
            operation_result = true;
        }
        catch (Exception e)
        {
            operation_result = false;
        }
    
        if (operation_result)
        {
            Task t = new Task();
            User u = new User();
    
            u = [SELECT Id, Username from User where Id = :o.OwnerId];
    
            t.OwnerId = u.Id;
            t.WhatId = o.Id;
            t.Subject = o.Name + ' has accepted Portal terms.';
            t.Status = 'Open';
            t.Priority = 'Normal';
    
            insert t;
        }
    
        return operation_result;
    }
    
	global static boolean accountFromRTB(Map<String, Object> m){
    Boolean operation_result = false;
    String oldStatus = (String)m.get('OldValue');
    String note = (String)m.get('Note');
    String newStatus = (String)m.get('NewValue');
    String salesforceId = (String)m.get('SalesforceId');
    String clientName = (String)m.get('ClientName');

    Account a = new Account();
    a = [SELECT Name from Account where Id = :salesforceId];

    if (salesforceId != '')
    {
        CreateTask(oldStatus, newStatus, a.Name, note, SalesforceId);
        operation_result = true;
    }

    return operation_result;
}	    

    // Utility Functions 
	global static void CreateTask(string oldStatus, string newStatus, string clientName, string note, string account_id) {
        
           Task t = new Task(); 
           User u = new User(); 
           Account a = new Account();
        
           a = [SELECT OwnerId from Account where Id = :account_id];
		   u = [SELECT Id, Username from User where Id = :a.OwnerId];
        
           t.OwnerId = u.Id;
           t.WhatId = account_id;
           t.Subject = clientName + ': from status - ' + oldStatus + ' to status - ' + newStatus;
           t.Status = 'Open';
           t.Priority = 'Normal';
           t.Description = note;
        
           insert t; 
    }    

}