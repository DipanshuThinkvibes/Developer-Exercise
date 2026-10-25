trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete){

    if (Trigger.isBefore) {
        if(Trigger.isInsert ){
            ContactTriggerHandler.beforeInsert(Trigger.new);
        } 
        if(Trigger.isUpdate){
            ContactTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
        }

    }

}