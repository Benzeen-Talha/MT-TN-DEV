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
      string regExpDQ =  '[/\"/g, ""]';
      string replacement = '';
      string StatusUpdate = campaignStatus;
     
      string updateRTBNotes = RTBNOTes; 
      string updateRTBReasonCode = RTBReasonCode;
      string updateOnHoldReasonCode = OnHoldReasonCode;
      string updateNoPotentialReasonCode = NonPotentialReasonCode;
        
       
      Id updatecontactId_Bulk = Id.valueOf(contactId_Bulk);

       // Id updatecontactId_Bulk = Id.valueOf(contactId_Bulk.replaceAll(regExpDQ,replacement));
      // Id updatecontactId_Bulk_OnHold = Id.valueOf(contactId_Bulk_OnHold);
    //  Id updatecontactId_Bulk_OnHold = Id.valueOf(contactId_Bulk_OnHold.replaceAll(regExpDQ,replacement));

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

          if(updatecontactId_Bulk<>NULL || updatecontactId_Bulk <> ''){
          updateStatus.Authorisation_Contact_for_RTB__c = updatecontactId_Bulk;
          }

        /*
          if(updatecontactId_Bulk_OnHold<>NULL || updatecontactId_Bulk_OnHold <> ''){
            updateStatus.Authorisation_Contact_for_On_Hold__c = updatecontactId_Bulk_OnHold;
          }
        */

        updateRecordStatus.add(updateStatus);
    
     }
    }  
    update updateRecordStatus;
  
   }

 @RemoteAction
   global static void updateRelationshipStatusOnHold(List<string> relationIds, string campaignStatus, String RTBNotes, String contactId_Bulk_OnHold, String RTBReasonCode,
        String NonPotentialReasonCode, String OnHoldReasonCode){

      string regExp =  '[/\'/g, ""]';
      string regExpDQ =  '[/\"/g, ""]';
      string replacement = '';
      string StatusUpdate = campaignStatus;
     
      string updateRTBNotes = RTBNOTes; 
      string updateRTBReasonCode = RTBReasonCode;
      string updateOnHoldReasonCode = OnHoldReasonCode;
      string updateNoPotentialReasonCode = NonPotentialReasonCode;
        
       
      Id updatecontactId_Bulk = Id.valueOf(contactId_Bulk_OnHold);

       // Id updatecontactId_Bulk = Id.valueOf(contactId_Bulk.replaceAll(regExpDQ,replacement));
      // Id updatecontactId_Bulk_OnHold = Id.valueOf(contactId_Bulk_OnHold);
    //  Id updatecontactId_Bulk_OnHold = Id.valueOf(contactId_Bulk_OnHold.replaceAll(regExpDQ,replacement));

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

          if(updatecontactId_Bulk<>NULL || updatecontactId_Bulk <> ''){
          updateStatus.Authorisation_Contact_for_On_Hold__c = updatecontactId_Bulk;
          }

        /*
          if(updatecontactId_Bulk_OnHold<>NULL || updatecontactId_Bulk_OnHold <> ''){
            updateStatus.Authorisation_Contact_for_On_Hold__c = updatecontactId_Bulk_OnHold;
          }
        */

        updateRecordStatus.add(updateStatus);
    
     }
    }  
    update updateRecordStatus;
  
   }






 @RemoteAction
   global static void updateRelationshipStatusNoPotential(List<string> relationIds, string campaignStatus, String RTBNotes, String contactId_Bulk, String RTBReasonCode,
        String NonPotentialReasonCode, String OnHoldReasonCode){

      string regExp =  '[/\'/g, ""]';
      string regExpDQ =  '[/\"/g, ""]';
      string replacement = '';
      string StatusUpdate = campaignStatus;
     
      string updateRTBNotes = RTBNOTes; 
      string updateRTBReasonCode = RTBReasonCode;
      string updateOnHoldReasonCode = OnHoldReasonCode;
      string updateNoPotentialReasonCode = NonPotentialReasonCode;
        
       
      Id updatecontactId_Bulk = Id.valueOf(contactId_Bulk);

       // Id updatecontactId_Bulk = Id.valueOf(contactId_Bulk.replaceAll(regExpDQ,replacement));
      // Id updatecontactId_Bulk_OnHold = Id.valueOf(contactId_Bulk_OnHold);
    //  Id updatecontactId_Bulk_OnHold = Id.valueOf(contactId_Bulk_OnHold.replaceAll(regExpDQ,replacement));

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

          if(updatecontactId_Bulk<>NULL || updatecontactId_Bulk <> ''){
          updateStatus.Authorisation_Contact_for_No_Potential__c = updatecontactId_Bulk;
          }

        /*
          if(updatecontactId_Bulk_OnHold<>NULL || updatecontactId_Bulk_OnHold <> ''){
            updateStatus.Authorisation_Contact_for_On_Hold__c = updatecontactId_Bulk_OnHold;
          }
        */

        updateRecordStatus.add(updateStatus);
    
     }
    }  
    update updateRecordStatus;
  
   }










}