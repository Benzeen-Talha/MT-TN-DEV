/**
* @Name:  ContactTriggerHandler
* @description: Trigger handler class for Contact Object trigger
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 11/02/16    T.Sotiraki      Created Trigger   
*/
public with sharing class ContactTriggerHandler {
    
    public static boolean UpdateFromOBi = false; 

    public static void onAfterInsert(List<Contact> contacts){
        try{
            if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
                for(Contact c : contacts){
                    ContactUtil.createOBIJSONMessageRequest(c.Id, 'ContactPost');
                }

                ///////////////////////////
                ///Update Domain List
                ///////////////////////////
                ContactUtil.updateDomainList(contacts);
            }
        }
        catch(Exception ex){
            System.debug('Error onAfterInsert: ' + ex.getMessage());
        }
    }

    public static void onAfterUpdate(List<Contact> contacts, Map<Id, Contact> oldContactsMap){
        try{
            if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
                for(Contact c : contacts){
                    if((c.FirstName != oldContactsMap.get(c.Id).FirstName ||
                       c.LastName != oldContactsMap.get(c.Id).LastName ||
                       c.Salutation != oldContactsMap.get(c.Id).Salutation ||
                       c.Phone != oldContactsMap.get(c.Id).Phone ||
                       c.HomePhone != oldContactsMap.get(c.Id).HomePhone ||
                       c.MobilePhone != oldContactsMap.get(c.Id).MobilePhone ||
                       c.Fax != oldContactsMap.get(c.Id).Fax ||
                       c.Email != oldContactsMap.get(c.Id).Email ||
                       c.Title != oldContactsMap.get(c.Id).Title ) && 
                       c.OBI_Contact_Id__c != null
                    ){
                
                        ContactUtil.createOBIJSONMessageRequest(c.Id, 'ContactPut');
                    }
                }

                ///////////////////////////
                ///Update Domain List
                ///////////////////////////
                ContactUtil.updateDomainList(contacts);
            }
        }
        catch(Exception ex){
            System.debug('Error onAfterUpdate: ' + ex.getMessage());
        }
    }

    public static void onAfterDelete(List<Contact> contacts){
        try{
            if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
                for(Contact c : contacts){
                    ContactUtil.createOBIJSONMessageRequest(c.Id, 'ContactDelete');
                }
            }
        }
        catch(Exception ex){
            System.debug('Error onAfterDelete: ' + ex.getMessage());
        }
    }
}