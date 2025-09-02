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
    public static PagedResult getProducts(
        Filters filters,
        Integer pageNumber,
        String lastRecordName
    ) {
        String key, whereClause = '';
        Decimal maxPrice;
        String[] categories, materials, levels, criteria = new List<String>{};
        if (filters != null) {
            maxPrice = filters.maxPrice;
            materials = filters.materials;
            levels = filters.levels;
            if (!String.isEmpty(filters.searchKey)) {
                key = filters.searchKey + '*';
                List<List<SObject>> searchResults = [
                    FIND :key
                    IN ALL FIELDS
                    RETURNING Product__c(Id)
                ];
                List<Id> productIds = new List<Id>();
                for (Product__c product : (List<Product__c>) searchResults[0]) {
                    productIds.add(product.Id);
                }
                criteria.add('Id IN :productIds');
            }
            if (filters.maxPrice >= 0) {
                maxPrice = filters.maxPrice;
                criteria.add('MSRP__c <= :maxPrice');
            }
            if (filters.categories != null) {
                categories = filters.categories;
                criteria.add('Category__c IN :categories');
            }
            if (filters.levels != null) {
                levels = filters.levels;
                criteria.add('Level__c IN :levels');
            }
            if (filters.materials != null) {
                materials = filters.materials;
                criteria.add('Material__c IN :materials');
            }
            if (criteria.size() > 0) {
                whereClause = 'WHERE ' + String.join(criteria, ' AND ');
            }
        }

        if (pageNumber > 1 && String.isNotBlank(lastRecordName)) {
            if (String.isBlank(whereClause)) {
                whereClause = 'WHERE';
            } else {
                whereClause += ' AND';
            }
            whereClause += ' Name > :lastRecordName';
        }

        Integer pageSize = ProductController.PAGE_SIZE;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        result.records = Database.query(
            'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c FROM Product__c ' +
                whereClause +
                ' WITH USER_MODE' +
                ' ORDER BY Name' +
                ' LIMIT :pageSize'
        );
        result.totalItemCount = result.records.size();
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
