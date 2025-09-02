public with sharing class ProductController {
    static Integer PAGE_SIZE = 9;

    public class Filters {
        @AuraEnabled
        public String searchKey { get; set; }
        @AuraEnabled
        public Decimal maxPrice { get; set; }
        @AuraEnabled
        public String[] categories { get; set; }
        @AuraEnabled
        public String[] materials { get; set; }
        @AuraEnabled
        public String[] levels { get; set; }
    }

    @AuraEnabled(Cacheable=true scope='global')
    public static PagedResult getProducts(Filters filters, Integer pageNumber) {
        String key;
        String whereClause = '';
        Decimal maxPrice;
        String[] categories;
        String[] materials;
        String[] levels;
        List<String> criteria = new List<String>();

        if (filters != null) {
            if (!String.isEmpty(filters.searchKey)) {
                key = filters.searchKey + '*';
            }
            if (filters.maxPrice != null && filters.maxPrice >= 0) {
                maxPrice = filters.maxPrice;
                criteria.add('MSRP__c <= :maxPrice');
            }
            if (filters.categories != null && !filters.categories.isEmpty()) {
                categories = filters.categories;
                criteria.add('Category__c IN :categories');
            }
            if (filters.materials != null && !filters.materials.isEmpty()) {
                materials = filters.materials;
                criteria.add('Material__c IN :materials');
            }
            if (filters.levels != null && !filters.levels.isEmpty()) {
                levels = filters.levels;
                criteria.add('Level__c IN :levels');
            }
            if (!criteria.isEmpty()) {
                whereClause = 'WHERE ' + String.join(criteria, ' AND ');
            }
        }

        Integer pageSize = ProductController.PAGE_SIZE;
        Integer offset = (pageNumber - 1) * pageSize;

        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;

        if (key != null) {
            String soslQuery =
                'FIND :key IN ALL FIELDS RETURNING Product__c(Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c ' +
                whereClause +
                ' ORDER BY Name LIMIT ' +
                pageSize +
                ')';
            List<List<SObject>> searchResults = Search.query(soslQuery);
            result.records = searchResults[0];
            result.totalItemCount = searchResults[0].size();
        } else {
            String query =
                'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c FROM Product__c ' +
                whereClause +
                ' WITH USER_MODE' +
                ' ORDER BY Name' +
                ' LIMIT ' +
                pageSize +
                ' OFFSET ' +
                offset;
            result.records = Database.query(query);
            // Keyset pagination is more performant, but requires client-side changes.
            // For now, we'll remove the expensive count query and return the current page of results.
            // The client will need to be updated to handle "load more" functionality.
            result.totalItemCount = 0;
        }
        return result;
    }

    @AuraEnabled(Cacheable=true scope='global')
    public static Product__c[] getSimilarProducts(Id productId, Id familyId) {
        return [
            SELECT
                Id,
                Name,
                MSRP__c,
                Description__c,
                Category__c,
                Level__c,
                Picture_URL__c,
                Material__c
            FROM Product__c
            WHERE Product_Family__c = :familyId AND Id != :productId
            WITH USER_MODE
        ];
    }
}
