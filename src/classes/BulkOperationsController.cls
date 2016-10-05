global  class BulkOperationsController {

    public Relationship__c relationship { get; set; }      
 

    Public Transient  String  soql {get;set;}  
    private ApexPages.StandardSetController setCon{get; set;}  


  //public BulkOperationsController (ApexPages.StandardController controller){
  public BulkOperationsController (){
     
      relationship = new Relationship__c();
    //  searchString = System.currentPageReference().getParameters().get('lksrch');
   //  runSearch();  
  }



  @RemoteAction
   global static void updateRelationshipStatus(List<string> relationIds, string campaignStatus, String RTBNotes, String contactId_Bulk, String RTBReasonCode,
        String NonPotentialReasonCode, String OnHoldReasonCode){
	
      string regExp =  '[/\'/g, ""]';
      string replacement = '';
      string StatusUpdate = campaignStatus;
     
      string updateRTBNotes = RTBNOTes; 
      string updateRTBReasonCode = RTBReasonCode;
      string updateOnHoldReasonCode = OnHoldReasonCode;
      string updateNoPotentialReasonCode = NonPotentialReasonCode;

      
      Id updatecontactId_Bulk = Id.valueOf(contactId_Bulk);

      system.debug('======updateNoPotentialReasonCode========'+ updateNoPotentialReasonCode);
      system.debug('======updateOnHoldReasonCode========'+ updateOnHoldReasonCode);
      system.debug('======updateRTBReasonCode========'+ updateRTBReasonCode);
      system.debug('======campaignStatus========'+ campaignStatus); 
      // var listIdsQuoteRemoved =  listofIds.replace(/\'/g, "") ;
	   
      List<Id> IdListPassed = new  List<Id>();
    	for(integer i =0, j = relationIds.size(); i<j;i++){

      Id convertedId = Id.valueOf(relationIds[i].replaceAll(regExp,replacement));
      //Id.valueOf(a);
      IdListPassed.add(convertedId);
    }
   
    system.debug('=========updatecontactId_Bulk========'+updatecontactId_Bulk);
    system.debug('=========IdListPassed========'+IdListPassed); 
    system.debug('=======relationIds========' + relationIds.size());
    system.debug('=======Does it get here ========');
    system.debug('=========relationIds======='+relationIds);
  //  system.debug('=========resasonCode======='+resasonCode);
     
  //  set<id> ids = new set<id> { '0015000000f4QI2','0015000000f4QI3' };
    system.debug('=======This should return some values======='+database.query('select id,Campaign_Status__c from Relationship__c where id in :IdListPassed'));

      List<Relationship__c> updateRecordStatus = new List<Relationship__c>();
    //  List<Relationship__c> relationList = new List<Relationship__c> ();

     List<Relationship__c> relationList =  [Select Id, Campaign_Status__c from Relationship__c where Id In:IdListPassed];
      Relationship__c relationListContact = new Relationship__c();
     
      /*
     if(updatecontactId_Bulk <> NULL){
        relationListContact =  [Select Authorisation_Contact_for_RTB__c from Relationship__c where RTBContact_Id__c =:updatecontactId_Bulk Limit 1]; 
      }
      */
     
     system.debug('=========relationListContact=========='+relationListContact);
     system.debug('========relationList========'+relationList);

    if(relationIds.size()>0){
     for(integer i=0 ,j=relationList.size(); i<j; i++ ){
      
          Relationship__c updateStatus =  new Relationship__c();
          updateStatus.Id = relationList[i].Id;
          updateStatus.Campaign_Status__c = StatusUpdate;
          
         // updateStatus.On_Hold_Reason__c = resasonCode;

          if(updateRTBReasonCode <> NULL || updateRTBReasonCode <> ''){
          updateStatus.RTB_Reason_Code__c = updateRTBReasonCode;
          }

          if(updateOnHoldReasonCode <>NULL || updateOnHoldReasonCode <> ''){
          updateStatus.On_Hold_Reason__c = updateOnHoldReasonCode;
        }else {
           updateStatus.On_Hold_Reason__c = 'None';
        }
          
          if(updateNoPotentialReasonCode <> NULL || updateNoPotentialReasonCode <>''){
          updateStatus.No_Potential_Reason_Code__c = updateNoPotentialReasonCode;
        }

          updateStatus.RTB_Notes__c = updateRTBNotes;
          if(updatecontactId_Bulk<>NULL){
          updateStatus.Authorisation_Contact_for_RTB__c = updatecontactId_Bulk;
          }



        updateRecordStatus.add(updateStatus);
    
    }
  }
   
    update updateRecordStatus;
  
   }



  /*
  @RemoteAction
    public static String updateRelationships(String operation){
        String result = '';

        if(operation == 'RTB'){
          Relationship__c r1 = new Relationship__c();
          r1.Id = 'a0K3E000000GTrN';
          r1.RTB_Reason_Code__c = 'RTB055 - Request for Information';
          r1.Authorisation_Contact_for_RTB__c = '0033E000004kqSt';

          Relationship__c r4 = new Relationship__c();
          r4.Id = 'a0K3E000000GTrN';
          r4.RTB_Reason_Code__c = 'RTB055 - Request for Information';
          r4.Authorisation_Contact_for_RTB__c = '0033E000004kqSt';

          result =  'RTB Success';

          result =  'RTB Success';
        }

        if(operation == 'On Hold'){
          Relationship__c r2 = new Relationship__c();
          r2.Id = 'a0K3E000000GTrN';
          r2.On_Hold_Reason__c = 'test';
          r2.Authorisation_Contact_for_On_Hold__c = '0033E000004kqSt';
          r2.Off_Hold_Date__c = Date.valueOf('27/08/2016');

          result =  'On Hold Success';

        }

         if(operation == 'No Potential'){
          Relationship__c r3 = new Relationship__c();
          r3.Id = 'a0K3E000000GTrN';
          r3.No_Potential_Reason_Code__c = 'Already live on Tungsten Network with Buyer';
          r3.Authorisation_Contact_for_RTB__c = '0033E000004kqSt';
          
          result =  'No Potential Success';

        }
        return result;
    }

    
     public void runQuery() {
        try {
       campaignRelations = Database.query(soql);
    
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There has been an error. Contact an Administrator!'));
      } 
    }

    
    public PageReference search_CampaignRelationship() {
    
    String strCampaignName = Apexpages.currentPage().getParameters().get('strCampaignName');
     
    soql  = 'SELECT ID,Campaign__r.Name,Supplier_Account__r.Name ,Buyer_Account__r.Name,Campaign_Status__c FROM Relationship__c';

    if (!strCampaignName.equals('') && strCampaignName<>Null)   
    soql += ' where Campaign__r.Name LIKE \''+String.escapeSingleQuotes(strCampaignName)+'%\'';
    
    soql += ' LIMIT 800';

    system.debug('========Does it get here soql==========='+ soql);

  

    campaignRelations = new List<Relationship__c>();
    for(Relationship__c c : Database.query(soql)){
      campaignRelations.add(c);    
     }
    this.setCon = new ApexPages.StandardSetController(campaignRelations);  
    
       for(sObject r: this.setCon.getRecords() ) {          
            Relationship__c rl = (Relationship__c)r;
            cRelation_RowItem row = new cRelation_RowItem(rl,false);

            RowItemList.add(row);
            }  



    runQuery();
    getCampRelations();
  return null;
  //return (new PageReference('/'+currentPageId)); 
  }


 public List<cRelation_RowItem> getCampRelations() {
  system.debug('=========SOQL inside getContracts========='+ SOQL);  
  system.debug('=======setCon in getContracts ======'+ setCon);
  system.debug('=======setCon.getPageSize() in getContracts ======'+ setCon.getPageSize());
     // if(CCWRowItemList == null) {
          
  RowItemList = new List<cRelation_RowItem>();
  if(campaignRelations <> null) {
            for(sObject r: this.setCon.getRecords() ) {          
            Relationship__c rl = (Relationship__c)r;
            cRelation_RowItem row = new cRelation_RowItem(rl,false);

            RowItemList.add(row);
            }            
         }           
     //}
  
    return RowItemList;
   }


    public with sharing class cRelation_RowItem{
        public Relationship__c rel{get;set;}
        public Boolean IsSelected{get;set;}
        public cRelation_RowItem(Relationship__c r, Boolean s){
        this.rel=r;
        this.IsSelected=s;
       }
    }

    */



}