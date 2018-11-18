public with sharing class OpportunityLineItemRescheduler {
    
    public static void updateSchedules (Map<id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
        
        List<OpportunityLineItemSchedule> schedulesToUpdate = new List<OpportunityLineItemSchedule>();        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        List<OpportunityLineItem> opps = [SELECT OpportunityId, (SELECT Id, ScheduleDate FROM OpportunityLineItemSchedules order by ScheduleDate asc) FROM OpportunityLineItem WHERE OpportunityId IN: newMap.keySet()];

        for (OpportunityLineItem oli: opps) {

            Opportunity oldOpp = oldMap.get(oli.OpportunityId);
            Date oldSceduleDate = oldOpp.Update_Schedule_Start_Date__c;
            Date newSceduleDate = newMap.get(oli.OpportunityId).Update_Schedule_Start_Date__c;
            Opportunity newOpp = newMap.get(oli.OpportunityId);

            if((oldSceduleDate == null && newSceduleDate != null) || (oldSceduleDate != newSceduleDate && newSceduleDate != null)) {
                schedulesToUpdate.addAll(OpportunityLineItemRescheduler.updateSchedule(oli.OpportunityLineItemSchedules, newSceduleDate));
            }

            if (newOpp.CloseDate != oldOpp.CloseDate && newOpp.Update_Schedules__c == true) {
                oppMap.put(newOpp.Id, new Opportunity(Id = newOpp.Id, Update_Schedules__c = false));
                schedulesToUpdate.addAll(OpportunityLineItemRescheduler.updateSchedule(oli.OpportunityLineItemSchedules, newOpp.CloseDate));
            }
        }
        update schedulesToUpdate;
        update oppMap.values();
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