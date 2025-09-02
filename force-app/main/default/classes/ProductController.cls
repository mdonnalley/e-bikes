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
            if (!String.isEmpty(filters.searchKey)) {
                key = '%' + filters.searchKey + '%';
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

        String query =
            'SELECT Id, Name, MSRP__c, Description__c, Category__c, Level__c, Picture_URL__c, Material__c FROM Product__c ' +
            whereClause +
            ' WITH USER_MODE' +
            ' ORDER BY Name';

        // To avoid a costly count query, we request one more record than the page size.
        // The presence of this extra record tells us if there's a next page.
        query += ' LIMIT ' + (pageSize + 1);
        query += ' OFFSET :offset';

        List<Product__c> products = Database.query(query);

        boolean hasNextPage = products.size() > pageSize;
        if (hasNextPage) {
            // Remove the extra record before sending to the client.
            products.remove(products.size() - 1);
        }
        result.records = products;

        // We no longer run a separate COUNT query. We deduce the total item count.
        // This is an approximation for pagination purposes.
        Integer totalItemCount;
        if (pageNumber == 1 && !hasNextPage) {
            totalItemCount = products.size();
        } else if (hasNextPage) {
            totalItemCount = pageNumber * pageSize + 1; // At least one more.
        } else {
            totalItemCount = (pageNumber - 1) * pageSize + products.size();
        }
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
        ];
    }
}
