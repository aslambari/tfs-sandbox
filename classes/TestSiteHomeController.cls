public class TestSiteHomeController{
    @isTest
    private static void SiteHomeController(){
        Expertise__c exp = new Expertise__c();
        exp.Name='test';
        insert exp;
        Expertise__c exp1 = new Expertise__c();
        exp1.Name='test1';
        insert exp1;
        Expertise__c exp2 = new Expertise__c();
        exp2.Name='test2';
        insert exp2;
        SiteHomeController shc = new SiteHomeController();
        shc.getFirstColumn();
        shc.getMiddleColumn();
        shc.getLastColumn();
    }

}