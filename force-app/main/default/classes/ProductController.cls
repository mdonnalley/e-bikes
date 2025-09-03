public with sharing class ProductController {
    private static final Integer PAGE_SIZE = 9;

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
        String searchKey = '';
        Decimal maxPrice = 9999999;
        String[] categories = new List<String>{};
        String[] materials = new List<String>{};
        String[] levels = new List<String>{};

        if (filters != null) {
            searchKey = String.escapeSingleQuotes(
                filters.searchKey != null ? filters.searchKey : ''
            );
            maxPrice = filters.maxPrice != null ? filters.maxPrice : 9999999;
            categories = filters.categories != null
                ? filters.categories
                : new List<String>{};
            materials = filters.materials != null
                ? filters.materials
                : new List<String>{};
            levels = filters.levels != null
                ? filters.levels
                : new List<String>{};
        }

        Integer offset = (pageNumber - 1) * PAGE_SIZE;

        String query =
            'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c ' +
            'FROM Product__c ';
        String countQuery = 'SELECT COUNT() FROM Product__c ';
        String whereClause =
            'WHERE Name LIKE \'' +
            searchKey +
            '%\' AND MSRP__c <= ' +
            maxPrice +
            ' ';

        if (categories.size() > 0) {
            whereClause +=
                'AND Category__c IN (\'' +
                String.join(categories, '\',\'') +
                '\') ';
        }
        if (materials.size() > 0) {
            whereClause +=
                'AND Material__c IN (\'' +
                String.join(materials, '\',\'') +
                '\') ';
        }
        if (levels.size() > 0) {
            whereClause +=
                'AND Level__c IN (\'' +
                String.join(levels, '\',\'') +
                '\') ';
        }

        query +=
            whereClause +
            'WITH USER_MODE ORDER BY Name LIMIT ' +
            PAGE_SIZE +
            ' OFFSET ' +
            offset;
        countQuery += whereClause;

        List<Product__c> products = Database.query(query);
        Integer totalItemCount = Database.countQuery(countQuery);

        PagedResult result = new PagedResult();
        result.pageSize = PAGE_SIZE;
        result.pageNumber = pageNumber;
        result.records = products;
        result.totalItemCount = totalItemCount;

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
            LIMIT 5
        ];
    }
}
