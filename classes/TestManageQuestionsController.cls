@isTest
public class TestManageQuestionsController{
    @istest
    public static void test(){
         //Creating Gole
        CCA2_Goal__c goalObject = new CCA2_Goal__c(Name = 'New Goal');
        insert goalObject;
        
        //Creating Question
        CCA2_Question__c questionObject = new CCA2_Question__c (Sequence__c = 1.0,Type__c = 'Text', Name = 'New Question', Gate__c = 2);
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
        
        //Assign account id in pagereference
        ApexPages.currentPage().getParameters().put('id',goalObject.id);
        ApexPages.currentPage().getParameters().put('gate','2');        
        ManageQuestionsController obj = new ManageQuestionsController();
        ManageQuestionsController.createQuestion(questionObject.Id, 'test', 'test questions','testing','test',2,1,'test',goalObject.id, goalQuesObj.Id);
       
        obj.updatedQusId = questionObject.id;
        obj.getGatevalues();
        obj.addAns();
        obj.fillAnsList();
        obj.createdQusId = questionObject.Id;
        obj.createAnswer();
        obj.InitAnsList();
        obj.removeR = 0;
        obj.removeAns();
        obj.reOrderQuestions();
        obj.cancel();
        ManageQuestionsController.createQuestion('', 'test', 'test questions','testing','test',2,2,'test',goalObject.id, goalQuesObj.Id);
        
        
        
    }
}