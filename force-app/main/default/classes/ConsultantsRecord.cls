public with sharing class ConsultantsRecord {
     public static List<String> getConsultants(Id employerId){
        if(employerId == null){
            return new List<String>();
        }
        List<String> consultantsList = new List<String>();
        for (Hiring__c hiring : [ SELECT Consultant__r.Name FROM Hiring__c  WHERE Employer__c = :employerId  AND Consultant__c != NULL])
        {
            consultantsList.add(hiring.Consultant__r.Name);
        }
        return consultantsList;
     }
}