/**
 */
public with sharing class ProcessBuilder {
	
	@InvocableMethod
	public static void calculateConfirmedRelationship(List<Opportunity> opportunity){
		
		if(opportunity == null)
		{
			opportunity = new List<Opportunity>();
		}
		
		map<Id, Opportunity> oppMap = new map<Id, Opportunity>();
		List<Opportunity> oppToUpdate = new List<Opportunity>();
		
		for(Opportunity o: opportunity){
			oppMap.put(o.Id, o);
		}
		
		map<Id, map<id, Relationship__c>> relMapbyOpp = new map<id, map<id, Relationship__c>>();
		
		for(Relationship__c r: [Select Id, Name, Opportunity__c, confirmed__c From Relationship__c Where Opportunity__c IN: oppMap.Keyset()])
		{
			map<id, Relationship__c> relMap = relMapByOpp.get(r.Opportunity__c);
			if(relMap == null)
				relMap = new map<id, Relationship__c>();
			relMap.put(r.Id, r);
			
			relMapbyOpp.put(r.Opportunity__c, relMap);
		}
		
		for(Opportunity o: oppMap.Values()){
			
			map<Id, Relationship__c> relMap = relMapbyOpp.get(o.Id);
			integer i = 0;
			for(Relationship__c r: relMap.values()){
				if(r.Confirmed__c)
					i++; 
			}
			
			if(o.Confirmed_Relationships__c != i)
			{
				o.Confirmed_Relationships__c = i;
				oppToUpdate.Add(o);
			}
		}
		
		update oppToUpdate;
		
	}
    
}