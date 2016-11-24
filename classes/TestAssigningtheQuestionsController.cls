@isTest
public class TestAssigningtheQuestionsController{
    @istest
    public static void test(){
        String ownerid;
        ownerid = [select Id from Group where Name = 'unassigned' and Type = 'Queue' limit 1].id;
        
        //Creating Account
        Account accountObject = new Account(Name = 'New Account');
        insert accountObject;
        
         // creating contact record.
        Contact contactObject = new Contact(LastName='TestContact',AccountId=accountObject.Id);
        insert contactObject;
        
        //Creating Gole
        CCA2_Goal__c goalObject = new CCA2_Goal__c(Name = 'New Goal');
        insert goalObject;
        
        
        //Creating AccountGoal
        CCA2_Account_Goal__c accGoalObj = new CCA2_Account_Goal__c (Account__c = accountObject.id, CCA2_Goal__c = goalObject.Id);
        Insert accGoalObj;
       
        
        //Creating Question
        CCA2_Question__c questionObject = new CCA2_Question__c (Sequence__c = 1.0,Type__c = 'Text', Name = 'New Question 1', Gate__c = 2);
        insert questionObject;
        
        //Creating goalQuestion
        CCA2_Goal_Question__c goalQuesObj = new CCA2_Goal_Question__c(CCA2_Goal__c = goalObject.id, CCA2_Question__c =  questionObject.id );
        insert goalQuesObj;
        
        //Creating Answer Object
        CCA2_Answer__c answerObject = new CCA2_Answer__c(Question__c = questionObject.id);
        insert answerObject;
        
        
        //Creating GoalScore Object
        CCA2_Goal_Score__c goalScoreObj = new CCA2_Goal_Score__c(Score__c = 5, CCA2_Goals__c = goalObject.id, Answer__c = answerObject.id);
        insert goalScoreObj;
        
        // creating application record.
        Application__c app = new Application__c();
        app.Name='Test Application';
        app.Account__c = accountObject.Id;
        app.Best_Fit_Goal__c ='test2';
        app.Business_Owner_of_the_Application__c = contactObject.Id;
        app.Best_Goal_For_App_Number_Of_Questions__c = 'test2';
        app.Classification__c  = 'test2';
        app.Type__c = 'Finance';    
        app.Description__c = 'tests2';             
        insert app;
        
        ApexPages.currentPage().getParameters().put('accid',accountObject.Id);
        AssigningtheQuestionsController ctrl = new AssigningtheQuestionsController();
        ctrl.fetchUnassignedQues();
        ctrl.updateData();
        ctrl.next();
        ctrl.first();
        ctrl.last();
        ctrl.getPagePosition();
        
        
    }
}