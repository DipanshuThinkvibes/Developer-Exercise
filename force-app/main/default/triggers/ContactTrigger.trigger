trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete){

    if (Trigger.isBefore) {
        if(Trigger.isInsert ){
            ContactTriggerHandler.beforeInsert(Trigger.new);
        } 
    }
    else if(Trigger.isAfter){
        if(Trigger.isUpdate){
            ContactTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.new);
        }
    }

}