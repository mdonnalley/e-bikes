public with sharing class PagedResult {
    @AuraEnabled
    public Integer pageSize { get; set; }

    @AuraEnabled
    public Integer pageNumber { get; set; }

    @AuraEnabled
    public Boolean hasNextPage { get; set; }

    @AuraEnabled
    public Boolean hasPreviousPage { get; set; }

    @AuraEnabled
    public Object[] records { get; set; }
}
