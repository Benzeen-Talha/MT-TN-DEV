public with sharing class OpportunityRelationConfirm {
    
    public Opportunity opportunity{
    	get;set;
    }
    
    public OpportunityRelationConfirm(Apexpages.StandardController stdController){
    	this.opportunity = (Opportunity)stdController.getRecord();
    }
    
    public PageReference processRelation(){
    	
    	List<Relationship__c> relToUpdate = new List<Relationship__c>(); 
    	for(tRelation tr: tRelList){
    		if(tr.selected){
   				tr.relation.Confirmed__c = true;
   				relToUpdate.Add(tr.relation); 			
    		}
    	}
    	
    	
    	if(relToUpdate.size() > 0){
    		update relToUpdate;
    	}else{
    		Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR,'Please select atleast one Relation to confirm')); 	
    		return null;
    	}
    	
    	Apexpages.PageReference returnPage = new apexPages.StandardController(opportunity).view();
    	return returnPage;
    }
    
    
    public List<tRelation> tRelList{
    	get{
    		if(tRelList == null){
    			tRelList = new List<tRelation>();
    			for(Relationship__c rel: [Select Id, Name, Confirmed__c, Supplier_Account__r.Name From Relationship__c Where Opportunity__c =: opportunity.Id]){
    				tRelList.add(new tRelation(rel.confirmed__c, rel));
    			}
    		}
    		return tRelList;
    	}
    	set;
    }
    
    public class tRelation{
    	public boolean selected{get;set;}
    	public Relationship__c relation{get;set;}
    	
    	public tRelation(){
    		selected = false;
    		relation = new Relationship__c();
    	}
    	
    	public tRelation(boolean sel, Relationship__c rel){
    		selected = sel;
    		relation = new Relationship__c();
    		relation = rel;
    	}
    }
}