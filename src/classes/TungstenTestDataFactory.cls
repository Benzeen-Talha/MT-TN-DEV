/**
* @Name:  TungstenTestDataFactory
* @description: Test data factory class for Tungsten SF implementation
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 09/06/16    T.Sotiraki      Created Class   
* 18/07/16	
*/
@isTest
public with sharing class TungstenTestDataFactory {
	


	/**
	 * [createAAANumber description]
	 * @param  name      [description]
	 * @param  accountId [description]
	 * @param  type      [description]
	 * @return           [description]
	 */
	public static AAA_Number__c createAAANumber(String name, Id accountId, String type){

			AAA_Number__c a = new AAA_Number__c();
			a.Type__c = type;
			a.Account__c = accountId;
			a.Name = name;


		return a;

	}
	public static void createPricebookentry(){
		//Create all the products first
		List<Product2> productlist = new List<Product2>();
		productlist.Add(new Product2(Name='Analytics', IsActive=true));
		productlist.Add(new Product2(Name='Archiving', IsActive=true));
		productlist.Add(new Product2(Name='Buyer Role Other', IsActive=true));
		productlist.Add(new Product2(Name='Corporate', IsActive=true));
		productlist.Add(new Product2(Name='Data Present', IsActive=true));
		productlist.Add(new Product2(Name='Digital Signature Verification', IsActive=true));
		productlist.Add(new Product2(Name='e-Invoicing', IsActive=true));
		productlist.Add(new Product2(Name='IDC', IsActive=true));
		productlist.Add(new Product2(Name='Image Only', IsActive=true));
		productlist.Add(new Product2(Name='Integrated Solutions', IsActive=true));
		productlist.Add(new Product2(Name='Integration', IsActive=true));
		productlist.Add(new Product2(Name='ISS Lmited', IsActive=true));
		productlist.Add(new Product2(Name='ISS4ALL - global', IsActive=true));
		productlist.Add(new Product2(Name='ISS4ALL - In Geo-scope', IsActive=true));
		productlist.Add(new Product2(Name='Live PO upload', IsActive=true));
		productlist.Add(new Product2(Name='Pattern Match', IsActive=true));
		productlist.Add(new Product2(Name='PO Delivery', IsActive=true));
		productlist.Add(new Product2(Name='TEP', IsActive=true));
		productlist.Add(new Product2(Name='Tungsten WF Bundle', IsActive=true));
		productlist.Add(new Product2(Name='Web Form', IsActive=true));
		insert productlist;
		
		//create all the pricebooks
		List<Pricebook2> pbList = new List<Pricebook2>();
		pbList.Add(new PriceBook2(Name='5011 - GBP', Description='GBP', isActive=true, Country_Code__c='GB', Sales_Type__c='Supplier'));
		pbList.Add(new PriceBook2(Name='5086 - USD', Description='USD', isActive=true, Country_Code__c='US', Sales_Type__c='Supplier'));
		pbList.Add(new PriceBook2(Name='5101 - AUD', Description='AUD', isActive=true, Country_Code__c='', Sales_Type__c='Supplier'));
		pbList.Add(new PriceBook2(Name='5136 - EUR', Description='EUR', isActive=true, Country_Code__c='', Sales_Type__c=''));
		pbList.Add(new PriceBook2(Name='5141 - CAD', Description='CAD', isActive=true, Country_Code__c='', Sales_Type__c='Supplier'));
		pbList.Add(new PriceBook2(Name='UK - GBP', Description='', isActive=true, Country_Code__c='GB', Sales_Type__c=''));
		pbList.Add(new PriceBook2(Name='US - USD', Description='', isActive=true, Country_Code__c='US', Sales_Type__c=''));
		insert pbList;
		
		//Create Standard pricebook
		//Set the standard price book entry
		List<PricebookEntry> spbeList = new List<PricebookEntry>();
		for(Product2 p: productList)
		{
			PricebookEntry pbe = new PricebookEntry();
			pbe.IsActive = true;
			pbe.CurrencyIsoCode = 'GBP';
			pbe.UnitPrice = 100.00;
			pbe.Pricebook2Id = Test.getStandardPricebookId();
			pbe.Product2id = p.Id;
			
			spbeList.Add(pbe);
		}
		insert spbeList;
		
		
		
	}
	
	public static void createCustomSetting(){
		
		List<OBISyncSettings2__c> obiList = new List<OBISyncSettings2__c>();
		obiList.Add(new OBISyncSettings2__c(Name='AAAPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='AAA', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));		
		obiList.Add(new OBISyncSettings2__c(Name='AAAMerge',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Account', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='AccountPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Account', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='AccountMerge',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Account', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='AccountPut',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Account', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='CampaignDelete',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='CampaignMember', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='CampaignMemberDelete',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='CampaignMember', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='CampaignMemberPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='CampaignMember', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='CampaignPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Campaign', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='CampaignPut',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Campaign', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='CommercialInfoPut',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Opportunity', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='ContactDelete',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Contact', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='ContactPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Contact', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='ContactPut',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Contact', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='CreateEntity',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Account', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='CreateWebFormLinkPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Opportunity', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='CTALinkPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Account', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='EntityPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Account', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='OffHoldPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='OnHoldPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='OpportunityPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Opportunity', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='OpportunityPut',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Opportunity', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='RelationshipPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='CampaignRelationshipPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='RelationshipPut',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='ReleaseToImplementationPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='RTBPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
		obiList.Add(new OBISyncSettings2__c(Name='SalePost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
        obiList.Add(new OBISyncSettings2__c(Name='PrimaryContactPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Opportunity Contact', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	obiList.Add(new OBISyncSettings2__c(Name='TariffPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Opportunity Line', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
        obiList.Add(new OBISyncSettings2__c(Name='CompleteTaskSalePost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Opportunity', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
        obiList.Add(new OBISyncSettings2__c(Name='NoPotentialPost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Relationship', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
        obiList.Add(new OBISyncSettings2__c(Name='NotePost',EndPoint__c='https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/',Content_Type__c='application/json', object__c='Notes and Attachment', Authorisation__c = 'Basic TWVzc2FnZVJlY2l2ZXJTZXJ2aWNlOlFqOEV2c3ZUajhB', Method__c='POST'));
    	insert obiList;
	}
    
    	public static void createCustomSettingTriggerStatus(){		
		List<TriggersActive__c> triggerStatus = new List<TriggersActive__c>();
		triggerStatus.Add(new TriggersActive__c(Name='EventTrigger',Value__c=True));		
    	insert triggerStatus;
	}
    
     	public static void createCustomSettingBusinessHours(){		
		List<SalesBusibessHours__c> bh = new List<SalesBusibessHours__c>();
		bh.Add(new SalesBusibessHours__c(Name='FirstCallDays',Value__c=10));
        bh.Add(new SalesBusibessHours__c(Name='WorkingHours',Value__c=7));   
    	insert bh;
	}

	public static Account createSupplierAccount(String name){

			
			Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
 			Account acc = new Account(Name=name, Invoice_value__c=999, Invoice_Volume__c=999, Vendor_Code__c='999', VAT_Registration_Number__c='888',
        							RecordtypeId=supplierRecordTypeId, BillingStreet='test', BillingPostalCode='test', BillingStateCode='CA', BillingCity='test',
        							BillingcountryCode='US', Share_of_Capital__c='test', type_of_Company__c='Test', Number_and_Court_of_Registration__c = 'test',
        							Town_of_Registration__c = 'test', Chairman__c = 'test', Chairman_of_the_Board__c = 'test', Liable_Company__c = 'test',
        							Business_Style__c = 'test', Profession__c = 'test', Tax_Regime__c = 'test', Liquidator_Name__c = 'test', 
        							Early_Payment_Discount__c = '1', Late_Payment_Penalty__c = 'test', Permit_Number__c = '1', 
        							Period_Start_Date__c = date.newInstance(2017, 3, 21), Certification_Number__c = '1', Has_Certification_Number__c = TRUE,
        							OBI_Entity_Id__c = '123456');
        							
		return acc;

	}

	public static Account createBuyerAccount(String name){

			Account a = new Account();

			////////////////////////////
			///Set Record Type Id
			////////////////////////////
			Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Buyer').getRecordTypeId();
 			a.RecordTypeId = supplierRecordTypeId;

			a.Name = name;
			a.Type = 'Customer';


		return a;

	}
    
    public static Opportunity createBuyerOpportunity(){
    	Opportunity o = new Opportunity();
        o.Account = TungstenTestDataFactory.createBuyerAccount('Test Account');
        o.CloseDate = Date.today();
        o.Name = 'Test Opportunity';
        o.AAA_Number__c = TungstenTestDataFactory.createAAANumber('AAA000000001', o.Account.Id, 'Buyer').Id;
        return o;
    }
    
    
    public static Contact createSupplierContact(){
        Contact c= new Contact();
        c.FirstName = 'John';
        c.LastName = 'Doe';
        c.Email = 'John.Doe@test.com';
        c.Account = TungstenTestDataFactory.createSupplierAccount('Test Seller Account');
        c.Phone = '0123456789';
        c.Fax = '0123456789';
        c.Department__c = 'IT';
        
        return c;
        
    }
    
       
    public static Contact createBuyerContact(){
    	Contact c= new Contact();
        c.FirstName = 'John';
        c.LastName = 'Doe';
        c.Email = 'John.Doe@test.com';
        c.Account = TungstenTestDataFactory.createBuyerAccount('Test Seller Account');
        c.Phone = '0123456789';
        c.Fax = '0123456789';
        c.Department__c = 'IT';
        
        return c;
        
    }
    
    public static void createOBISyncSettings(){
    	
    	List<OBISyncSettings2__c> newList = new List<OBISyncSettings2__c>();
    	newList.Add(new OBISyncSettings2__c(Name='CampaignDelete', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/campaign/{campaignId}/', Method__c = 'DELETE', Object__c = 'CampaignMember', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='CTALinkPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/sale/{saleId}/createctalink/', Method__c = 'POST', Object__c = 'Account', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='CampaignMemberDelete', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/campaign/{campaignId}/member/{memberId}', Method__c = 'DELETE', Object__c = 'CampaignMember', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='AccountPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/', Method__c = 'POST', Object__c = 'Account', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='AccountPut', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/{entityId}/', Method__c = 'PUT', Object__c = 'Account', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='ContactPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/account/{accountId}/contact/', Method__c = 'POST', Object__c = 'Contact', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='CreateWebFormLinkPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/sale/{SaleId}/createwflink/', Method__c = 'POST', Object__c = 'Opportunity', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='ContactDelete', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/account/{accountId}/contact/{contactId}', Method__c = 'DELETE', Object__c = 'Contact', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='ContactPut', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/account/{accountId}/contact/{contactId}', Method__c = 'PUT', Object__c = 'Contact', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='RelationshipPut', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/account/{accountId}/relationship/{relationshipId}/', Method__c = 'PUT', Object__c = 'Relationship', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='CommercialInfoPut', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/account/{accountId}/commercialinfo/', Method__c = 'PUT', Object__c = 'Opportunity', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='CampaignPut', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/campaign/{campaignId}', Method__c = 'PUT', Object__c = 'Campaign', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='CampaignPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/campaign/', Method__c = 'POST', Object__c = 'Campaign', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='SalePost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/sale/', Method__c = 'POST', Object__c = 'Opportunity', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='CreateEntity', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/merge', Method__c = 'POST', Object__c = 'Account', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='EntityPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{userId}/entity/', Method__c = 'POST', Object__c = 'Account', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='OpportunityPut', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{UserId}/sale/{SaleId}', Method__c = '', Object__c = 'Opportunity', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='OnHoldPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{SaleId}/campaign/{CampaignId}/onhold/', Method__c = 'POST', Object__c = 'Relationship', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='ReleaseToImplementationPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{UserId}/releasetoimp/', Method__c = 'Relationship', Object__c = '', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='OffHoldPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{SaleId}/campaign/{CampaignId}/offhold/', Method__c = 'POST', Object__c = 'Relationship', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='RelationshipPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{AccountId}/relationship/{relationshipId}/', Method__c = 'POST', Object__c = 'Relationship', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='AccountMerge', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{UserId}/account/merge', Method__c = '', Object__c = 'Account', Authorisation__c = 'Basic Temp')); 
    	newList.Add(new OBISyncSettings2__c(Name='AAAPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{UserId}/account/', Method__c = 'POST', Object__c = 'AAA', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='OpportunityPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{UserId}/sale/', Method__c = 'POST', Object__c = 'Opportunity', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='CampaignMemberPost', Content_Type__c = 'application/json', Endpoint__c = 'https://vapour-dev.tungsten-network.com/api/v1/user/{UserId}/campaign/{CampaignId}/campaignmember/', Method__c = 'POST', Object__c = 'CampaignMember', Authorisation__c = 'Basic Temp'));
    	newList.Add(new OBISyncSettings2__c(Name='RTBPost', Content_Type__c = 'application/json', Endpoint__c = '', Method__c = 'POST', Object__c = 'Relationship', Authorisation__c = 'Basic Temp'));
    	
    	
    	
    	insert newList;
    }
    
       
    public static void createCampaing(){
    	Campaign cm = new Campaign(Name = 'Test Campaign', IsActive = true, RecordTypeId = '01258000000ISllAAG', StartDate = Date.Today(), EndDate = Date.Today().AddDays(30), Status='Active');
    	
    }

        public static Opportunity createFirstCallOpportunity(String FirstCallOppName, String RecordTypeName){

  		AccountUtil acctUtil = new AccountUtil();
  		// AccountUtil.createOBIJSONMessageRequest(a.Id, 'AccountPut'); 
   		recordType oppRT = [Select Id from RecordType where SobjectType = 'Opportunity' and  developerName = 'Integrated_Solutions_Sales'];
        
        Account AO = new Account();
        AO.Name = 'First Call Account Name';
        AO.BillingCountry = 'United Kingdom';
        AO.Vat_Registration_Number__c = 'AB547642';
        AO.Company_Registration_Number__c = '1234567890';

        Insert AO;
        
        
    	//   Account AO = createSupplierAccount('First Call Account Name');
      // insert AO;

        AAA_Number__c AA1 = new AAA_Number__c();
    	AA1.Name = 'AAA115075913';
    	AA1.Account__c = AO.Id;
    	AA1.Type__c = 'Supplier';
    	insert AA1;
    	
 		
    	Opportunity o = new Opportunity();
    	o.AAA_Number__c = AA1.Id;    		
        o.Name = FirstCallOppName;
        o.CloseDate = Date.today();
        o.Name = FirstCallOppName;
        o.ownerId = UserInfo.getUserId();
        o.StageName = 'Schedule First Call';
        //o.CreatedDate = System.Now();    
        o.RecordTypeId = oppRT.Id;//Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        return o;
    	
    }
    

    public static Event createFirtCallEvent(String Subject, DateTime e_startDatetime, DateTime e_endDatetime, Id e_WhatId ){
			Event e = new Event();
			e.Subject = Subject;
			e.StartDateTime = e_startDatetime;
			e.EndDateTime = e_endDatetime;
			e.WhatId = e_whatId;
		return e;

	}
    
    public static Opportunity createSupplerOpportunity(Id Accountid, Id AAANumberId, String Name, String Type){
    	Id SupplierRecordtypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Buyer Sales').getRecordTypeId();
    	Opportunity opp = new Opportunity(Name = Name, AAA_Number__c = AAANumberId, StageName = 'Schedule Fist Call', CloseDate = Date.today(), Type = Type,
        							AccountId = Accountid, RecordTypeId = SupplierRecordtypeId, Description='Test', Campaign_type__c = 'Integrated Solution');
        							opp.OBI_Sale_Id__c = 123456789;
        
        return opp;
    }
    
    public static Opportunity createSupplierOpportunity(id AccountId, string name, string Type){
		
		Id SupplierRecordtypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Buyer Sales').getRecordTypeId();
		Campaign campaign = new Campaign(Name='Test Campaign', type='managed', Number_of_Contacts__c = 33, Status = 'In Progress');
		insert campaign;
		Opportunity o = new Opportunity(Name = name, AccountId = AccountId, Type = Type, RecordTypeId = SupplierRecordTypeId, StageName = 'Lead', CloseDate = Date.Today(), CampaignId = campaign.Id);
		
		System.Debug(o);
		
		return o;
	}



 public static Opportunity interactionLog_Opportunity(String FirstCallOppName, String RecordTypeName){

       Account A1 = New Account();
        A1.Name = 'First Call Account Name';
        insert A1;

        AAA_Number__c AA2 = new AAA_Number__c();
        AA2.Name = 'AAA115075913';
        AA2.Account__c = A1.Id;
        AA2.Type__c = 'Supplier';
        insert AA2;
        

        Opportunity O3 = New Opportunity();
        O3.ownerId = UserInfo.getUserId();
        O3.Name = 'Test Opt O3';
        O3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        O3.AccountId = A1.Id;
        O3.Type = 'Existing Business';      
        O3.StageName = 'Schedule First Call';
        O3.CurrencyIsoCode = 'GBP';
        O3.CloseDate = System.today().addDays(10);
        O3.AAA_Number__c = AA2.Id;
        return O3;

	}

		 public static Contact interactionLog_Contact(String AccountId){

	 	Contact C1 = new Contact();
	 	C1.OBI_CTA_Link__c = 'https://sandbox.ob10.com:2002/dmz/shorturl.ashx?sc=1J08PUCL';
	 	C1.OBI_Contact_ID__c = '1231234';

	 	C1.FirstName = 'Say my name';
	 	C1.LastName = 'Say my name';
	 	C1.AccountID = AccountId;
	 
	 	C1.Gender__c = 'Male';
	 	c1.Phone = '07865456789';
	 	C1.Email = 'test@salesforce.com';
	 	return C1;


	 }

	  	 public static Relationship__c interactionLog_Relationship(String SupAccountId, String BuyAcId, String CampaignId, String OppId){

	 	Relationship__c R1 = new Relationship__c();

	 	//R1.Buyer_AAA_Number__c = '';
	 	R1.Buyer_Account__c = BuyAcId;
	 	R1.Supplier_Account__c = SupAccountId;
	 	R1.Campaign_Status__c = 'In Sales';
	 	R1.Campaign__c = CampaignId;
	 	R1.OBI_Relationship_Id__c = 'A12334444';
	 	R1.Opportunity__c = OppId;
	 	R1.Relationship_Status__c = 'In Sales';
	 	R1.Vendor_Code__c = '66669999';

	 	return R1; 	

	 }


	 	public static Contact utilityContact(){
	 		Account A0 = createSupplierAccount('Utility Account');
	 		Insert A0;
	 		Account A10 = new Account();
	 		A10.Id = A0.Id;
	 		A10.OBI_Entity_Id__c = '3325617';
	 		update A10;

		     contact c = new contact();
	         c.FirstName = 'Test Cont';
	         c.LastName = 'Test Cont Last Name';
	         c.Title = 'Mr';
	         c.Email = 'Joe.Blog@tungsten.com';
	         c.Fax = '0002223456';
	         c.HomePhone  = '07689865478';
	         c.Salutation = 'PM';
	         c.Phone = '078675123456';
	         c.AccountId = A10.Id;
	         c.MobilePhone =  '07689865478';     
	         return c;
		}

    
    
}