public with sharing class EmployerRecord {
    public static Map<Id,Set<Id>> getEmployer(){
        
        Map<Id,Set<Id>> employerMap = new Map<Id,Set<Id>>();
        for (Hiring__c hiring : [ SELECT Employer__c, Consultant__c FROM Hiring__c  WHERE Consultant__c != NULL])
        {
            if(!employerMap.containsKey(hiring.Employer__c)){
                employerMap.put(hiring.Employer__c,new Set<Id>());
            }
            employerMap.get(hiring.Employer__c).add(hiring.Consultant__c);
        }
        return employerMap;
    }
}