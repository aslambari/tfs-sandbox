@isTest
public class TestAppsByGoalController{
    static testmethod void unittest(){
        Account acc = new Account(name ='Test Account');
        insert acc;
                        
       
       //Creating Goal
       CCA2_Goal__c goal = new CCA2_Goal__c(Name = 'New Goal');
      
       insert goal;
       
       //Creating Account
       Account accountObject = new Account(Name = 'New Account');
       insert accountObject;
       
       //Creating AccountGoal
       CCA2_Account_Goal__c accGoalObj = new CCA2_Account_Goal__c (Account__c = accountObject.id, CCA2_Goal__c = goal.Id);
       
       Insert accGoalObj;
       
       
       
       ApexPages.currentPage().getParameters().put('accid',accountObject.id);
       Apexpages.currentPage().getParameters().put('goalid',goal.id);
       
       Application__c applicationObj = new Application__c(Account__c = accountObject.id, Name = 'New Application', Description__c = 'New Application Description');
       
       insert applicationObj;
       CCA2_Application_Goal__c AppGoal = new CCA2_Application_Goal__c(CCA2_Account_Goal__c = accGoalObj.id);
       AppGoal.CCA2_Application__c =applicationObj.id;       
       AppsByGoalController AppGoalCtrl = new AppsByGoalController();
       AppGoalCtrl.getData();
       
    }
}