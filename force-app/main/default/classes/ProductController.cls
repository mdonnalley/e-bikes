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
        String searchKey;
        Decimal maxPrice;
        String[] categories;
        String[] materials;
        String[] levels;

        if (filters != null) {
            searchKey = filters.searchKey;
            maxPrice = filters.maxPrice;
            categories = filters.categories;
            materials = filters.materials;
            levels = filters.levels;
        }

        Integer pageSize = ProductController.PAGE_SIZE;
        Integer offset = (pageNumber - 1) * pageSize;

        // Use SOSL if a search key is provided
        if (!String.isEmpty(searchKey)) {
            String soslQuery = 'FIND :searchKey IN ALL FIELDS RETURNING Product__c(Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c';
            List<String> criteria = new List<String>();
            if (maxPrice != null && maxPrice >= 0) {
                criteria.add('MSRP__c <= :maxPrice');
            }
            if (categories != null && !categories.isEmpty()) {
                criteria.add('Category__c IN :categories');
            }
            if (levels != null && !levels.isEmpty()) {
                criteria.add('Level__c IN :levels');
            }
            if (materials != null && !materials.isEmpty()) {
                criteria.add('Material__c IN :materials');
            }
            if (!criteria.isEmpty()) {
                soslQuery += ' WHERE ' + String.join(criteria, ' AND ');
            }
            soslQuery += ' WITH USER_MODE ORDER BY Name)';

            List<List<SObject>> searchResults = search.query(soslQuery);
            List<Product__c> products = (List<Product__c>) searchResults[0];

            PagedResult result = new PagedResult();
            result.pageNumber = pageNumber;
            result.pageSize = pageSize;
            result.totalItemCount = products.size();

            Integer fromIndex = offset;
            Integer toIndex = Math.min(offset + pageSize, products.size());

            if (fromIndex >= products.size()) {
                result.records = new List<Product__c>();
            } else {
                result.records = products.subList(fromIndex, toIndex);
            }
            return result;
        }

        // Otherwise, use SOQL
        String soqlQuery = 'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c FROM Product__c';
        List<String> criteria = new List<String>();
        if (maxPrice != null && maxPrice >= 0) {
            criteria.add('MSRP__c <= :maxPrice');
        }
        if (categories != null && !categories.isEmpty()) {
            criteria.add('Category__c IN :categories');
        }
        if (levels != null && !levels.isEmpty()) {
            criteria.add('Level__c IN :levels');
        }
        if (materials != null && !materials.isEmpty()) {
            criteria.add('Material__c IN :materials');
        }
        if (!criteria.isEmpty()) {
            soqlQuery += ' WHERE ' + String.join(criteria, ' AND ');
        }
        soqlQuery +=
            ' WITH USER_MODE ORDER BY Name LIMIT ' +
            (pageSize + 1) +
            ' OFFSET ' +
            offset;

        List<Product__c> products = Database.query(soqlQuery);

        PagedResult result = new PagedResult();
        result.pageNumber = pageNumber;
        result.pageSize = pageSize;
        result.records = products;
        result.totalItemCount = -1; // We can't know the total count without a slow query

        if (products.size() > pageSize) {
            products.remove(pageSize);
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
