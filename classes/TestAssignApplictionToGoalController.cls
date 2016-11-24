@istest
public class TestAssignApplictionToGoalController{
    @istest
    public static void test(){
        String ownerid;
        ownerid = [select Id from Group where Name = 'unassigned' and Type = 'Queue' limit 1].id;
        
        //Creating Question
        CCA2_Question__c questionObject = new CCA2_Question__c (Type__c = 'Text', Name = 'New Question', Gate__c = 2, Sequence__c = 1);
        insert questionObject;
        
        //Creating Gole
        CCA2_Goal__c goalObject = new CCA2_Goal__c(Name = 'New Goal'); 
        insert goalObject;
        CCA2_Goal__c goalObject2 = new CCA2_Goal__c(Name = 'New Goal2'); 
        insert goalObject2;
        
        //Creating Account
        Account accountObject1 = new Account(Name = 'New Account1');
        insert accountObject1;
        
        //Creating AccountGoal
        CCA2_Account_Goal__c accGoalObj = new CCA2_Account_Goal__c (Account__c = accountObject1.id, CCA2_Goal__c = goalObject.Id);
        Insert accGoalObj;
        
        //Creating Application
        Application__c applicationObj1 = new Application__c(Account__c = accountObject1.id, Name = 'New Application', Description__c = 'New Application Description');
        insert applicationObj1;
        
        Application__c applicationObj2 = new Application__c(Account__c = accountObject1.id, Name = 'New Application2', Description__c = 'New Application Description');
        insert applicationObj2;
        
        //Creating Responce Record
        CCA2_Response__c responceRecord1 = new CCA2_Response__c(CCA2_Application__c = applicationObj1.id, CCA2_Question__c = questionObject.id, Gate__c = 1);
        insert responceRecord1;
        
        CCA2_Response__c responceRecord2 = new CCA2_Response__c(CCA2_Application__c = applicationObj2.id, CCA2_Question__c = questionObject.id, Gate__c = 2);
        insert responceRecord2;
        
        //Assign account id in pagereference
        ApexPages.currentPage().getParameters().put('accountId',accountObject1.id);
        
        AssignApplicationsToGoalsController obj = new AssignApplicationsToGoalsController();
        obj.selectedGate = '2';
        system.debug('Before list------->' + obj.modalAllList);
        obj.modalAllList[1].status = true;
        obj.modalAllList[1].excluded = true;
        obj.modalAllList[1].unsignedStatus = true;
        system.debug('After list------->' + obj.modalAllList);
        obj.assignedAll();
        obj.changeSelectList();
        //obj.unsignedApp = true;
        obj.changeSelectList();
        obj.next();
        obj.prev();
        obj.last();
        obj.first();
        obj.getPagePosition();
        obj.cancel();
    }
}