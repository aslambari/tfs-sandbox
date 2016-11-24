public class ManageQuestionsController{
    public string goalId;
    public boolean isgoalId{get;set;}
    public CCA2_Goal__c goal{get;set;}
    public list<QuestionModel> QuestionModelList{get;set;}
    public list<AnswerModel> AnswerModelList{get;set;}
    public integer Counter;
    public integer removeR{get;set;}
    public string createdQusId{get;set;}
    public string updatedQusId{get;set;}
    public map<string, CCA2_Goal_Score__c> goalScoreMap;
    public map<string, CCA2_Goal_Question__c> goalQuestionMap;
    public set<string> goalQusSet{get;set;}
    public Decimal questionGateValue{get;set;}
    public string goalQusId{get;set;}
    public string goalQuesId{get;set;}
    public map<string, string> QuestionSequenceMap{get;set;}
    //public string removeQusId{get;set;}
    
    public ManageQuestionsController(){
        goalId = ApexPages.currentPage().getParameters().get('id');
        isgoalId = false;
        goal = new CCA2_Goal__c();
        string gateStr = ApexPages.currentPage().getParameters().get('gate');
        questionGateValue = integer.valueOf(gateStr != null && gateStr.trim().length()>0 ? gateStr.trim() : '1');
       
        InitFun();
        
        counter = 0;
        AnswerModelList = new list<AnswerModel>();
    }
    
    private void InitFun(){
        if(goalId != null && goalId.length()>0){
            isgoalId = true;
            list<CCA2_Goal__c> goalList = [SELECT Id, Name, 
                                           (SELECT Id, Name, CCA2_Goal__c, CCA2_Question__c FROM CCA2_Goal_Question__r)
                                           FROM CCA2_Goal__c 
                                           WHERE Id =: goalId];
                                           
            if(goalList.size()>0){
                goal = goalList[0];
                goalId = goal.Id;
                goalQusSet = new set<string>();
                if(goal.CCA2_Goal_Question__r.size()>0){
                    for(CCA2_Goal_Question__c gq : goal.CCA2_Goal_Question__r){
                        goalQusSet.add(gq.CCA2_Question__c);
                    }
                }
                
                list<CCA2_Goal_Score__c> goalScoreList = [SELECT Id, Name, Score__c, CCA2_Goals__c, Answer__c, Exclude__c 
                                                          FROM CCA2_Goal_Score__c];
                
                goalScoreMap = new map<string, CCA2_Goal_Score__c>();               
                if(goalScoreList.size()>0){
                    for(CCA2_Goal_Score__c gs : goalScoreList){
                        goalScoreMap.put(''+gs.CCA2_Goals__c+gs.Answer__c, gs);
                    }
                }
                
                list<CCA2_Goal_Question__c> goalQuesList = [SELECT Id, Name, CCA2_Question__c, CCA2_Goal__c, Recommended_goal_score_range__c 
                                                            FROM CCA2_Goal_Question__c];
                                                            
                goalQuestionMap = new map<string, CCA2_Goal_Question__c>();               
                if(goalQuesList.size()>0){
                    for(CCA2_Goal_Question__c gq : goalQuesList){
                        goalQuestionMap.put(''+gq.CCA2_Goal__c+gq.CCA2_Question__c, gq);
                    }
                }
                
                fetchQuestions();
            }
        }
    }
    
    public void fetchQuestions(){
        list<CCA2_Question__c> questionList = [SELECT Id,  Sequence__c, Name, Question_Describe__c, Type__c, Category__c, Gate__c//, Sequence_Number__c
                                               FROM CCA2_Question__c
                                               ORDER BY Sequence__c, Name
                                               LIMIT 1000];
                                             
        if(questionList.size()>0){
            QuestionModelList = new list<QuestionModel>();
            QuestionSequenceMap = new map<string, string>();
            for(CCA2_Question__c q : questionList){
                
                if(q.Gate__c == questionGateValue){
                    QuestionModel qm = new QuestionModel();
                    qm.id = q.Id;
                    qm.questionText = q.Name!=null ? q.Name.replaceall('\'','&#39;').replaceall('/','&#47;') : '';
                    qm.questionDes = q.Question_Describe__c!=null ? q.Question_Describe__c.replaceall('\r\n','').replaceall('"','').replaceall('\'','&#39;').replaceall('/','&#47;') : '';
                    qm.questionType = q.Type__c;
                    qm.questionSequence = q.Sequence__c;
                    qm.questionGate = q.Gate__c;
                    qm.questionCateg = q.Category__c;
                    if(goalQuestionMap.containsKey(''+goalId+q.Id)){
                        qm.RecomGoalScoreRange = goalQuestionMap.get(''+goalId+q.Id).Recommended_goal_score_range__c+'*#*'+goalQuestionMap.get(''+goalId+q.Id).Id;
                    }
                    if(goalQusSet.contains(q.Id)){
                        qm.haveGoalQus = true;
                    }else{
                        qm.haveGoalQus = false;
                    }
                    QuestionModelList.add(qm);
                    
                    QuestionSequenceMap.put(q.Id, ''+q.Sequence__c);
                }
            }
        }
    }
    
    /*public pagereference removeQuestion(){
        delete [SELECT Id FROM CCA2_Goal_Question__c WHERE CCA2_Goal__c =: goalId AND CCA2_Question__c =: removeQusId];
        delete [SELECT Id FROM CCA2_Goal_Score__c WHERE CCA2_Goals__c =: goalId AND Answer__r.Question__c =: removeQusId];
        
        return new pagereference('/apex/ManageQuestions?id='+goalId+'&gate='+questionGateValue).setRedirect(true);
    }*/
    
    public list<selectOption> getGatevalues(){
        list<selectOption> options = new list<selectOption>();
        AggregateResult[] groupedResults = [SELECT MAX(Gate__c)maxi FROM CCA2_Question__c];
        if(groupedResults.size()>0){
            Integer maxGateValue = integer.valueOf(groupedResults[0].get('maxi'));
            for(integer i=1 ; i<=maxGateValue ; i++){
                options.add(new selectOption(''+i, ''+i));
            }
            return options;
        }
        return null;
    }
    
    public void InitAnsList(){
        AnswerModelList = new list<AnswerModel>();
        AnswerModel ans = new AnswerModel();
        ans.answer = new CCA2_Answer__c();
        Counter = 0;
        ans.index = Counter;
        ans.goalScorestr = null;
        AnswerModelList.add(ans);
    }
    
    public void addAns(){
        AnswerModel ans = new AnswerModel();
        ans.answer = new CCA2_Answer__c();
        Counter = Counter+1;
        ans.index = Counter;
        ans.goalScorestr = null;
        AnswerModelList.add(ans);
    }
    
    public void removeAns(){
        Integer position = 0;
        for(AnswerModel ans : AnswerModelList){
            if(ans.index == removeR){
                break;
            }
            position++;
        }
        AnswerModel tempModel = AnswerModelList.get(position);
        if(tempModel.answer.Id != null){
            delete tempModel.answer;
        }
        AnswerModelList.remove(position);
    }
    
    public pagereference createAnswer(){
        Savepoint sp = Database.setSavepoint();
        
        try{
            list<CCA2_Answer__c> tempAnswerList = new list<CCA2_Answer__c>();
            list<CCA2_Goal_Score__c> tempGoalScorList = new list<CCA2_Goal_Score__c>();
            list<CCA2_Goal_Question__c> tempGoalQusList = new list<CCA2_Goal_Question__c>();
            
            if(createdQusId.trim().length()>0){
                list<CCA2_Question__c> tempList = [SELECT Id, Sequence__c FROM CCA2_Question__c WHERE Id =: createdQusId];
                if(tempList.size()>0){
                    QuestionSequenceMap.put(tempList[0].Id, ''+tempList[0].Sequence__c);
                    reOrderQuestions();
                }
            }
            
            if(AnswerModelList.size()>0){
                for(AnswerModel ans : AnswerModelList){
                    if(ans.qusType != 'Text'){
                        CCA2_Answer__c answr = new CCA2_Answer__c();
                        answr = ans.answer;
                        if(answr.Id == null){
                            answr.Question__c = createdQusId;
                        }
                        if(ans.qusType == 'Picklist' && ans.answer.PicklistResponse__c != null && ans.answer.PicklistResponse__c.trim().length()>0){
                            answr.Low_Value__c = null;
                            answr.High_Value__c = null;
                        }
                        if(ans.qusType == 'Number'){
                            answr.PicklistResponse__c = null;
                            answr.Low_Value__c = ans.answer.Low_Value__c>0 ? ans.answer.Low_Value__c : null;
                            answr.High_Value__c = ans.answer.High_Value__c>0 ? ans.answer.High_Value__c : null;
                        }
                        tempAnswerList.add(answr);
                            
                        if(tempAnswerList.size()>0){
                            if(ans.goalScorestr != null && ans.goalScorestr.trim().length()>0){
                                CCA2_Goal_Score__c gscore = new CCA2_Goal_Score__c();
                                
                                if(goalScoreMap.containsKey(''+goalId+ans.answer.Id)){
                                    gscore.Id = goalScoreMap.get(''+goalId+ans.answer.Id).Id;
                                }else{
                                    gscore.CCA2_Goals__c = goalId;
                                }
                                gscore.Score__c = integer.valueOf(ans.goalScorestr);
                                gscore.Exclude__c = ans.isExclude;
                                ans.tempGoalScore = gscore;
                                tempGoalScorList.add(gscore);
                                if(tempGoalQusList==null || tempGoalQusList.size()==0){
                                    if(goalQuesId.trim().length()==0){
                                        CCA2_Goal_Question__c goalQues = new CCA2_Goal_Question__c();
                                        goalQues.CCA2_Question__c = createdQusId;
                                        goalQues.CCA2_Goal__c = goalId;
                                        goalQues.Recommended_goal_score_range__c = null;
                                        tempGoalQusList.add(goalQues);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(tempAnswerList.size()>0){
                upsert tempAnswerList;
                if(tempGoalQusList.size()>0){
                    insert tempGoalQusList;
                }
                
                for(AnswerModel a : AnswerModelList){
                    if(!goalScoreMap.containsKey(''+goalId+a.answer.Id)){
                        a.tempGoalScore.Answer__c = a.answer.Id;
                    }
                }
                
                if(tempGoalScorList.size()>0){
                    upsert tempGoalScorList;
                }
                
                InitAnsList();
                InitFun();
                return new pagereference('/apex/ManageQuestions?id='+goalId+'&gate='+questionGateValue).setRedirect(true);
            }
        }catch(Exception e){
            Database.rollback(sp);
        }
        return new pagereference('/apex/ManageQuestions?id='+goalId+'&gate='+questionGateValue).setRedirect(true);
    }
    
    public void fillAnsList(){
        list<CCA2_Answer__c> tempAnsList = [SELECT Id, Name, Question__c, PicklistResponse__c, Low_Value__c, High_Value__c, Position__c, Answer_Details__c 
                                             FROM CCA2_Answer__c
                                             WHERE Question__c =: updatedQusId];
        
        Counter = 0;
        AnswerModelList = new list<AnswerModel>();
        if(tempAnsList!=null && tempAnsList.size()>0){
            for(CCA2_Answer__c ans : tempAnsList){
                AnswerModel answr = new AnswerModel();
                answr.answer = ans;
                answr.Index = Counter;
                if(goalScoreMap.containsKey(''+goalId+ans.Id)){
                    answr.goalScorestr = goalScoreMap.get(''+goalId+ans.Id).Score__c!=null ? ''+goalScoreMap.get(''+goalId+ans.Id).Score__c:null;
                    answr.isExclude = goalScoreMap.get(''+goalId+ans.Id).Exclude__c;
                }
                AnswerModelList.add(answr);
                Counter++;
            }
        }else{
            AnswerModel answr = new AnswerModel();
            answr.answer = new CCA2_Answer__c();
            answr.Index = Counter;
            answr.goalScorestr = null;
            AnswerModelList.add(answr);
            Counter++;
        }
    }
    
    @RemoteAction
    public static CCA2_Question__c createQuestion(string qusId, string categ, string qusText, string qusDes, string qusType, Decimal qusGate, Decimal qusSequence, string RecomGoalScorRange, string goal_Id, string goalQusId){
        //Savepoint sp = Database.setSavepoint();
        
        //try{
            CCA2_Question__c qus = new CCA2_Question__c();
            qus.Category__c = categ;
            qus.Name = qusText;
            qus.Question_Describe__c = qusDes;
            qus.Type__c = qusType;
            qus.Gate__c = qusGate;
            qus.Sequence__c = qusSequence;
            
            if(qusId.trim().length()==0){
                insert qus;
                
                if(RecomGoalScorRange.trim().length()>0){
                    CCA2_Goal_Question__c goalQues = new CCA2_Goal_Question__c();
                    goalQues.CCA2_Question__c = qus.Id;
                    goalQues.CCA2_Goal__c = goal_Id;
                    goalQues.Recommended_goal_score_range__c = RecomGoalScorRange.trim();
                    
                    insert goalQues;
                }
                
                return qus;
            }else{
                qus.Id = qusId;
                update qus;
                
                if(RecomGoalScorRange.trim().length()==0){
                    delete [SELECT Id, Name, CCA2_Question__c, CCA2_Goal__c 
                            FROM CCA2_Goal_Question__c
                            WHERE CCA2_Goal__c =: goal_Id
                            AND CCA2_Question__c =: qusId];
                }
                if(RecomGoalScorRange.trim().length()>0){
                    if(goalQusId.trim().length()==0){
                        CCA2_Goal_Question__c goalQues = new CCA2_Goal_Question__c();
                        goalQues.CCA2_Question__c = qus.Id;
                        goalQues.CCA2_Goal__c = goal_Id;
                        goalQues.Recommended_goal_score_range__c = RecomGoalScorRange.trim();
                        
                        insert goalQues;
                    }else{
                        CCA2_Goal_Question__c goalQues = new CCA2_Goal_Question__c();
                        goalQues.Id = goalQusId;
                        goalQues.Recommended_goal_score_range__c = RecomGoalScorRange.trim();
                        
                        update goalQues;
                    }
                }
                
                return qus;
            }
        /*}catch(Exception e){
            Database.rollback(sp);
        }*/
        return null;
    }
    
    public pagereference reOrderQuestions(){
        set<string> sequenceSet = new set<string>();
        map<decimal, string> seqQusMap = new map<decimal, string>();
        list<CCA2_Question__c> updateSequenceOfQus = new list<CCA2_Question__c>();
        for(string qusId : QuestionSequenceMap.keySet()){
            if(QuestionSequenceMap.get(qusId).trim().length()>0){
                if(!sequenceSet.contains(QuestionSequenceMap.get(qusId).trim())){
                    seqQusMap.put(decimal.valueOf(QuestionSequenceMap.get(qusId).trim()), qusId);
                    sequenceSet.add(QuestionSequenceMap.get(qusId).trim());
                }else if(sequenceSet.contains(QuestionSequenceMap.get(qusId).trim())){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This '+QuestionSequenceMap.get(qusId).trim()+' Sequence Number already exist.'));
                    return null;
                }
            }else if(QuestionSequenceMap.get(qusId).trim().length()==0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sequence Number is required.'));
                return null;
            }
        }
        if(seqQusMap.size()>0){
            integer tempSeq = 1;
            list<decimal> seqList = new list<decimal>();
            seqList.addAll(seqQusMap.keySet());
            seqList.sort();
            for(decimal seq : seqList){
                CCA2_Question__c qustion = new CCA2_Question__c(Id = seqQusMap.get(seq));
                qustion.Sequence__c = tempSeq;
                updateSequenceOfQus.add(qustion);
                tempSeq++;
            }
            if(updateSequenceOfQus.size()>0){
                update updateSequenceOfQus;
            }
        }
        return new pagereference('/apex/ManageQuestions?id='+goalId+'&gate='+questionGateValue).setRedirect(true);
    }
    
    public pagereference cancel(){
        return new pagereference('/'+goalId);
    }
    
    public class QuestionModel{
        public string id{get;set;}
        public string questionCateg{get;set;}
        public string questionText{get;set;}
        public string questionDes{get;set;}
        public string questionType{get;set;}
        public Decimal questionGate{get;set;}
        public Decimal questionSequence{get;set;}
        public boolean haveGoalQus{get;set;}
        public string RecomGoalScoreRange{get;set;}
    }
    
    public class AnswerModel{
        public Integer index{get;set;}
        public string goalScorestr{get;set;}
        public boolean isExclude{get;set;}
        public string qusType{get;set;}
        public CCA2_Answer__c answer{get;set;}
        public CCA2_Goal_Score__c tempGoalScore{get;set;}
        
        AnswerModel(){
            tempGoalScore = new CCA2_Goal_Score__c();
            isExclude = false;
        }
    }
}