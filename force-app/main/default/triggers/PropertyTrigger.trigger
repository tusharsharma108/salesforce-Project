trigger PropertyTrigger on Property__c (before insert, before update, after insert, after update){

    
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            PropertyTriggerHandler.validateFivePropertyPerAgent(Trigger.new);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            PropertyTriggerHandler.updateSalesPrice(Trigger.new);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            PropertyTriggerHandler.updateCommissionsOnApproval(Trigger.new, Trigger.oldMap);
        }
    }
    /*
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            PropertyTriggerHandler.validateUser(Trigger.new);
        }
    }
*/
}