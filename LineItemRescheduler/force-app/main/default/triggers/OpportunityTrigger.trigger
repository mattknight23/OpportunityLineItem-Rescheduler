trigger OpportunityTrigger on Opportunity (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            OpportunityLineItemRescheduler.updateSchedules(Trigger.oldMap, Trigger.newMap);
        }
    }
}