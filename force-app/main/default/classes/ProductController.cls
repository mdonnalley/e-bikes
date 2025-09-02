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
        String key;
        Decimal maxPrice;
        String[] categories, materials, levels;
        List<String> criteria = new List<String>();

        if (filters != null) {
            if (!String.isEmpty(filters.searchKey)) {
                key = filters.searchKey + '%';
                criteria.add('Name LIKE :key');
            }
            if (filters.maxPrice != null && filters.maxPrice >= 0) {
                maxPrice = filters.maxPrice;
                criteria.add('MSRP__c <= :maxPrice');
            }
            if (filters.categories != null && !filters.categories.isEmpty()) {
                categories = filters.categories;
                criteria.add('Category__c IN :categories');
            }
            if (filters.levels != null && !filters.levels.isEmpty()) {
                levels = filters.levels;
                criteria.add('Level__c IN :levels');
            }
            if (filters.materials != null && !filters.materials.isEmpty()) {
                materials = filters.materials;
                criteria.add('Material__c IN :materials');
            }
        }

        String whereClause = '';
        if (!criteria.isEmpty()) {
            whereClause = 'WHERE ' + String.join(criteria, ' AND ');
        }

        Integer offset = (pageNumber - 1) * PAGE_SIZE;

        PagedResult result = new PagedResult();
        result.pageSize = PAGE_SIZE;
        result.pageNumber = pageNumber;

        String countQuery = 'SELECT count() FROM Product__c ' + whereClause;
        result.totalItemCount = Database.countQuery(countQuery);

        String query =
            'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c ' +
            'FROM Product__c ' +
            whereClause +
            ' ORDER BY Name ' +
            'LIMIT :PAGE_SIZE ' +
            'OFFSET :offset';
        result.records = Database.query(query);

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
