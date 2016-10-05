public with sharing class ContactRoleEditController {

	public Opportunity opportunity{get;set;}	
	public ContactRoleEditController(Apexpages.StandardController stdController){
		this.opportunity = (Opportunity)stdController.getRecord();
		
		this.opportunity = [Select Id, Name, AccountId From Opportunity Where Id =: this.opportunity.id];
	}
	
	public map<Id, map<string, OpportunityContactRole>> ocrMap{
		get{
			if(ocrMap == null){
				ocrMap = new map<Id, map<string, OpportunityContactRole>>();
				for(OpportunityContactRole ocr: [SELECT ContactId,Id,IsPrimary,OpportunityId,Role FROM OpportunityContactRole Where OpportunityId =: this.Opportunity.Id]){
					System.Debug('@@@@@@@' + ocr);
					map<string, OpportunityContactRole> ocrTMap = ocrMap.get(ocr.ContactId);
					if(ocrTMap == null){
						ocrTMap = new map<string, OpportunityContactRole>();
					}
					ocrTMap.put(ocr.Role, ocr);
					ocrMap.put(ocr.ContactId, ocrTMap);
				}
			}
			
			return ocrmap;
		}
		set;
	}

 	public list<contactList> contactMap{
 		get{
 			if(contactMap == null){
 				contactMap = new list<contactList>();
 				for(Contact c : [Select Id, Name, Inactive__c, Full_Name__c, AccountId From Contact Where AccountId =: this.opportunity.AccountId AND InActive__c = false]){
 					map<string, OpportunityContactRole> c2ocr = new map<string, OpportunityContactRole>();
 					c2ocr = ocrMap.get(c.Id) == null ? new map<string, OpportunityContactRole>() : ocrMap.get(c.Id);
 					
 					boolean PR = false;
 					boolean SR = false;
 					boolean BR = false;
 					boolean TR = false;
 					
 					if(c2ocr.get('Sales') != null){
 						SR = true;
 						if(c2ocr.get('Sales').IsPrimary)
 						{PR = true;}
 					}
 					if(c2ocr.get('Billing') != null){
 						BR = true;
 						if(c2ocr.get('Billing').IsPrimary)
 						{PR = true;}
 					}
 					if(c2ocr.get('Technical') != null){
 						TR = true;
 						if(c2ocr.get('Technical').IsPrimary)
 						{PR = true;}
 					}
 					
 					
 					
 					contactMap.add(new ContactList(PR, c, SR, TR, BR));
 				}				
 			}
 			return contactMap;
 		}
 		set;
 	}
 	
 	
 	
 	public PageReference processCR(){
 		list<OpportunityContactRole> ocrUpdate = new list<OpportunityContactRole>();
 		list<OpportunityContactRole> ocrDelete = new list<OpportunityContactRole>();
 		
 		for(contactList cl : contactMap){
 			map<string, OpportunityContactRole> c2ocr = ocrMap.get(cl.Contact.Id) == null ? new map<string, OpportunityContactRole>() : ocrMap.get(cl.Contact.Id);
 			
 			if(cl.isSalesRole){
 				OpportunityContactRole ocr = c2ocr.get('Sales');
 				if(ocr == null)
 				{
 					ocr = new OpportunityContactrole(ContactId = cl.Contact.Id, OpportunityId = this.opportunity.Id, Role = 'Sales');
 					ocrUpdate.Add(ocr);
 				}
 			}else{
 				if(c2ocr.get('Sales') != null){
 					ocrDelete.Add(c2ocr.get('Sales'));
 				}
 			}
 			if(cl.isBillingRole){
 				OpportunityContactRole ocr = c2ocr.get('Billing');
 				if(ocr == null)
 				{
 					ocr = new OpportunityContactrole(ContactId = cl.Contact.Id, OpportunityId = this.opportunity.Id, Role = 'Billing');
 					ocrUpdate.Add(ocr);
 				}
 			}else{
 				if(c2ocr.get('Billing') != null){
 					ocrDelete.Add(c2ocr.get('Billing'));
 				}
 			}
 			if(cl.isTechnicalRole){
 				OpportunityContactRole ocr = c2ocr.get('Technical');
 				if(ocr == null)
 				{
 					ocr = new OpportunityContactrole(ContactId = cl.Contact.Id, OpportunityId = this.opportunity.Id, Role = 'Technical');
 					ocrUpdate.Add(ocr);
 				} 					
 			}else{
 				if(c2ocr.get('Technical') != null){
 					ocrDelete.Add(c2ocr.get('Technical'));
 				}
 			}
 			
 			System.debug('####### ocrUpdate' + ocrupdate);
 			System.Debug('####### ocrDelete' + ocrDelete);
 			
 			if(ocrUpdate.size() > 0){
 				upsert ocrUpdate;

 				////////////////////////////
 				///CalloutToObi
 				////////////////////////////
 				for(OpportunityContactrole ocr : ocrUpdate){
 					//OpportunityUtil.UpdatePrimaryContact(ocr.OpportunityId);
 				}
 			}
 			if(ocrDelete.size() > 0){
 				delete ocrDelete;
 			}
 			
 		}
 		
 		pageReference returnPage = new pageReference('/' + this.opportunity.Id);
 		returnPage.setRedirect(true);
 		return returnPage;
 	}
 	public PageReference cancel(){
 		pageReference returnPage = new pageReference('/' + this.opportunity.Id);
 		returnPage.setRedirect(true);
 		return returnPage;
 	}
 	
 	public class contactList{
 		public boolean isPrimary{get;set;}
 		public Contact contact{get;set;}
 		public boolean isSalesRole{get;set;}
 		public boolean isTechnicalRole{get;set;}
 		public boolean isBillingRole{get;set;}
 		
 		public contactList(){
 			isPrimary = false;
 			contact = new Contact();
 			isSalesRole = false;
 			isTechnicalRole = false;
 			isBillingRole = false;
 		}
 		
 		public contactList(Boolean sel, Contact c, boolean isSR, boolean isTR, boolean isBR){
 			isPrimary = sel;
 			contact = new Contact();
 			contact = c;
 			isSalesRole = isSR;
 			isTechnicalrole = isTR;
 			isBillingRole = isBR;
 		}
 		
 		public contactList(Contact c){
 			isPrimary = false;
 			contact = new Contact();
 			contact = c;
 			isSalesrole = false;
 			isTechnicalRole = false;
 			isBillingRole = false;		
 		}
 	}
    
}