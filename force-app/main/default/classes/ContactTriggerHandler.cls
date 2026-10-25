public with sharing class ContactTriggerHandler {
    public static void beforeInsert(List<Contact> newContacts) {
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
    }
    public static void beforeUpdate(Map<Id, Contact> oldContacts, List<Contact> newContacts) {
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> oldAccountsToUpdate = new List<Account>();
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
            
             // Check if the New Contact's AccountId has not changed or if the Is_Primary__c field has changed from false to true
            if(oldContacts.get(con.Id).AccountId == con.AccountId && oldContacts.get(con.Id).Is_Primary__c == false && con.Is_Primary__c == true){
                AggregateResult result = [SELECT COUNT(Id) ContactCount FROM Contact WHERE AccountId = :con.AccountId ];
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email,Contact_Count__c = (Integer)result.get('ContactCount'));
                accountsToUpdate.add(acc);
            }
            // Check if the New Contact's AccountId has not changed or if the Is_Primary__c field has changed from true to false
            else if(oldContacts.get(con.Id).AccountId == con.AccountId && oldContacts.get(con.Id).Is_Primary__c == true && con.Is_Primary__c == false){
                AggregateResult result = [SELECT COUNT(Id) ContactCount FROM Contact WHERE AccountId = :con.AccountId ];
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = null,Contact_Count__c = (Integer)result.get('ContactCount'));
                accountsToUpdate.add(acc);
            }
            // Check if the New Contact's AccountId has changed and if the Is_Primary__c field has changed from false to true
            else if(oldContacts.get(con.Id).AccountId != con.AccountId && oldContacts.get(con.Id).Is_Primary__c == false && con.Is_Primary__c == true){
                AggregateResult result = [SELECT COUNT(Id) ContactCount FROM Contact WHERE AccountId = :con.AccountId ];
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email,Contact_Count__c = (Integer)result.get('ContactCount'));
                accountsToUpdate.add(acc);
            }
            else if(oldContacts.get(con.Id).AccountId != con.AccountId && oldContacts.get(con.Id).Is_Primary__c == true && con.Is_Primary__c == true){
                AggregateResult result = [SELECT COUNT(Id) ContactCount FROM Contact WHERE AccountId = :con.AccountId ];
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email,Contact_Count__c = (Integer)result.get('ContactCount'));
                accountsToUpdate.add(acc);
                 AggregateResult oldResult = [SELECT COUNT(Id) oldContactCount FROM Contact WHERE AccountId = :oldContacts.get(con.Id).AccountId ];
                Account oldAcc = new Account(Id = oldContacts.get(con.Id).AccountId,Primary_Contact_Email__c = null,Contact_Count__c = (Integer)oldResult.get('oldContactCount'));
                oldAccountsToUpdate.add(oldAcc);
            }
        
            // Check if the New Contact's AccountId has  changed and if the Is_Primary__c field has unchecked
            else if (oldContacts.get(con.Id).AccountId != con.AccountId && oldContacts.get(con.Id).Is_Primary__c == false){
                AggregateResult oldResult = [SELECT COUNT(Id) oldContactCount FROM Contact WHERE AccountId = :oldContacts.get(con.Id).AccountId ];
                Account oldAcc = new Account(Id = oldContacts.get(con.Id).AccountId,Contact_Count__c = (Integer)oldResult.get('oldContactCount'));
                oldAccountsToUpdate.add(oldAcc);
            }
            //Check if the new Contact's AccountId has not changed and if the Is_Primary__c field has not changed but the Email has changed
            else if(oldContacts.get(con.Id).AccountId == con.AccountId && oldContacts.get(con.Id).Is_Primary__c == true && con.Is_Primary__c == true && oldContacts.get(con.Id).Email != con.Email){
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email);
                accountsToUpdate.add(acc);
            }
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
            }
        if(!oldAccountsToUpdate.isEmpty()){
            update oldAccountsToUpdate;
        }
    }
}