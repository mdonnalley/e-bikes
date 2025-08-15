@isTest
public class TestHeroDetailsPositionCustomPicklist {
    
    @isTest
    static void testGetDefaultValue() {
        HeroDetailsPositionCustomPicklist picklist = new HeroDetailsPositionCustomPicklist();
        
        VisualEditor.DataRow defaultValue = picklist.getDefaultValue();
        
        Assert.areEqual('Right', defaultValue.getLabel());
        Assert.areEqual('right', defaultValue.getValue());
    }
    
    @isTest
    static void testGetValues() {
        HeroDetailsPositionCustomPicklist picklist = new HeroDetailsPositionCustomPicklist();
        
        VisualEditor.DynamicPickListRows values = picklist.getValues();
        
        Assert.areEqual(2, values.size());
        
        // Test first value (Left)
        VisualEditor.DataRow leftValue = values.get(0);
        Assert.areEqual('Left', leftValue.getLabel());
        Assert.areEqual('left', leftValue.getValue());
        
        // Test second value (Right)
        VisualEditor.DataRow rightValue = values.get(1);
        Assert.areEqual('Right', rightValue.getLabel());
        Assert.areEqual('right', rightValue.getValue());
    }
}