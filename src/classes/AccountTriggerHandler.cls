/**
* @description: Trigger Handler class for Account Object
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 18/04/16  T.Sotiraki        Created class
*/
public with sharing class AccountTriggerHandler {
	
    public static void onBeforeInsert(List<Account> accounts){
                
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				priceBookAssignmentHandler.ledgerAssignmentSupplierSalesHandler(accounts);
			}
		}
		catch(Exception ex){
			System.debug('Error onBeforeInsert: ' + ex.getMessage());
		}
	}

	public static void onBeforeUpdate(List<Account> accounts, Map<Id, Account> oldMap){
        
		try{
                        
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				List<Account> accountsLedgerChange = new List<Account>();

				for(Account a : accounts){
                    
                    //AccountStatusController.CheckTransition(a, oldMap.get(a.Id).Account_Status__c, a.Account_Status__c, false); 
                    
                	if(a.BillingCountry == oldMap.get(a.Id).BillingCountry){
                    	            
                    	accountsLedgerChange.add(a);  
                                                              
                	}
                    
            	}
            
            	priceBookAssignmentHandler.ledgerAssignmentSupplierSalesHandler(accountsLedgerChange);
			}
		}
		catch(Exception ex){
			System.debug('Error onBeforeUpdate: ' + ex.getMessage());
		}
	}


	public static void onAfterInsert(List<Account> accounts){
        
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				for(Account a : accounts){
					AccountUtil.createOBIJSONMessageRequest(a.Id, 'EntityPost');
				}
			}
		}
		catch(Exception ex){
			System.debug('Error onAfterInsert: ' + ex.getMessage());
		}
	}

	public static void onAfterUpdate(List<Account> accounts, Map<Id, Account> oldMap){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				
				for(Account a : accounts){

					if((a.Vat_Registration_Number__c != oldMap.get(a.Id).Vat_Registration_Number__c ||
					   a.Name != oldMap.get(a.Id).Name ||
					   a.Company_Registration_Number__c != oldMap.get(a.Id).Company_Registration_Number__c ||
					   a.Share_of_Capital__c != oldMap.get(a.Id).Share_of_Capital__c ||
					   a.Number_and_Court_of_Registration__c != oldMap.get(a.Id).Number_and_Court_of_Registration__c ||
					   a.Type_of_company__c != oldMap.get(a.Id).Type_of_company__c ||
					   a.Town_of_Registration__c != oldMap.get(a.Id).Town_of_Registration__c ||
					   a.Chairman__c != oldMap.get(a.Id).Chairman__c ||
					   a.Chairman_of_the_Board__c != oldMap.get(a.Id).Chairman_of_the_Board__c ||
					   a.Liable_Company__c != oldMap.get(a.Id).Liable_Company__c ||
					   a.Business_Style__c != oldMap.get(a.Id).Business_Style__c ||
					   a.Profession__c != oldMap.get(a.Id).Profession__c ||
					   a.Tax_Regime__c != oldMap.get(a.Id).Tax_Regime__c ||
					   a.Liquidator_Name__c != oldMap.get(a.Id).Liquidator_Name__c ||
					   a.Early_Payment_Discount__c != oldMap.get(a.Id).Early_Payment_Discount__c ||
					   a.Late_Payment_Penalty__c != oldMap.get(a.Id).Late_Payment_Penalty__c ||
					   a.Permit_Number__c != oldMap.get(a.Id).Permit_Number__c ||
					   a.Permit_Date__c != oldMap.get(a.Id).Permit_Date__c ||
					   a.Authority_to_Print_Number__c != oldMap.get(a.Id).Authority_to_Print_Number__c ||
					   a.Period_Start_Date__c != oldMap.get(a.Id).Period_Start_Date__c ||
					   a.Certification_Number__c != oldMap.get(a.Id).Certification_Number__c ||
					   a.Has_Certification_Number__c != oldMap.get(a.Id).Has_Certification_Number__c ||
					   a.BillingStreet != oldMap.get(a.Id).BillingStreet ||
					   a.BillingCity != oldMap.get(a.Id).BillingCity ||
					   a.BillingState != oldMap.get(a.Id).BillingState ||
					   a.BillingPostalCode != oldMap.get(a.Id).BillingPostalCode ||
					   a.BillingCountryCode != oldMap.get(a.Id).BillingCountryCode ) &&
					   a.OBI_Entity_Id__c != null
					   ){
                	
                 		AccountUtil.createOBIJSONMessageRequest(a.Id, 'AccountPut');   
                }				
			}
		}
	}
	catch(Exception ex){
			System.debug('Error onAfterUpdate: ' + ex.getMessage());
		}
	}
}