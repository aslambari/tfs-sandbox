public class QuestionDetailsController{
    
    //Private Variable Declaration
    private Map<String,CCA2_Goal_Question__c> gQMap;
    private Map<String,List<CCA2_Goal_Score__c>> gSMap;
    private CCA2_Goal_Score__c emptyScores;
    
    //Public Variable Declaration
    public CCA2_Question__c quesObj{get;set;}
    public List<AnswerGoalModel> detailsList{get;set;}
    public Map<String,CCA2_Answer__c> ansMap{get;set;}
    public List<AnswerScoreModel> showGoal{get;set;}
    public List<CCA2_Goal_Score__c  > editScoreList{get;set;}
    public String editGoalId{get;set;}
    public String selectedGoalName{get;set;}
    public String editAnswerIds{get;set;}
    public Boolean error{get;set;}
    
    //Controller
    public QuestionDetailsController(){
        quesObj = new CCA2_Question__c();
        detailsList = new List<AnswerGoalModel>();
        ansMap = new Map<String,CCA2_Answer__c>();
        gQMap = new Map<String,CCA2_Goal_Question__c>();
        gSMap = new Map<String,List<CCA2_Goal_Score__c>>();
        showGoal = new List<AnswerScoreModel>();
        editScoreList = new List<CCA2_Goal_Score__c>();
        emptyScores= new CCA2_Goal_Score__c();
        error = true;
    }
    
    //Method For Initialization
    public pageReference initQuestionDetails(){
        String questionId = apexPages.currentPage().getParameters().get('id');
        if(questionId == null || questionId == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Question Selected'));
            error = false;
            return null;
        }
        quesObj = [select Name,Type__c from CCA2_Question__c where id =: questionId];
        
        for(CCA2_Answer__c a:[select Answer_Details__c,High_Value__c,Low_Value__c,PicklistResponse__c from CCA2_Answer__c where Question__c =: questionId]){
            ansMap.put(a.id,a);
        }
        
        for(CCA2_Goal_Question__c gQ:[select CCA2_Goal__c,CCA2_Goal__r.Name from CCA2_Goal_Question__c where CCA2_Question__c =: questionId]){
            gQMap.put(gQ.CCA2_Goal__c,gQ);
        }
        
        for(CCA2_Goal_Score__c gS:[select Exclude__c,Score__c,CCA2_Goals__c,Answer__c from CCA2_Goal_Score__c where CCA2_Goals__c in:[select id from CCA2_Goal__c] and Answer__c in: ansMap.keyset()]){
            List<CCA2_Goal_Score__c> tempList = gSMap.get(gS.CCA2_Goals__c + '-' + gS.Answer__c);
            if(tempList == null){
                tempList = new List<CCA2_Goal_Score__c>();
            }
            tempList.add(gS);
            gSMap.put(gS.CCA2_Goals__c + '-' + gS.Answer__c ,tempList);
        }
        
        fillDetails();
        return null;
    }
    
    //Moethod For Filling Details in AnswerGoalModel
    public void fillDetails(){
        List<CCA2_Goal__c> allGoals = [select id,name from CCA2_Goal__c];
        for(String ansId:ansMap.keyset()){
            AnswerGoalModel tempAGM = new AnswerGoalModel();
            tempAGM.answer = ansMap.get(ansId);
            for(CCA2_Goal__c g:allGoals){
                if(gQMap.get(g.id) != null){
                    tempAGM.goalQues.add(gQMap.get(g.id));
                }else{
                    tempAGM.goalQues.add(new CCA2_Goal_Question__c ());
                }
                if(showGoal.size() < allGoals.size()){
                    AnswerScoreModel tempAnswerScoreModel = new AnswerScoreModel();
                    tempAnswerScoreModel.goal = g;
                    tempAnswerScoreModel.answerIdList.addAll(ansMap.Keyset());
                    showGoal.add(tempAnswerScoreModel);
                }
                if(gSMap.get(g.id + '-' + ansId) != null){
                    tempAGM.scoreList.addAll(gSMap.get(g.id + '-' + ansId));
                }else{
                     tempAGM.scoreList.add(emptyScores);
                }    
            }
            detailsList.add(tempAGM);
        }
    }
    
    //Method For Filling Vales in Edit Dialog Box
    public void valuesForDialog(){
        editAnswerIds = editAnswerIds.remove(']');
        editAnswerIds = editAnswerIds.remove('[');
        editAnswerIds = editAnswerIds.deleteWhitespace();
        List<String> answerIds = editAnswerIds.split(',');
        system.debug('---->answerIds  '+answerIds);
        editScoreList = [select Exclude__c,Score__c,Answer__c,Answer__r.Answer_Details__c,Answer__r.High_Value__c,Answer__r.Low_Value__c,Answer__r.PicklistResponse__c from CCA2_Goal_Score__c where CCA2_Goals__c =: editGoalId and Answer__c in: answerIds];
        Set<String> tempAns = new Set<String>();
        for(CCA2_Goal_Score__c tempScore:editScoreList){
            tempAns.add(tempScore.Answer__c);
        }
        
        Integer looplmt = 0;
        if(editScoreList.size() == 0){
            looplmt = answerIds.size();
        }else{
            looplmt = answerIds.size() - editScoreList.size();
        }
        
        for(Integer i = 0; i<looplmt; i++){
            if(!tempAns.contains(answerIds[i])){
                CCA2_Goal_Score__c tempScore = new CCA2_Goal_Score__c();
                tempScore.Answer__c = answerIds[i];
                tempScore.CCA2_Goals__c  = editGoalId;
                tempScore.Unique_Id__c = answerIds[i] + '_' + editGoalId;
                editScoreList.add(tempScore);
                tempAns.add(answerIds[i]);
            }
        }
    }
    
    //Method To Upsert Score
    public PageReference updateScore(){
        try{
            upsert editScoreList;
        }catch(Exception e){
            system.debug('--->Custom Error: ' + e);
        }
        PageReference pg = new PageReference('/apex/QuestionDetails?id='+quesObj.Id);
        pg.setredirect(true);
        return pg;
    }
    
    //Method To Remove Score
    public pageReference removeScore(){
        delete [SELECT Id FROM CCA2_Goal_Question__c WHERE CCA2_Goal__c =: editGoalId AND CCA2_Question__c =: quesObj.id];
        delete [SELECT Id FROM CCA2_Goal_Score__c WHERE CCA2_Goals__c =: editGoalId AND Answer__r.Question__c =: quesObj.id];
        return new pageReference('/apex/QuestionDetails?id=' + quesObj.id).setredirect(true);      
    }
    
    //Model Class To Hold Data
    public class AnswerGoalModel{
        public CCA2_Answer__c answer{get;set;}
        public List<CCA2_Goal_Question__c> goalQues{get;set;}
        public List<CCA2_Goal_Score__c> scoreList{get;set;}
        
        public AnswerGoalModel(){
            answer = new CCA2_Answer__c();
            goalQues = new List<CCA2_Goal_Question__c>();
            scoreList = new List<CCA2_Goal_Score__c>();
        }
    }
    
    //Model Class To Show Header
    public class AnswerScoreModel{
        public List<String> answerIdList{get;set;}
        public CCA2_Goal__c goal{get;set;}
        
        public AnswerScoreModel(){
            answerIdList = new List<String>();
            goal = new CCA2_Goal__c();
        }
    }
}