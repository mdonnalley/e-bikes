@isTest
public class TestProductRecordInfoController {
    @testSetup
    static void setup() {
        // Create test Product Family
        Product_Family__c family = new Product_Family__c(
            Name = 'Test Family',
            Category__c = 'Mountain'
        );
        insert family;

        // Create test Product
        Product__c product = new Product__c(
            Name = 'Test Product',
            MSRP__c = 1000,
            Category__c = 'Mountain',
            Level__c = 'Beginner',
            Material__c = 'Carbon',
            Product_Family__c = family.Id
        );
        insert product;
    }

    @isTest
    static void testGetRecordInfoForProduct() {
        // Test finding a Product record
        List<String> result = ProductRecordInfoController.getRecordInfo(
            'Test Product'
        );

        Assert.isNotNull(
            result,
            'Result should not be null for existing product'
        );
        Assert.areEqual(2, result.size(), 'Result should contain 2 elements');
        Assert.areEqual(
            'Product__c',
            result[1],
            'Second element should be Product__c'
        );

        // Verify the ID is valid
        Product__c testProduct = [
            SELECT Id
            FROM Product__c
            WHERE Name = 'Test Product'
            LIMIT 1
        ];
        Assert.areEqual(
            testProduct.Id,
            result[0],
            'First element should be the Product ID'
        );
    }

    @isTest
    static void testGetRecordInfoForProductFamily() {
        // Test finding a Product Family record
        List<String> result = ProductRecordInfoController.getRecordInfo(
            'Test Family'
        );

        Assert.isNotNull(
            result,
            'Result should not be null for existing product family'
        );
        Assert.areEqual(2, result.size(), 'Result should contain 2 elements');
        Assert.areEqual(
            'Product_Family__c',
            result[1],
            'Second element should be Product_Family__c'
        );

        // Verify the ID is valid
        Product_Family__c testFamily = [
            SELECT Id
            FROM Product_Family__c
            WHERE Name = 'Test Family'
            LIMIT 1
        ];
        Assert.areEqual(
            testFamily.Id,
            result[0],
            'First element should be the Product Family ID'
        );
    }

    @isTest
    static void testGetRecordInfoForNonExistentRecord() {
        // Test with a name that doesn't exist
        List<String> result = ProductRecordInfoController.getRecordInfo(
            'Non Existent Item'
        );

        Assert.isNull(result, 'Result should be null for non-existent record');
    }

    @isTest
    static void testGetRecordInfoWithNullInput() {
        // Test with null input
        List<String> result = ProductRecordInfoController.getRecordInfo(null);

        Assert.isNull(result, 'Result should be null for null input');
    }

    @isTest
    static void testGetRecordInfoWithEmptyString() {
        // Test with empty string
        List<String> result = ProductRecordInfoController.getRecordInfo('');

        Assert.isNull(result, 'Result should be null for empty string input');
    }

    @isTest
    static void testGetRecordInfoProductTakesPrecedence() {
        // Create both a Product and Product Family with the same name
        Product_Family__c family2 = new Product_Family__c(
            Name = 'Duplicate Name',
            Category__c = 'Road'
        );
        insert family2;

        Product__c product2 = new Product__c(
            Name = 'Duplicate Name',
            MSRP__c = 1500,
            Category__c = 'Road',
            Level__c = 'Racer',
            Material__c = 'Aluminum',
            Product_Family__c = family2.Id
        );
        insert product2;

        // Test that Product takes precedence over Product Family
        List<String> result = ProductRecordInfoController.getRecordInfo(
            'Duplicate Name'
        );

        Assert.isNotNull(result, 'Result should not be null');
        Assert.areEqual(2, result.size(), 'Result should contain 2 elements');
        Assert.areEqual(
            'Product__c',
            result[1],
            'Should return Product__c type (Product takes precedence)'
        );
        Assert.areEqual(product2.Id, result[0], 'Should return the Product ID');
    }
}
