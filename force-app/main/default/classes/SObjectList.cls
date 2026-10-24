public with sharing class SObjectList {
   public static List<String> getObjectList(){
        List<String> objectList = new List<String>();
        for(Schema.SObjectType sobjectType : Schema.getGlobalDescribe().values()){
            objectList.add(sobjectType.getDescribe().getName());
        }
        return objectList;
   }
}