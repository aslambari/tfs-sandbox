@isTest
public class TestApplicationResultController{
    @istest
    public static void test(){
        // creating account record.
        Account acc = new Account(Name='TestAccount');
        insert acc;
        
         //Creating Application
        Application__c applicationObj = new Application__c(Account__c = acc.id, Name = 'New Application', Description__c = 'New Application Description');
        insert applicationObj;
        
        
        //Creating Gole
        CCA2_Goal__c goalObject = new CCA2_Goal__c(Name = 'New Goal');
        insert goalObject;
        
        // creating account goal record.
        CCA2_Account_Goal__c accgoalObject = new CCA2_Account_Goal__c();
        accgoalObject.Account__c = acc.Id;
        accgoalObject.CCA2_Goal__c = goalObject.Id;
        accgoalObject.Unique_Id__c = 'ag101';
        insert accgoalObject;
        
        
        // creating application goal record.
        CCA2_Application_Goal__c appgoalObject = new CCA2_Application_Goal__c();
        appgoalObject.CCA2_Application__c = applicationObj.Id;
        appgoalObject.Unique_Id__c = '111';
        appgoalObject.CCA2_Account_Goal__c = accgoalObject.Id;
        insert appgoalObject;
        
        ApexPages.currentPage().getParameters().put('id',applicationObj.id);
        
        ApplicationResultController obj = new ApplicationResultController();
        obj.getData();
    }
}