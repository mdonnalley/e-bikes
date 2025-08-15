@isTest
public class TestPagedResult {
    
    @isTest
    static void testPagedResultProperties() {
        // Test constructor and property assignment
        PagedResult result = new PagedResult();
        
        // Test setting properties
        result.pageSize = 10;
        result.pageNumber = 1;
        result.totalItemCount = 100;
        result.records = new List<String>{'Record1', 'Record2', 'Record3'};
        
        // Assert properties are set correctly
        Assert.areEqual(10, result.pageSize, 'Page size should be 10');
        Assert.areEqual(1, result.pageNumber, 'Page number should be 1');
        Assert.areEqual(100, result.totalItemCount, 'Total item count should be 100');
        Assert.areEqual(3, result.records.size(), 'Records list should contain 3 items');
        Assert.areEqual('Record1', result.records[0], 'First record should be Record1');
    }
    
    @isTest
    static void testPagedResultWithNullValues() {
        // Test with null values
        PagedResult result = new PagedResult();
        
        // Properties should be null by default
        Assert.isNull(result.pageSize, 'Page size should be null by default');
        Assert.isNull(result.pageNumber, 'Page number should be null by default');
        Assert.isNull(result.totalItemCount, 'Total item count should be null by default');
        Assert.isNull(result.records, 'Records should be null by default');
    }
    
    @isTest
    static void testPagedResultWithEmptyRecords() {
        // Test with empty records list
        PagedResult result = new PagedResult();
        result.pageSize = 5;
        result.pageNumber = 1;
        result.totalItemCount = 0;
        result.records = new List<Object>();
        
        Assert.areEqual(5, result.pageSize, 'Page size should be 5');
        Assert.areEqual(1, result.pageNumber, 'Page number should be 1');
        Assert.areEqual(0, result.totalItemCount, 'Total item count should be 0');
        Assert.areEqual(0, result.records.size(), 'Records list should be empty');
    }
}