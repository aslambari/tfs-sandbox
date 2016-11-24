public class TestSiteExpertiseController{
    @isTest
    private static void testController(){
        Expertise__c exp = new Expertise__c();
        exp.Name='test';
        exp.Details__c='This is \n detail';
        insert exp;
        SiteExpertiseController sch = new SiteExpertiseController();
        ApexPages.currentPage().getParameters().put('id',exp.id);
        SiteExpertiseController sch1 = new SiteExpertiseController();
        
    }
}