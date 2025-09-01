public with sharing class PagedResult {
    @AuraEnabled
    public Integer pageSize { get; set; }

    @AuraEnabled
    public Boolean hasMore { get; set; }

    @AuraEnabled
    public Object[] records { get; set; }
}
