public with sharing class PagedResult {
    @AuraEnabled
    public Integer pageSize { get; set; }

    @AuraEnabled
    public Integer pageNumber { get; set; }

    @AuraEnabled
    public Boolean hasNext { get; set; }

    @AuraEnabled
    public Boolean hasPrevious { get; set; }

    @AuraEnabled
    public Object[] records { get; set; }
}
