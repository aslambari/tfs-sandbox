public class TestSiteContactHandler{
    @isTest
    private static void testController(){
        SiteContactHandler sch = new SiteContactHandler();
        sch.newLead.LastName = 'test';
        sch.saveLead();
    
    }
}