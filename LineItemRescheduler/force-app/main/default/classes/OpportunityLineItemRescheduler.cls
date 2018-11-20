public with sharing class OpportunityLineItemRescheduler {
    
    public static void updateSchedules (Map<id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        
        List<OpportunityLineItemSchedule> schedulesToUpdate = new List<OpportunityLineItemSchedule>();        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        List<OpportunityLineItem> oppLineItems = [SELECT Opportunity.Update_Schedules_With_Close_Date__c, OpportunityId,  (SELECT Id, ScheduleDate FROM OpportunityLineItemSchedules order by ScheduleDate asc) FROM OpportunityLineItem WHERE OpportunityId IN: newMap.keySet()];

        if(!oppLineItems.isEmpty()){
            
            for (OpportunityLineItem oli: oppLineItems) {
                
                Opportunity oldOpp = oldMap.get(oli.OpportunityId);
                Date oldSceduleDate = oldOpp.Update_Schedule_Start_Date__c;
                Date newSceduleDate = newMap.get(oli.OpportunityId).Update_Schedule_Start_Date__c;
                Opportunity newOpp = newMap.get(oli.OpportunityId);
                
                if(!oli.OpportunityLineItemSchedules.isEmpty()) {
                    
                    if((oldSceduleDate == null && newSceduleDate != null) || (oldSceduleDate != newSceduleDate && newSceduleDate != null) && oli.Opportunity.Update_Schedules_With_Close_Date__c == false) {
                        schedulesToUpdate.addAll(OpportunityLineItemRescheduler.updateSchedule(oli.OpportunityLineItemSchedules, newSceduleDate));
                    } else if (newOpp.Update_Schedules_With_Close_Date__c == true) {
                        oppMap.put(newOpp.Id, new Opportunity(Id = newOpp.Id, Update_Schedules_With_Close_Date__c = false, Update_Schedule_Start_Date__c = null));
                        schedulesToUpdate.addAll(OpportunityLineItemRescheduler.updateSchedule(oli.OpportunityLineItemSchedules, newOpp.CloseDate));
                    }
                } else if( newOpp.Update_Schedules_With_Close_Date__c == true ) {
                    oppMap.put(newOpp.Id, new Opportunity(Id = newOpp.Id, Update_Schedules_With_Close_Date__c = false, Update_Schedule_Start_Date__c = null));
                }
            }
            update oppMap.values();
            update schedulesToUpdate;
        } else {
            
            for(Opportunity o : newMap.values()) {
                
                if( o.Update_Schedules_With_Close_Date__c == true ) {
                    
                    oppMap.put(o.Id, new Opportunity(Id = o.Id, Update_Schedules_With_Close_Date__c = false, Update_Schedule_Start_Date__c = null));
                }
            }
            update oppMap.values();
        }
    }

    public static List<OpportunityLineItemSchedule> updateSchedule(List<OpportunityLineItemSchedule> schedules, Date newScheduleDate) {
        
        OpportunityLineItemSchedule firstSchedule = schedules[0];
        Integer dayDiff = firstSchedule.ScheduleDate.daysBetween(newScheduleDate);
        List<OpportunityLineItemSchedule> schedulesToUpdate = updateServiceDates(schedules, dayDiff);
        
        return schedulesToUpdate;        
    }

    public static List<OpportunityLineItemSchedule> updateServiceDates(List<OpportunityLineItemSchedule> schedulesToUpdate, Integer dayDiff) {
        
        List<OpportunityLineItemSchedule> updatedSchedules = new List<OpportunityLineItemSchedule>();
        for(OpportunityLineItemSchedule oLIS : schedulesToUpdate) {
            oLIS.ScheduleDate = oLIS.ScheduleDate.addDays(dayDiff);
            updatedSchedules.add(oLIS);
        }
        return updatedSchedules;
    }
}