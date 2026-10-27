
public with sharing class AccountSearchController {

    public String searchName { get; set; }
    public String searchIndustry { get; set; }
    public String searchBillingCity { get; set; }

    public Integer pageNumber { get; set; }
    public Integer pageSize { get; private set; }
    public Integer totalRecords { get; private set; }
    public Boolean hasSearched { get; private set; }

    public List<Account> accounts { get; private set; }

    public AccountSearchController() {
        pageNumber = 1;
        pageSize = 10;
        totalRecords = 0;
        hasSearched = false;
        accounts = new List<Account>();
    }

    public PageReference search() {
        pageNumber = 1;
        hasSearched = true;
        loadAccounts();
        return null;
    }

    private String buildWhereClause() {
        List<String> conditions = new List<String>();

        if (String.isNotBlank(searchName)) {
            conditions.add('Name LIKE :namePattern');
        }

        if (String.isNotBlank(searchIndustry)) {
            conditions.add('Industry = :searchIndustry');
        }

        if (String.isNotBlank(searchBillingCity)) {
            conditions.add('BillingCity LIKE :cityPattern');
        }

        return conditions.isEmpty()
            ? ''
            : ' WHERE ' + String.join(conditions, ' AND ');
    }

    private void loadAccounts() {
        String namePattern = '%' + searchName + '%';
        String cityPattern = '%' + searchBillingCity + '%';

        String whereClause = buildWhereClause();

        String countQuery =
            'SELECT COUNT() FROM Account' + whereClause;

        totalRecords = Database.countQuery(countQuery);

        Integer totalPages = getTotalPages();

        if (totalPages > 0 && pageNumber > totalPages) {
            pageNumber = totalPages;
        }

        Integer recordOffset = (pageNumber - 1) * pageSize;

        String accountQuery =
            'SELECT Id, Name, Industry, Phone, BillingCity ' +
            'FROM Account' + whereClause +
            ' ORDER BY Name ASC LIMIT :pageSize OFFSET :recordOffset';

        accounts = Database.query(accountQuery);
    }

    public Integer getTotalPages() {
        if (totalRecords == 0) {
            return 0;
        }

        return (totalRecords + pageSize - 1) / pageSize;
    }

    public Boolean getHasPrevious() {
        return pageNumber > 1;
    }

    public Boolean getHasNext() {
        return pageNumber < getTotalPages();
    }

    public PageReference first() {
        pageNumber = 1;
        loadAccounts();
        return null;
    }

    public PageReference previous() {
        if (pageNumber > 1) {
            pageNumber--;
        }

        loadAccounts();
        return null;
    }

    public PageReference next() {
        if (pageNumber < getTotalPages()) {
            pageNumber++;
        }

        loadAccounts();
        return null;
    }

    public PageReference last() {
        Integer totalPages = getTotalPages();

        if (totalPages > 0) {
            pageNumber = totalPages;
        }

        loadAccounts();
        return null;
    }
}
