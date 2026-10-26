/**
 * This class handles the logic for the Contact trigger.
 * It ensures that only one primary contact exists per account and updates account fields accordingly.
 */
public with sharing class ContactTriggerHandler {
    /**
     * This method is called before inserting new Contact records.
     * It checks if there is already a primary contact for the associated account and prevents duplicates.
     *
     * @param newContacts List of new Contact records being inserted.
     */
    public static void beforeInsert(List<Contact> newContacts) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null && con.Is_Primary__c == true) {
                accountIds.add(con.AccountId); 
            }
        }
        if (!accountIds.isEmpty()) {
            List<Contact> existingPrimaryContacts = [
                SELECT Id, AccountId
                FROM Contact
                WHERE AccountId IN :accountIds AND Is_Primary__c = true 
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
    public static void afterUpdate(Map<Id, Contact> oldContacts, List<Contact> newContacts) {
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> oldAccountsToUpdate = new List<Account>();
        Set<Id> oldContactsAccountIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null && con.Is_Primary__c == true && (oldContacts.get(con.Id).Is_Primary__c == false || oldContacts.get(con.Id).Is_Primary__c == null)) {
                accountIds.add(con.AccountId); 
            }
        }
        if (!accountIds.isEmpty()) {
            List<Contact> existingPrimaryContacts = [
                SELECT Id, AccountId
                FROM Contact
                WHERE AccountId IN :accountIds AND Is_Primary__c = true 
            ];
            Map<Id, Contact> accountToPrimaryContactMap = new Map<Id, Contact>();
            for(Contact existingContact : existingPrimaryContacts) {
                accountToPrimaryContactMap.put(existingContact.AccountId, existingContact);
            }
            for(Contact newContact : newContacts) {
                if(newContact.AccountId != null && newContact.Is_Primary__c == true) {
                    if(accountToPrimaryContactMap.containsKey(newContact.AccountId)) {
                        accountIds.remove(newContact.AccountId);
                        newContact.addError('There is already a primary contact for this account.');

                    }                    
                }
            }
        }
        for(Contact con:newContacts){
             if(con.AccountId != null){
                accountIds.add(con.AccountId);
             }
             else if(oldContacts.get(con.Id).AccountId != null){
                oldContactsAccountIds.add(oldContacts.get(con.Id).AccountId);
             }
             
          }
           List<AggregateResult> result = [SELECT AccountId, COUNT(Id) ContactCount FROM Contact WHERE AccountId IN :accountIds GROUP BY AccountId];
           List<AggregateResult> oldResult = [SELECT AccountId, COUNT(Id) oldContactCount FROM Contact WHERE AccountId IN :oldContactsAccountIds GROUP BY AccountId];
           Map<Id, Integer> contactCountMap = new Map<Id, Integer>();

           for (AggregateResult ar : result) {
               contactCountMap.put((Id) ar.get('AccountId'),(Integer) ar.get('ContactCount'));
            }
            Map<Id, Integer> oldContactCountMap = new Map<Id, Integer>();

           for (AggregateResult oldar : oldResult) {
               oldContactCountMap.put((Id) oldar.get('AccountId'),(Integer) oldar.get('oldContactCount'));
            }
          for(Contact con:newContacts){
             // Check if the New Contact's AccountId has not changed or if the Is_Primary__c field has changed from false to true
             
            if(oldContacts.get(con.Id).AccountId == con.AccountId && oldContacts.get(con.Id).Is_Primary__c == false && con.Is_Primary__c == true){
                 Integer countValue = contactCountMap.containsKey(con.AccountId)? contactCountMap.get(con.AccountId): 0;
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email,Contact_Count__c = countValue);
                accountsToUpdate.add(acc);
            }
            // Check if the New Contact's AccountId has not changed or if the Is_Primary__c field has changed from true to false
            else if(oldContacts.get(con.Id).AccountId == con.AccountId && oldContacts.get(con.Id).Is_Primary__c == true && con.Is_Primary__c == false){
               Integer countValue = contactCountMap.containsKey(con.AccountId)? contactCountMap.get(con.AccountId): 0;
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = null,Contact_Count__c = countValue);
                accountsToUpdate.add(acc);
            }
            // Check if the New Contact's AccountId has changed and if the Is_Primary__c field has changed from false to true
            else if(oldContacts.get(con.Id).AccountId != con.AccountId && oldContacts.get(con.Id).Is_Primary__c == false && con.Is_Primary__c == true){
                Integer countValue = contactCountMap.containsKey(con.AccountId)? contactCountMap.get(con.AccountId): 0;
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email,Contact_Count__c = countValue);
                accountsToUpdate.add(acc);
            }
            else if(oldContacts.get(con.Id).AccountId != con.AccountId && oldContacts.get(con.Id).Is_Primary__c == true && con.Is_Primary__c == true){
                Integer countValue = contactCountMap.containsKey(con.AccountId)? contactCountMap.get(con.AccountId): 0;
                Account acc = new Account(Id = con.AccountId,Primary_Contact_Email__c = con.Email,Contact_Count__c = countValue );
                accountsToUpdate.add(acc);
                Integer oldCountValue = oldcontactCountMap.containsKey(con.AccountId)? oldcontactCountMap.get(con.AccountId): 0;
                Account oldAcc = new Account(Id = oldContacts.get(con.Id).AccountId,Primary_Contact_Email__c = null,Contact_Count__c = oldCountValue);
                oldAccountsToUpdate.add(oldAcc);
            }
        
            // Check if the New Contact's AccountId has  changed and if the Is_Primary__c field has unchecked
            else if (oldContacts.get(con.Id).AccountId != con.AccountId && oldContacts.get(con.Id).Is_Primary__c == false){
            
                Integer oldCountValue = oldcontactCountMap.containsKey(con.AccountId)? oldcontactCountMap.get(con.AccountId): 0;
                Account oldAcc = new Account(Id = oldContacts.get(con.Id).AccountId,Contact_Count__c = oldCountValue);
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