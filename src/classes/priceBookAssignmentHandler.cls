/**
* @description: 
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 27/06/16  G.Cameron       Created class
*/

public with sharing class priceBookAssignmentHandler {
    
    public static void priceBookAssignmentSupplierSalesHandler (List <Opportunity> opps){
    
        
        //List & Map generation
        
        List <Id> oppIds = new List <Id>();
        
        for(Opportunity opp : opps){
        
            oppIds.add(opp.Id);
            
        }
        
        List <Opportunity> newOpps = [SELECT Id, Campaign_Type__c, Account.Recordtype.Name, Account.CurrencyIsoCode, Name FROM Opportunity WHERE Id in :oppIds];
    
        //Map <Opportunity, String> oppCountriesMap = new Map <Opportunity, String>();
        
        List <PriceBook2> priceBooks = [SELECT Id, Name, Sales_Type__c, Service_Type__c,  Country_Code__c FROM PriceBook2 WHERE Sales_Type__c = 'Supplier'];
        
        List <tariffMapping__c> tariffMappings = [SELECT Id, Name, WF_Tariff__c , IS_Tariff__c, OBI_Country_Code__c, Ledger__c, Currency__c FROM tariffMapping__c];
        
        List <Id> oppAccs = new List <Id>();
        
        for(Opportunity opp : newOpps){
            
            oppAccs.add(opp.Account.Id);
            
        }
        
        List<Account> oppAccounts = [SELECT Id, Name, BillingCountryCode FROM Account WHERE ID in : oppAccs];
        
        Map <ID, String> accCountryMap = new Map<ID, String>();
        
        for(Account acc : oppAccounts){
            
            accCountryMap.put(acc.Id, acc.BillingCountryCode);
            system.debug('acc country code = ' + acc.BillingCountryCode);
            
        }
        
        //Map <String , PriceBook2> priceBookCountryMap = new Map <String , PriceBook2>();
        
        Map <String , PriceBook2> priceBookTariffMapWF = new Map <String , PriceBook2>();
        
        Map <String , PriceBook2> priceBookTariffMapIS = new Map <String , PriceBook2>();
        
        Map <String , PriceBook2> priceBookTariffNameMapWF = new Map <String , PriceBook2>();
        
        Map <String , PriceBook2> priceBookTariffNameMapIS = new Map <String , PriceBook2>();
        
        Map <String , String> currencyTariffMap = new Map <String , String>();
        
        // *****Product assignment********
        Map <Id , PriceBookEntry> priceBookEntryMapWF = new Map <Id , PriceBookEntry>();
        
        Map <Id , PriceBookEntry> priceBookEntryMapIS = new Map <Id , PriceBookEntry>();
        
        List<PriceBookEntry> PriceBookEntriesIS = new list <PriceBookEntry>();
        
        List<PriceBookEntry> PriceBookEntriesWF = new list <PriceBookEntry>();
        
        List<Id> PriceBookIDsIS = new list <Id>();
        
        List<Id> PriceBookIDsWF = new list <Id>();
        
        List<Product2> productsIS = new List<Product2>();
        
        List<Product2> productsWF = new List<Product2>();
        
        List<ID> productIDsIS = new List<ID>();
        
        List<ID> productIDsWF = new List<ID>();
        
        Map <Id, String> productNameMapIS = new Map<Id, String>();
        
        Map <Id, String> productNameMapWF = new Map<Id, String>();
        
        List<OpportunityLineItem> newOppLines = new List<OpportunityLineItem>();
        
        //delete existing products
        List <OpportunityLineItem> existingLineItems = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.Id in : oppIDs];
        
        delete(existingLineItems);
        // *****Product assignment********
        
        //START OF PROCESS
        
        for(PriceBook2 pB : priceBooks){
            
            for(tariffMapping__c tF : tariffMappings){
                
                if(pB.Name == tF.IS_Tariff__c){
                    
                    priceBookTariffMapIS.put(tF.Name, pB);
                    currencyTariffMap.put(tF.Name, tF.Currency__c);
                    system.debug('IS tariff added to list: ' + pB.Name);
                    // *****Product assignment********
                    PriceBookIDsIS.add(pB.Id);
                    // *****Product assignment********
                  
                 } 
                   
                 if(pB.Name == tF.WF_Tariff__c){
                    
                    priceBookTariffMapWF.put(tF.Name, pB);
                    currencyTariffMap.put(tF.Name, tF.Currency__c);
                    system.debug('WF tariff added to list: ' + pB.Name);
                    // *****Product assignment********
                    PriceBookIDsWF.add(pB.Id);
                    // *****Product assignment********
                    
                    
                }
                
            }
            
        
        }
        
        // *****Product assignment********
        PriceBookEntriesIS = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode  FROM PriceBookEntry WHERE PriceBook2.Id in : PriceBookIDsIS];
        system.debug('PriceBookEntriesIS: ' + PriceBookEntriesIS);
        PriceBookEntriesWF = [SELECT Id, Name, Pricebook2Id, Product2Id, CurrencyIsoCode  FROM PriceBookEntry WHERE PriceBook2.Id in : PriceBookIDsWF];
        system.debug('PriceBookEntriesWF: ' + PriceBookEntriesWF);
        
        for(PriceBookEntry pBE : PriceBookEntriesIS){
            
            priceBookEntryMapIS.put(pBE.Pricebook2Id, pBE);
            productIDsIS.add(pBE.Product2Id);
            
        }
        
        for(PriceBookEntry pBE : PriceBookEntriesWF){
            
            priceBookEntryMapWF.put(pBE.Pricebook2Id, pBE);
            productIDsWF.add(pBE.Product2Id);
            
        }
        
        productsIS = [SELECT Name, Id FROM Product2 WHERE Id in : productIDsIS];
        
        productsWF = [SELECT Name, Id FROM Product2 WHERE Id in : productIDsWF];
        
        for(Product2 prod : productsIS){
            
            productNameMapIS.put(prod.Id, prod.Name);
            
        }
        
        for(Product2 prod : productsWF){
            
            productNameMapWF.put(prod.Id, prod.Name);
            
        }
        
        // *****Product assignment********
        
        //priceBookCountryMap.put(pB.Country_Code__c, pB);
        for(Opportunity opp : newOpps){
        
            if(opp.Account.Recordtype.Name == 'Supplier'){
                
                String countryCode = accCountryMap.get(opp.AccountId);
                
                if(currencyTariffMap.get(countryCode) != null){
                
                    system.debug('currencyTariffMap.get(countryCode) = ' + currencyTariffMap.get(countryCode));
                    opp.CurrencyISOCode = currencyTariffMap.get(countryCode);
                    system.debug('opp.CurrencyISOCode = ' + opp.CurrencyISOCode);
                    
                    /**Migrated to Account specific method
                    opp.Account.CurrencyISOCode = currencyTariffMap.get(countryCode);
                    **/
                    
                }
                
                system.debug('country code = ' + countryCode);
                
                
                if(priceBookTariffMapIS.get(countryCode) != null){
                    
                    if(opp.Campaign_Type__c == 'Integrated Solution'){
                    
                        opp.PriceBook2Id = priceBookTariffMapIS.get(countryCode).Id;
                        system.debug('IS tariff assigned ' + priceBookTariffMapIS.get(countryCode).Name);
                        
                        // *****Product assignment********
                        if(priceBookEntryMapIS.size()>0){
                            
                            system.debug('priceBookEntryMapIS size > 0');
                            system.debug('priceBookEntryMapIS = ' + priceBookEntryMapIS.values());
                            
                            for(PriceBookEntry pBE : priceBookEntryMapIS.values()){
                            
                                if(newOppLines.size() == 0){
                                    
                                    if(productNameMapIS.get(pBE.Product2Id) == priceBookTariffMapIS.get(countryCode).Service_Type__c){
                                        
                                        if(opp.CurrencyIsoCode == pBE.CurrencyIsoCode){
                                        
                                            system.debug('productNameMapIS.get = ' + productNameMapIS.get(pBE.Product2Id) == priceBookTariffMapIS.get(countryCode).Service_Type__c);
                                            system.debug('product id = ' + priceBookEntryMapIS.get(opp.PriceBook2Id).Id);
                                            
                                            OpportunityLineItem oppline = new OpportunityLineItem(OpportunityId = opp.Id, PriceBookEntryId = priceBookEntryMapIS.get(opp.PriceBook2Id).Id);
                                            newOppLines.add(oppline);
                                        
                                        }
                            
                                    }
                                    
                                }
                                
                                
                            
                            }
                            
                        }
                        // *****Product assignment********
                        
                    }
                    
                }
                
                if(priceBookTariffMapWF.get(countryCode) != null){
                    
                    if(opp.Campaign_Type__c == 'Web Form'){
                    
                        opp.PriceBook2Id = priceBookTariffMapWF.get(countryCode).Id;
                        system.debug('WF tariff assigned');
                        
                        // *****Product assignment********
                        if(priceBookEntryMapWF.size()>0){
                            
                            for(PriceBookEntry pBE : priceBookEntryMapWF.values()){
                                
                                if(newOppLines.size() == 0){
                                    
                                    if(productNameMapWF.get(pBE.Product2Id) == priceBookTariffMapWF.get(countryCode).Service_Type__c){
                                        
                                        if(opp.CurrencyIsoCode == pBE.CurrencyIsoCode){
                                    
                                            OpportunityLineItem oppline = new OpportunityLineItem(OpportunityId = opp.Id, PriceBookEntryId = priceBookEntryMapWF.get(opp.PriceBook2Id).Id);
                                            newOppLines.add(oppline);
                                        
                                        }
                            
                                    }
                                    
                                }
                            
                            }
                            
                        }
                        // *****Product assignment********
                        
                    }
                    
                }
                
            }
        
        }
        
        update(newOpps);
        // *****Product assignment********
        insert(newOppLines);
        // *****Product assignment********
    
  }
  
  public static void ledgerAssignmentSupplierSalesHandler (List <Account> accs){
    
        List <tariffMapping__c> tariffMappings = [SELECT Id, Name, Ledger__c, Currency__c FROM tariffMapping__c];
        
        system.debug('in ledgerAssignmentSupplierSalesHandler method');
        
        for(Account a :accs){
            
            for(tariffMapping__c tF : tariffMappings){
                
                system.debug('in ledger assignment loop');
                
                if(a.BillingCountryCode == tF.Name){
                    
                    system.debug('in ledger assignment condition');
                    a.Ledger__c = tF.Ledger__c;
                    system.debug('Ledger = ' + a.Ledger__c);
                    a.CurrencyISOCode = tF.Currency__c;
                    system.debug('Currency = ' + a.CurrencyISOCode);
                    
                }
                
            }
            
        }
    
    }
    
}