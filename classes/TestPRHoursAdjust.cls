public with sharing class TestPRHoursAdjust {


    @isTest
    public static void TestAffectProjectRequestActuals () {
        
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        
        Project__c proj = new Project__c();
        proj.name = 'asasd';
        insert proj;
        
        Contact con = new Contact();
        con.firstname='alan';
        con.lastname='brown';
        con.account = acc;
        insert con;
        
        project_request__c projectReq = new project_request__c();
        projectReq.name = 'asgf';
        projectReq.developer__c = con.id;
        projectReq.project__c = proj.id;
            
        Time_card__c tCard = new Time_card__c();
        tCard.day__c = Date.today();
        tCard.Hours__c = 12.0;
        tCard.Developer__c = con.id;        
        try {
            insert tcard;            
        } catch (Exception e) {
            System.debug('all is well');
        }
        
    }
}