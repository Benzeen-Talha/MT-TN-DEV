@isTest
private class LeadTriggerTEST {

    static testMethod void myUnitTest() {
        
        Lead testLead = new LEad(LastName = 'Test Lead', Email = 'g@G.com', Company = 'Forsa', Status = 'Sales Qualified Lead', ERP__c = 'Baan', Number_of_invoices_sent_per_year__c = '50,000 - 100,000', Project_in_Place__c = 'Yes', With_BPO__c = 'Yes', Workflow__c = 'Yes');
        
        Insert testLead;
        
        testLead.Email = 'graeme@G.com';
        
        update testLead;
        
    }
}