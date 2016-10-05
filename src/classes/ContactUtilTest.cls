/**
* @Name:  ContactUtilTest
* @description: Test class for ContactUtil class
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 09/06/16    T.Sotiraki      Created Class   
*09/09/2016   M Talha         Updated Class  
*/
@isTest
private class ContactUtilTest {
    
    @isTest static void contactUtilTestMethod() {

        TungstenTestDataFactory.createCustomSettingTriggerStatus();
        TungstenTestDataFactory.createCustomSetting();
        TungstenTestDataFactory.createPricebookentry();

        test.startTest();

        ContactUtil contUtil = new ContactUtil();


        Test.setMock(HttpCalloutMock.class, new MockObjects());
        
        User u = new User (LastName = 'Integration', FirstName = 'Sales', IsActive=true, Email = 'test.smo2@tungsten-network.com', Alias='sinte', UserName='test.smo2@tungsten-network.com.temp', 
                CommunityNickName='sinte2', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', ProfileId = UserInfo.getProfileId());
        insert u;
      

        User runningUser = [Select Id, Email From User Where Id = :U.Id];
        
        Account A1 = New Account();
        A1.Name = 'First Call Account Name';
        A1.OBI_Entity_Id__c = '3325617';
        insert A1;
    
         contact c = new contact();
         c.FirstName = 'Test Cont';
         c.LastName = 'Test Cont Last Name';
         c.Title = 'Mr';
         c.Email = 'Joe.Blog@tungsten.com';
         c.Fax = '0002223456';
         c.HomePhone  = '07689865478';
         c.Salutation = 'PM';
         c.Phone = '078675123456';
         c.AccountId = A1.Id;
         c.MobilePhone =  '07689865478';     
         insert c;

         
        //Contact C = TungstenTestDataFactory.utilityContact();


         list<Contact> lstCont = new List<Contact>();
         
         for(integer i=0,j=300;i<j;i++){
         Contact c1 = new Contact();
           
         c1.FirstName = 'Test Cont' + i;
         c1.LastName = 'Test Cont Last Name' +i;
         c1.Title = 'Mr';
         c1.Email = 'Joe.Blog@tungsten.com';
         c1.Fax = '0002223456';
         c1.HomePhone  = '07689865478';
         c1.Salutation = 'PM';
         c1.Phone = '078675123456';
         c1.AccountId = A1.Id;
         c1.MobilePhone =  '07689865478';     
         lstCont.add(c1);
         }
         insert lstCont;

         contact c2 = new contact();
         c2.FirstName = 'Test Cont';
         c2.LastName = 'Test Cont Last Name';
         c2.Title = Null;
         c2.Email = Null;
         c2.Fax = Null;     
         c2.HomePhone  = Null;
         c2.Salutation = Null;
         c2.Phone = NULL;
         c2.AccountId = A1.Id;
         c2.MobilePhone =  Null;      
         insert c2;
    

         contact c3 = new contact();
         c3.Id =  c.Id;
         c3.Email = 'Joe2.Blog@tungsten.com';
         update c3;

         contact c4 = new contact();
         c4.Id = c2.Id;
         c4.Email = 'Joe.Blog5@tungsten.com';
         c4.Phone = '09876789000';
         update c4;

         delete c4;



        ContactUtil.updateDomainList(lstCont);

        test.stopTest();


        // Implement test code
    }
    

    
}