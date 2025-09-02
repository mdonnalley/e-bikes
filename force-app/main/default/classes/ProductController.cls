public with sharing class ProductController {
    private static final Integer PAGE_SIZE = 9;
    private static final String QUERY_STRING = 'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c FROM Product__c';

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
        String whereClause = buildWhereClause(filters);
        Integer offset = (pageNumber - 1) * PAGE_SIZE;

        PagedResult result = new PagedResult();
        result.pageSize = PAGE_SIZE;
        result.pageNumber = pageNumber;
        result.records = getProductRecords(whereClause, offset);
        result.totalItemCount = getTotalItemCount(whereClause);

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

    private static String buildWhereClause(Filters filters) {
        List<String> criteria = new List<String>();

        if (filters != null) {
            if (!String.isEmpty(filters.searchKey)) {
                String searchKey = '%' + filters.searchKey + '%';
                criteria.add('Name LIKE :searchKey');
            }
            if (filters.maxPrice != null && filters.maxPrice >= 0) {
                Decimal maxPrice = filters.maxPrice;
                criteria.add('MSRP__c <= :maxPrice');
            }
            if (filters.categories != null && !filters.categories.isEmpty()) {
                List<String> categories = filters.categories;
                criteria.add('Category__c IN :categories');
            }
            if (filters.levels != null && !filters.levels.isEmpty()) {
                List<String> levels = filters.levels;
                criteria.add('Level__c IN :levels');
            }
            if (filters.materials != null && !filters.materials.isEmpty()) {
                List<String> materials = filters.materials;
                criteria.add('Material__c IN :materials');
            }
        }

        if (criteria.isEmpty()) {
            return '';
        }

        return 'WHERE ' + String.join(criteria, ' AND ');
    }

    private static List<Product__c> getProductRecords(
        String whereClause,
        Integer offset
    ) {
        String query =
            QUERY_STRING +
            ' ' +
            whereClause +
            ' WITH USER_MODE' +
            ' ORDER BY Name' +
            ' LIMIT ' +
            PAGE_SIZE +
            ' OFFSET ' +
            offset;
        return Database.query(query);
    }

    private static Integer getTotalItemCount(String whereClause) {
        String countQuery = 'SELECT count() FROM Product__c ' + whereClause;
        return Database.countQuery(countQuery);
    }
}
