/**
* @Name:  EventTriggerHelper
* @description: Trigger handler class for Event Object
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 15/07/16    M Talha   Created Trigger   
*/
    

public with sharing class EventTriggerHelper {
    
    public static boolean isFirstRun = True;
    
    public EventTriggerHelper() {}

    public static void FirstCall_Start_End_Date_Opportunity(LIST<Event> triggerNew){
       
      Datetime dateAssigned ; 
      Opportunity eventOppt;   
      RecordType optRTISS;
      RecordType optRTWeb;
      Decimal WorkingHours = SalesBusibessHours__c.getValues('WorkingHours').value__c;
      Decimal FirstCallDays = SalesBusibessHours__c.getValues('FirstCallDays').value__c;
       
       BusinessHours bh = [SELECT Id FROM BusinessHours WHERE name='Sales Team Business Hours' limit 1];
       
       if(triggerNew<>NULL){       
      List<Event> OptEvent = [Select ID,WhatId,StartDateTime,EndDateTime,Subject  from Event where Id=:triggerNew[0].Id];    
            if(OptEvent.size()>0 && OptEvent[0].WhatId <>NULL){
                eventOppt = [Select Id,CreatedDate,CreatedById,RecordTypeId, OwnerId  from Opportunity where Id=:OptEvent[0].WhatId];
                optRTISS = [Select Id from RecordType where SobjectType = 'Opportunity' And DeveloperName = 'Integrated_Solutions_Sales' limit 1];
                optRTWeb = [Select Id from RecordType where SobjectType = 'Opportunity' And DeveloperName = 'Web_Form_Sales' limit 1];
        List<OpportunityFieldHistory> optEventHistory = [SELECT Id,OpportunityId,CreatedDate,Field,NewValue,OldValue FROM OpportunityFieldHistory where Field = 'Owner' and OpportunityId =: eventOppt.Id order by CreatedDate desc limit 1];           
            
            
           if(optEventHistory.size() > 0 && optEventHistory[0].NewValue <> optEventHistory[0].OldValue){
                dateAssigned = optEventHistory[0].CreatedDate;
                System.debug('=======OpportunityFieldHistory Owner Assigned====='+ dateAssigned);
            }else{
              if(eventOppt <>NULL){
              //dateAssigned = triggerNew[0].CreatedDate;
              dateAssigned = eventOppt.CreatedDate;
              System.debug('=======Opportunity Created Date as dateAssigned====='+ dateAssigned);
              }
           }
         }
                   
        if(eventOppt <> NULL){            
        if(eventOppt.RecordTypeId == optRTISS.Id || eventOppt.RecordTypeId ==optRTWeb.Id){
           
            for(Event evt:OptEvent ){         
           /* BusinessHours Class with diff() method calculates time difference in milliseconds */        
           
         //{
           if((BusinessHours.diff(bh.Id,dateAssigned,evt.StartDateTime)/1000/60/60/WorkingHours) > FirstCallDays || (BusinessHours.diff(bh.Id,dateAssigned,evt.EndDateTime)/1000/60/60/WorkingHours) > FirstCallDays){           
          
           System.debug('===========Difference between dateAssigned and StartDate======'+(BusinessHours.diff(bh.Id,dateAssigned,evt.StartDateTime)/1000/60/60/WorkingHours));
           System.debug('===========Difference between dateAssigned and EndDate======'+(BusinessHours.diff(bh.Id,dateAssigned,evt.StartDateTime)/1000/60/60/WorkingHours));
           
           triggerNew[0].addError( System.Label.Opportunity_First_Call_Start_and_End_Date_Error_Message,false);             
            
             }
             else
              if(Date.ValueOf(evt.StartDateTime) < System.Today() || Date.ValueOf(evt.EndDateTime) < System.Today()){ 
                triggerNew[0].addError( System.Label.Opportunity_First_Call_Start_and_End_Date_Restrict_Past_Dates,false); 
             }
          }
       }
      }              
    }  
  }


  
  public static void ScheduleFirstCall_Opportunity_StageStartUpdate(LIST<Opportunity> triggerNew,Map<Id,Opportunity> triggerOldMap){
       isFirstRun = True;
      List<Opportunity> updateOppList =  new List<Opportunity>();

      if(triggerNew.size()>0 && triggerOldMap<>NULL && isFirstRun == True){ 

      //List<Opportunity> sfcOpportunity = [Select Id, StageName from Opportunity where Id=:triggerNew[0].Id ];            
      System.debug('======= Does it Get here for Opportunity stage first call ====='+triggerNew);
     
            for(Opportunity opt:triggerNew ){
               if(triggerOldMap.get(opt.Id).StageName <> opt.StageName && opt.StageName == 'Schedule First Call'){
                  Opportunity objOpt = new Opportunity();
                  objOpt.Id = opt.Id;
                  objOpt.Schedule_First_Call_Stage_Calculation__c = System.Now();
                  
             updateOppList.add(objOpt);
          }

        } 
        isFirstRun = false;
        update updateOppList;

    }
      
  }


  
    public static void ScheduleFirstCall_Opportunity_StageStartInsert(LIST<Opportunity> triggerNew){
       isFirstRun = True;
      List<RecordType> fcRT = [Select Id from RecordType where DeveloperName = 'Integrated_Solutions_Sales' or DeveloperName =  'Web_Form_Sales'] ;
        List<Opportunity> updateOppList =  new List<Opportunity>();

      if(triggerNew.size()>0 && isFirstRun == True){  
      
      //List<Opportunity> sfcOpportunity = [Select Id, StageName from Opportunity where Id=:triggerNew[0].Id and RecordTypeId In: fcRT];       
       System.debug('======= Does it Get here for Opportunity stage first call ====='+triggerNew[0].StageName);
      
            for(Opportunity opt:triggerNew ){
             if(triggerNew.size()>0 && opt.StageName ==  'Schedule First Call'){
                Opportunity objOpt = new Opportunity();
                objOpt.Id = opt.Id;
                objOpt.Schedule_First_Call_Stage_Calculation__c = System.Now();
                updateOppList.add(objOpt);
         
          }

        }
        isFirstRun = false;
        Update updateOppList;
    }
      
  }

  public static void updateOpportunityToFirstCall(List<Event> events){
      
    if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
      
      List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
      Set<Id> opportunityIds = new Set<Id>();
      Set<Id> opportunityIdsForEngaged = new Set<Id>();

      List<Event> newEvents = [Select Id, Subject, Account.Name, WhatId From Event Where Id in :events];
      
      for(Event e : newEvents){
        if(e.Subject == 'First Call With '+ e.Account.Name){
            opportunityIds.add(e.WhatId);
        }
        if(e.Subject == 'First Call' && e.Description != null){
            opportunityIdsForEngaged.add(e.WhatId);
            
        }
      }

      if(opportunityIds.size() > 0){
        List<Opportunity> opps = new List<Opportunity>();

        opps = [Select Id, StageName
                From Opportunity
                Where Id in :opportunityIds];

        if(opps.size() > 0){
          for(Opportunity o : opps){
            if(o.StageName == 'Schedule First Call'){
               o.StageName = 'First Call';
              opportunitiesToUpdate.add(o);
            }
          }
        }
      }

      if(opportunityIdsForEngaged.size() > 0){
        List<Opportunity> opps = new List<Opportunity>();

        opps = [Select Id, StageName
                From Opportunity
                Where Id in :opportunityIdsForEngaged];

        if(opps.size() > 0){
          for(Opportunity o : opps){
            if(o.StageName == 'First Call'){
               o.StageName = 'Engaged';
              opportunitiesToUpdate.add(o);
            }
          }
        }
      }


      if(opportunitiesToUpdate.size() > 0){
        update opportunitiesToUpdate;
      }

    }

      
  }
  




}