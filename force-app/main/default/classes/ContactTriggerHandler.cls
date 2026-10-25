public with sharing class ContactTriggerHandler {
    public static void beforeInsert(List<Contact> newContacts) {
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> AccountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null && con.Is_Primary__c == true) {
                AccountIds.add(con.AccountId); 
            }
        }
        if (!AccountIds.isEmpty()) {
            List<Contact> existingPrimaryContacts = [
                SELECT Id, AccountId
                FROM Contact
                WHERE AccountId IN :AccountIds AND Is_Primary__c = true
            ];
            Map<Id, Contact> accountToPrimaryContactMap = new Map<Id, Contact>();
            for(Contact existingContact : existingPrimaryContacts) {
                accountToPrimaryContactMap.put(existingContact.AccountId, existingContact);
            }
            for(Contact newContact : newContacts) {
                if(newContact.AccountId != null && newContact.Is_Primary__c == true) {
                    if(accountToPrimaryContactMap.containsKey(newContact.AccountId)) {
                        newContact.addError('There is already a primary contact for this account.');
                    }                    
                }
            }
        }
        for(Contact con:newContacts){           
            AggregateResult result = [SELECT COUNT(Id) ContactCount FROM Contact WHERE AccountId = :con.AccountId ];
            Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email,Contact_Count__c = (Integer)result.get('ContactCount'));
            accountsToUpdate.add(acc);
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
    public static void beforeUpdate(Map<Id, Contact> oldContacts, List<Contact> newContacts) {
         List<Account> accountsToUpdate = new List<Account>();
        Set<Id> AccountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null && con.Is_Primary__c == true && (oldContacts.get(con.Id).Is_Primary__c == false || oldContacts.get(con.Id).Is_Primary__c == null)) {
                AccountIds.add(con.AccountId); 
            }
        }
        if (!AccountIds.isEmpty()) {
            List<Contact> existingPrimaryContacts = [
                SELECT Id, AccountId
                FROM Contact
                WHERE AccountId IN :AccountIds AND Is_Primary__c = true
            ];
            Map<Id, Contact> accountToPrimaryContactMap = new Map<Id, Contact>();
            for(Contact existingContact : existingPrimaryContacts) {
                accountToPrimaryContactMap.put(existingContact.AccountId, existingContact);
            }
            for(Contact newContact : newContacts) {
                if(newContact.AccountId != null && newContact.Is_Primary__c == true) {
                    if(accountToPrimaryContactMap.containsKey(newContact.AccountId)) {
                        newContact.addError('There is already a primary contact for this account.');
                    }                    
                }
            }
        }
        for(Contact con:newContacts){           
            AggregateResult result = [SELECT COUNT(Id) ContactCount FROM Contact WHERE AccountId = :con.AccountId ];
            Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email,Contact_Count__c = (Integer)result.get('ContactCount'));
            accountsToUpdate.add(acc);
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}