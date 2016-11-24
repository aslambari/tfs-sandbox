@isTest
public class TestApplicationGoalScoreTrigger{

    public static testMethod void unitTest(){
        // creating account record.
        Account acc = new Account(Name='TestAccount');
        insert acc;
        
        // creating contact record.
        Contact con = new Contact(LastName='TestContact',AccountId=acc.Id);
        insert con;
        
        // creating application record.
        Application__c app = new Application__c();
        app.Name='Test Application';
        app.Account__c = acc.Id;
        app.Best_Fit_Goal__c ='test';
        app.Business_Owner_of_the_Application__c = con.Id;
        app.Best_Goal_For_App_Number_Of_Questions__c = 'test';
        app.Classification__c  = 'test';
        app.Type__c = 'Finance';    
        app.Description__c = 'tests';             
        insert app;
        
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
        appgoalObject.CCA2_Application__c = app.Id;
        appgoalObject.Unique_Id__c = '111';
        appgoalObject.CCA2_Account_Goal__c = accgoalObject.Id;
        insert appgoalObject;
        
        // creating question records.
        CCA2_Question__c questionObject = new CCA2_Question__c (Sequence__c = 1.0,Type__c = 'Text', Name = 'New Question', Gate__c = 2);
        insert questionObject;      
        
        // creating response records.
        CCA2_Response__c responseObject = new CCA2_Response__c();
        responseObject.CCA2_Application__c = app.Id;
        responseObject.CCA2_Question__c    = questionObject.Id;
        responseObject.Answer__c = 'test';
        responseObject.Gate__c   = 1;
        responseObject.Unique_Id__c = '101';
        insert responseObject;
                
        CCA2_Application_Goal_Score__c ags = new  CCA2_Application_Goal_Score__c();
        ags.CCA2_Response__c = responseObject.Id;
        ags.CCA2_Application_Goal__c = appgoalObject.Id;
        ags.score__c = 25;
        insert ags;
        
        ags.score__c = 125;
        update ags;
    
    }
}