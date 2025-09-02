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
        String key, whereClause = '';
        Decimal maxPrice;
        String[] categories, materials, levels, criteria = new List<String>{};
        if (filters != null) {
            maxPrice = filters.maxPrice;
            materials = filters.materials;
            levels = filters.levels;
            // Apex Guru Recommendation: Avoid leading wildcards in SOQL queries.
            // This allows the query to be selective and use an index on the Name field.
            if (!String.isEmpty(filters.searchKey)) {
                key = filters.searchKey + '%';
                criteria.add('Name LIKE :key');
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
        Integer pageSize = ProductController.PAGE_SIZE;
        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;

        // Apex Guru Recommendation: Inefficient total item count.
        // Database.countQuery can be slow. Consider alternative pagination strategies
        // like keyset pagination if performance is critical.
        result.totalItemCount = Database.countQuery(
            'SELECT count() FROM Product__c ' + whereClause
        );

        // Apex Guru Recommendation: Slow Pagination with OFFSET.
        // To optimize, we first query for the Ids of the records on the current page,
        // and then retrieve the full records for that set of Ids.
        // This is generally more performant than using OFFSET on a query with many fields.
        String idQuery =
            'SELECT Id FROM Product__c ' +
            whereClause +
            ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
        List<Product__c> productIds = Database.query(idQuery);

        if (productIds.isEmpty()) {
            result.records = new List<Product__c>();
        } else {
            List<Id> ids = new List<Id>();
            for (Product__c p : productIds) {
                ids.add(p.Id);
            }
            result.records = Database.query(
                'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c FROM Product__c ' +
                    'WHERE Id IN :ids' +
                    ' WITH USER_MODE' +
                    ' ORDER BY Name'
            );
        }

        // Apex Guru Recommendation: Ensure that the frequently filtered fields
        // (Category__c, Level__c, Material__c) are indexed in Salesforce.
        // This is a schema change and cannot be done in Apex.

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
