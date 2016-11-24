/*
        Name        :  TestaffectProjectRequestActuals
        Author      :
        Date        :  04/04/2015
        Description :  This test class for 'affectProjectRequestActuals' class.
*/

@isTest
public class TestaffectProjectRequestActuals{
    @isTest
    private static void affectProjectTest(){
        // Insert account object
            Account acc = new Account(Name = 'TestAccount');
            insert acc;
        // Insert contact object
            Contact con = new Contact(Lastname = 'TestContact', AccountId = acc.id);
            insert con;
        // Insert Project object
            Project__c pro = new Project__c(Name = 'TestProject');
            insert pro;
        // Insert Project request object
            Project_Request__c pr = new Project_Request__c(Project__c = pro.id, Developer__c = con.id, Name = 'TestSummry');
            insert pr;
        // Insert Time Card object
            Time_Card__c tc = new Time_Card__c(Hours__c = 5, Day__c = system.Today(), Week_Ending__c = system.Today().addDays(3),Developer__c = con.id,Project_Request__c = pr.id);
            insert tc;
        // Update time card object
            tc.Hours__c = 6;
            update tc;
        // Delete time card object
            delete tc;
    }
}