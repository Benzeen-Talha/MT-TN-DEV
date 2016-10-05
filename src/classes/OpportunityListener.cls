@RestResource(urlMapping='/OpportunityListener/*')
global class OpportunityListener {

	@HttpPost
    global static string HandlePost()
    {
    	RestRequest request = RestContext.Request;   
        String strPostedData = RestContext.request.requestBody.toString().replaceAll('\n','').replaceAll('\r','');
        Boolean operation_result = false; 
        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(strPostedData); 

		String AAANumber = (String) m.get('aaanumber');
		RecordType isRc = [SELECT Id, Name FROM RecordType WHERE Name = 'Supplier Sales-e-invoicing-IS'];

		Account a = [SELECT Id, Name FROM Account where ID IN (
			SELECT Account__c FROM AAA_Number__c where Name = :AAANumber)];


		//TODO: Check if similar opportunity has been created previously, if yes do not create a duplicate.
		if (a != null){
			AAA_Number__c isAAA = new AAA_Number__c();
			isAAA.Name = 'AAAAA';
			isAAA.Service_Type__c = 'Integrated Solutions';
			isAAA.Account__c = a.Id;
			isAAA.Type__c = 'Supplier';
			isAAA.Admin_Office__c = 'London';
			insert isAAA;

			Opportunity o = new Opportunity();
			o.AAA_Number__c = isAAA.Id;
			o.AccountId = a.Id;
			o.Name = 'Request for IS Upgrade - ' + a.Name;
			//o.Number_of_contact_roles__c = 0;
			o.StageName = 'Schedule First Call';
			o.RecordTypeId = isRc.Id;
			o.CloseDate = Date.today().addMonths(1);
			insert o;

			Relationship__c rel = new Relationship__c();
			rel.Opportunity__c = o.Id;
			rel.Supplier_AAA_Number__c = isAAA.Id;
			rel.Supplier_Account__c = a.Id;
			insert rel;

			return 'New Opportunity has been created.';
		}

		return 'Account based on the AAANumber is not found!';

    }
}