/*
    Name            :    AnsweringQuestionsCtrl
    Date            :    24th Sept. 20414
    Autohr          :
    Description     :    
*/

public class AnsweringQuestionsCtrl{
    //update in the code 1-10-2014    
    public String currentQuestion{get;set;}
    public QuestionModel quesModelobj{get;set;}
    public List<SelectOption> questionOpts{get;set;}
    public Map<String,String> quesoptionMap{get;set;}
    public boolean showUnanswered{get;set;}
    public boolean showpage{get;set;}
    public Map<String,String> answerValueMap{get;set;}
    public List<SelectOption> pagesizeOpts{get;set;}
    public String pagesize{get;set;}    
    
    private Set<String> answerIds;   
    private Set<String> allquestionIds;
    Set<String> trueAppItds;

    public AnsweringQuestionsCtrl(){
        init();
    }
    
    public void init(){       
        trueAppItds = new Set<String>();  
        pagesizeOpts = new List<SelectOption>();
        pagesizeOpts.add(new SelectOption('All','All'));
        pagesizeOpts.add(new SelectOption('10','10'));
        pagesizeOpts.add(new SelectOption('25','25'));
        pagesizeOpts.add(new SelectOption('50','50'));
        pagesizeOpts.add(new SelectOption('100','100'));
        pagesize = 'All';
        
        showUnanswered = false;
        showpage = true;
        allquestionIds = new Set<String>();
        questionOpts = new List<SelectOption>();       
        questionOpts = fetchQuestionsOpts();       
    }
    
    public void changeQuestion(){
        questionOpts = fetchQuestionsOpts();
    }
    
    public void showUnanswered(){
        currentQuestion = '';
        allquestionIds = new Set<String>();
        questionOpts = fetchQuestionsOpts();
    }
    
  
    
    public List<SelectOption> fetchQuestionsOpts(){        
        //showApplicationMap.put(null,false);
        quesoptionMap = new Map<String,String>(); 
        Set<String> questionIds = new Set<String>();
        
        quesModelobj = new QuestionModel();
        List<SelectOption> optlst = new List<SelectOption>();
        //fetch all response records of the current login user
        List<CCA2_Response__c> responselst = [Select id,Answer__c,Answer_Text__c,CCA2_Application__c,CCA2_Question__c,CCA2_Question__r.Name
                                               from CCA2_Response__c where ownerId =: userinfo.getuserId() AND CCA2_Question__c != null 
                                               AND CCA2_Application__c != null order by CCA2_Question__r.Sequence__c ASC limit 1000];
        Set<String> notCompletedQuestins = new Set<String>();
        Integer count = 0;
        Set<String> questionsIds = new Set<String>();
        if(responselst.size() == 0){
            showpage = false;
        }
        Set<String> appIdstemp = new Set<String>();
        if(responselst.size()>0){
            for(CCA2_Response__c res : responselst){
                appIdstemp.add(res.CCA2_Application__c);                
            } 
                     
            if(appIdstemp.size()>0){
                for(CCA2_Application_Goal_Score__c ags : [Select id,Answered__c,CCA2_Application_Goal__r.CCA2_Application__c from CCA2_Application_Goal_Score__c where CCA2_Application_Goal__r.CCA2_Application__c IN : appIdstemp]){
                   trueAppItds.add(ags.CCA2_Application_Goal__r.CCA2_Application__c);
                }
            }            
            
            
            for(CCA2_Response__c res : responselst){                           
                
                if(res.Answer__c == null || res.Answer__c.length() == 0){
                    notCompletedQuestins.add(res.CCA2_Question__c);
                }   
                 
                if(showUnanswered == true && (res.Answer__c == null || res.Answer__c.length() == 0)){
                    questionIds.add(res.CCA2_Question__c);
                    if(!questionsIds.contains(res.CCA2_Question__c))
                        optlst.add(new SelectOption(res.CCA2_Question__c,res.CCA2_Question__r.Name+''));
                    if(count == 0 && (currentQuestion == null || currentQuestion.length() ==0) ){
                        currentQuestion = res.CCA2_Question__c;
                    }   
                    count++; 
                    questionsIds.add(res.CCA2_Question__c);
                    allquestionIds.add(res.CCA2_Question__c);   
                    quesoptionMap.put(res.CCA2_Question__c,res.CCA2_Question__r.Name+'');
                }else if(showUnanswered == false){
                    questionIds.add(res.CCA2_Question__c);
                    if(!questionsIds.contains(res.CCA2_Question__c))
                        optlst.add(new SelectOption(res.CCA2_Question__c,res.CCA2_Question__r.Name+''));
                    if(count == 0 && (currentQuestion == null || currentQuestion.length() ==0) ){
                        currentQuestion = res.CCA2_Question__c;
                    }   
                    count++; 
                    questionsIds.add(res.CCA2_Question__c);
                    allquestionIds.add(res.CCA2_Question__c);   
                    quesoptionMap.put(res.CCA2_Question__c,res.CCA2_Question__r.Name+'');
                }
                     
                 
            }
            
            System.debug('@@@ questionIds==>'+questionIds);
            /* for(CCA2_Response__c res : responselst){
                if(!questionsIds.contains(res.CCA2_Question__c) && notCompletedQuestins.contains(res.CCA2_Question__c)){
                    optlst.add(new SelectOption(res.CCA2_Question__c,res.CCA2_Question__r.Name+''));
                   
                }else if(!questionsIds.contains(res.CCA2_Question__c)){
                   SelectOption tempopt = new SelectOption(res.CCA2_Question__c,'<b style="font-weight:bold;">'+res.CCA2_Question__r.Name+'</b>');
                   tempopt.setEscapeItem(false);
                   optlst.add(tempopt);      
                   quesoptionMap.put(res.CCA2_Question__c,'<b style="font-weight:bold;">'+res.CCA2_Question__r.Name+'</b>');             
                }
                questionsIds.add(res.CCA2_Question__c);
            }*/
        }
        System.debug('@@ currentQuestion ==>'+currentQuestion);
        prepareModel(currentQuestion);
        System.debug('@@ quesoptionMap ==>'+quesoptionMap );
       
        return optlst;
    }
    
  
    
    private void prepareModel(String questionId){
        answerValueMap = new Map<String,String>();
        answerIds = new Set<String>();
        if(questionId != null && questionId.length() > 0){
           List<CCA2_Question__c> queslst = new List<CCA2_Question__c>();
           queslst =  [Select id,Name,Question_Describe__c,Type__c,Category__c,
                           (Select id,High_Value__c,Low_Value__c,PicklistResponse__c,Position__c,Answer_Details__c from CCA2_Answers__r order by  Position__c),
                           (select id,CCA2_Question__c,CCA2_Question__r.Type__c,CCA2_Application__c,Answer__c,Answer_Text__c,
                               CCA2_Application__r.Description__c ,CCA2_Application__r.Name from CCA2_Responses__r where CCA2_Application__c IN : trueAppItds OR answer__c != null order by CCA2_Application__r.Name)
                           from CCA2_Question__c where ID =: questionId];
          
           
             if(queslst.size()>0){
                 quesModelobj = new QuestionModel();
                 CCA2_Question__c ques = queslst[0];
                 quesModelobj.question = new CCA2_Question__c(ID = ques.Id);
                 quesModelobj.question.Name = ques.Name;
                 quesModelobj.question.Question_Describe__c = ques.Question_Describe__c;
                 quesModelobj.question.Type__c = ques.Type__c;
                 quesModelobj.question.Category__c = ques.Category__c;
                 List<SelectOption> optslst = new List<SelectOption>();
                 optslst.add(new SelectOption('','--None--'));
                 if(ques.CCA2_Answers__r != null && ques.CCA2_Answers__r.size()>0 && ques.Type__c == 'Picklist'){  
                     quesModelobj.possibleanslst = ques.CCA2_Answers__r;              
                     for(CCA2_Answer__c ans : ques.CCA2_Answers__r){
                         answerIds.add(ans.Id);
                         if(ans.PicklistResponse__c != null){
                             optslst.add(new SelectOption(ans.Id,ans.PicklistResponse__c));
                             quesModelobj.possibleAns.add(ans.PicklistResponse__c);
                             answerValueMap.put(ans.Id,ans.PicklistResponse__c);
                          }
                     }
                 }else if(ques.CCA2_Answers__r != null && ques.CCA2_Answers__r.size()>0 && ques.Type__c == 'Number'){
                     quesModelobj.possibleanslst = ques.CCA2_Answers__r;                   
                     for(CCA2_Answer__c ans : ques.CCA2_Answers__r){    
                         answerIds.add(ans.Id); 
                         if(ans.Low_Value__c != null && ans.High_Value__c != null){
                             optslst.add(new SelectOption(ans.Id,ans.Low_Value__c+'-'+ans.High_Value__c));
                              quesModelobj.possibleAns.add(ans.Low_Value__c+'-'+ans.High_Value__c);
                              answerValueMap.put(ans.Id,ans.Low_Value__c+'-'+ans.High_Value__c);
                         }else if(ans.Low_Value__c == null && ans.High_Value__c != null){
                             optslst.add(new SelectOption(ans.Id,'<'+ans.High_Value__c));
                             quesModelobj.possibleAns.add('<'+ans.High_Value__c);
                             answerValueMap.put(ans.Id,'<'+ans.High_Value__c);
                         }else if(ans.Low_Value__c != null && ans.High_Value__c == null){
                             optslst.add(new SelectOption(ans.Id,'>'+ans.Low_Value__c));
                             quesModelobj.possibleAns.add('>'+ans.Low_Value__c);
                             answerValueMap.put(ans.Id,'>'+ans.Low_Value__c);
                         }                   
                             
                     }
                 }
                 quesModelobj.answerOpts = optslst;
                 if(ques.CCA2_Responses__r != null && ques.CCA2_Responses__r.size()>0){
                     List<CCA2_Response__c> tempReslst = new List<CCA2_Response__c>();
                     for(CCA2_Response__c res : ques.CCA2_Responses__r){
                         if(showUnanswered == true && (res.Answer__c == null || res.Answer__c.length() == 0)){
                              tempReslst.add(res);
                         }else if(showUnanswered == false){
                             tempReslst.add(res);
                         }                         
                     }
                     if(tempReslst.size()>0){
                         System.debug('@@@ pagesize ==>' +pagesize );
                         if(pagesize != 'All'){
                             List<CCA2_Response__c> tempreslst2 = new List<CCA2_Response__c>();
                             for(integer rowcount = 0; rowcount< Integer.valueOf(pagesize) && rowcount < tempReslst.size() ;rowcount++){
                                 tempreslst2.add(tempReslst[rowcount]);
                             }
                             if(tempreslst2.size()>0)
                                 quesModelobj.responselst = tempreslst2;
                         }else{
                             quesModelobj.responselst =  tempReslst; 
                         }                            
                     }                 
                 }
                     
             }
        }       
    }
    
    public void saveRecords(){    
        pagesize = 'All';
        // Create a savepoint
        Savepoint sp = Database.setSavepoint();  
        try{
           
            //fetch goal's for the questions
            Set<String> goalIds = new Set<String>();
            for(CCA2_Goal_Question__c gq : [select CCA2_Goal__c from CCA2_Goal_Question__c where CCA2_Question__c =: quesModelobj.question.Id]){
                goalIds.add(gq.CCA2_Goal__c);
            }
            
            //fetch questions possible Answers 
            Set<String> tempAnsIds = new Set<String>();
            for(CCA2_Answer__c ans : [Select id from CCA2_Answer__c where Question__c =: quesModelobj.question.Id]){
                tempAnsIds.add(ans.Id);
            }
            
            //fetch the excluded goal ids for the answer
            Map<String,Set<String>> excludedAnsGoalIDMap = new Map<String,Set<String>>();
            for(CCA2_Goal_Score__c gs : [Select Answer__c,CCA2_Goals__c,Exclude__c from CCA2_Goal_Score__c where Answer__c IN : tempAnsIds]){
                if(gs.Exclude__c){
                    Set<String> tempGIds = excludedAnsGoalIDMap.get(gs.Answer__c);
                    if(tempGIds == null)
                        tempGIds = new Set<String>();
                    tempGIds.add(gs.CCA2_Goals__c);
                    excludedAnsGoalIDMap.put(gs.Answer__c,tempGIds);
                }                
            }
            
            //fetch goal question for text type questions to fetch value of Recommended goal score range
            Map<String,String> recommendedScoreMap = new Map<String,String>();
            for(CCA2_Goal_Question__c gq : [Select id,CCA2_Goal__c,CCA2_Question__c,Recommended_goal_score_range__c from CCA2_Goal_Question__c 
                                            where CCA2_Question__c =: currentQuestion AND CCA2_Goal__c IN : goalIds]){
                  recommendedScoreMap.put(gq.CCA2_Goal__c+'_'+gq.CCA2_Question__c,gq.Recommended_goal_score_range__c);
            }
            System.debug('@@ recommendedScoreMap==>'+recommendedScoreMap);
            //fetch goal score for the answer of the questions
            Map<String,CCA2_Goal_Score__c> goalScoreMap = new Map<String,CCA2_Goal_Score__c>();
            Set<String> excludedAnsIds = new Set<String>();
            Set<String> excludedGoalIds = new Set<String>();
            System.debug(goalIds + ' $$$ '+answerIds);
            if(goalIds.size()>0 && answerIds.size()>0){
                for(CCA2_Goal_Score__c gs : [Select id,Score__c,CCA2_Goals__c,Answer__c, Exclude__c from CCA2_Goal_Score__c
                                             where CCA2_Goals__c IN : goalIds AND Answer__c IN : answerIds]){
                      goalScoreMap.put(gs.CCA2_Goals__c+'_'+gs.Answer__c,gs);
                      
                      if(gs.Exclude__c){
                          excludedAnsIds.add(gs.Answer__c);  
                        //  excludedGoalIds.add(gs.CCA2_Goals__c);                        
                      }
                }
            }  
            
            Set<String> appIDs = new Set<String>();
            Set<String> responseIDs = new Set<String>();
            //get Application ids which response is given
            for(CCA2_Response__c res : quesModelobj.responselst){
               // if(res.Answer__c != null){
                    appIDs.add(res.CCA2_Application__c);                    
               // }
                responseIDs.add(res.Id);
            }  
            //fetch old value of response's answers
            Map<String,CCA2_Response__c> oldResponseMap = new Map<String,CCA2_Response__c>();
            for(CCA2_Response__c res : [Select id,Answer__c,Answer_Text__c from CCA2_Response__c where id IN : responseIDs]){
                if(res.Answer__c == null){
                    res.Answer__c = '';
                    oldResponseMap.put(res.Id,res);
                }else{
                    oldResponseMap.put(res.Id,res);
                }   
                if(res.Answer_Text__c == null)         
                    res.Answer_Text__c = '';
            }
            
            Map<String,List<CCA2_Application_Goal__c>> applicationGoalMap = new Map<String,List<CCA2_Application_Goal__c>>();
            Set<String> appGoalIds = new Set<String>();
            if(appIDs.size()>0){
                for(CCA2_Application_Goal__c appGoal : [Select id,CCA2_Account_Goal__c,CCA2_Application__c,CCA2_Account_Goal__r.CCA2_Goal__c
                                                        from CCA2_Application_Goal__c where CCA2_Application__c IN : appIDs]){
                         List<CCA2_Application_Goal__c> templst = applicationGoalMap.get(appGoal.CCA2_Application__c);
                         if(templst == null){
                             templst = new List<CCA2_Application_Goal__c>();
                         }
                         templst.add(appGoal);
                         applicationGoalMap.put(appGoal.CCA2_Application__c,templst);
                         appGoalIds.add(appGoal.Id);
                }
            } 
            
            //fetch Existing application goal score
            Map<String,CCA2_Application_Goal_Score__c> appGoalScoreMap = new Map<String,CCA2_Application_Goal_Score__c>();
            if(appGoalIds.size()>0 && responseIDs.size()>0){
                for(CCA2_Application_Goal_Score__c s : [Select id,CCA2_Application_Goal__c,Answered__c,CCA2_Response__c,Score__c,Recommended_goal_score_range__c from CCA2_Application_Goal_Score__c 
                                                        where CCA2_Application_Goal__c IN : appGoalIds]){
                        appGoalScoreMap.put(s.CCA2_Application_Goal__c+'_'+s.CCA2_Response__c,s);
                }
            }
            system.debug('######appGoalScoreMap----->'+appGoalScoreMap);
            //upsert application goal score and update response records
            List<CCA2_Response__c> updateReslst = new List<CCA2_Response__c>();
            List<CCA2_Application_Goal_Score__c> appgoalscorelst = new List<CCA2_Application_Goal_Score__c>();
            Set<string> excludedAppIds = new Set<String>();
           
            for(CCA2_Response__c res : quesModelobj.responselst){
                
                if(oldResponseMap.containskey(res.Id) && ( (res.CCA2_Question__r.Type__c != 'Text' && res.Answer__c != oldResponseMap.get(res.Id).Answer__c) || (res.CCA2_Question__r.Type__c == 'Text' && res.Answer_Text__c != oldResponseMap.get(res.Id).Answer_Text__c))){
                   if(res.CCA2_Question__r.Type__c == 'Text'){
                       res.Answer__c = 'Text Reponse';
                   }else if(res.CCA2_Question__r.Type__c != 'Text' && answerValueMap.containskey(res.Answer__c)){
                       res.Answer_Text__c = answerValueMap.get(res.Answer__c);
                   }   
                  
                   if(excludedAnsIds.contains(res.Answer__c)){
                       excludedAppIds.add(res.CCA2_Application__c);
                   }
                   if(excludedAnsGoalIDMap.containskey(res.Answer__c)){
                       excludedGoalIds = excludedAnsGoalIDMap.get(res.Answer__c);
                   }   
                              
                    updateReslst.add(res);
                    if(applicationGoalMap.containskey(res.CCA2_Application__c)){
                        for(CCA2_Application_Goal__c appGoal : applicationGoalMap.get(res.CCA2_Application__c)){
                            String key = appGoal.Id + '_' + res.id;
                             system.debug('######key----->'+key);                               
                            if(appGoalScoreMap.containskey(key)){                                 
                                CCA2_Application_Goal_Score__c score = new CCA2_Application_Goal_Score__c();
                                score.Id = appGoalScoreMap.get(key).ID;                               
                                score.Answered__c = true;
                                String scoreKey = appGoal.CCA2_Account_Goal__r.CCA2_Goal__c + '_' + res.Answer__c;    
                                String recommenedKey = appGoal.CCA2_Account_Goal__r.CCA2_Goal__c + '_' + currentQuestion;
                                if(recommendedScoreMap.containskey(recommenedKey) && res.CCA2_Question__r.Type__c == 'Text'){
                                    score.Recommended_goal_score_range__c = recommendedScoreMap.get(recommenedKey);
                                    appgoalscorelst.add(score);
                                }else if(goalScoreMap.containskey(scoreKey) && res.CCA2_Question__r.Type__c != 'Text'){
                                    score.Score__c = goalScoreMap.get(scoreKey).Score__c; 
                                   /* if(goalScoreMap.get(scoreKey).Exclude__c){
                                        excludedGoalIds.add(goalScoreMap.get(scoreKey).CCA2_Goals__c);
                                    } */                                
                                    appgoalscorelst.add(score);
                                }
                           }
                        }
                    }
                }
            }
            
             //exclude applications and delete the related response records for perticuler goal
             System.debug('@@@ excludedAppIds==>'+excludedAppIds);
             System.debug('@@@ excludedGoalIds===>'+excludedGoalIds);
         
             System.debug('@@ updateReslst==>' + updateReslst);
             System.debug('@@ appgoalscorelst==>' + appgoalscorelst);
            
           
            
            //update response
            if(updateReslst.size()>0)
                update updateReslst;
            
            System.debug('##### appgoalscorelst==>'+appgoalscorelst.size() + ' === ' +appgoalscorelst);
            //upsert application goal score
            if(appgoalscorelst.size()>0)
                update appgoalscorelst;        
         
          if(excludedAppIds.size() > 0 && excludedGoalIds.size()>0) 
                excludeApplications(excludedAppIds,excludedGoalIds); 
      
         
         allquestionIds.remove(currentQuestion);
         System.debug('@@@ allquestionIds==>'+allquestionIds);
         
         List<CCA2_Question__c> nextQuestions = [Select id from CCA2_Question__c where ID IN : allquestionIds order by Sequence__c ASC];
         System.debug('@@ nextQuestions==>'+nextQuestions);
         if(nextQuestions.size()>0){
             integer qcount = 0;
             do{
                prepareModel(nextQuestions[qcount].Id);
                currentQuestion = nextQuestions[qcount].Id; 
                qcount++;
                if(quesModelobj.responselst.size() > 0)
                   break;
             }while(nextQuestions.size()-1>qcount);
             
             
             if(quesModelobj.responselst.size() == 0){
                 showpage = false;
             }                
                 
         }else{
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'No more questions to answer');
           ApexPages.addMessage(myMsg);  
         }
         
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.confirm,'Answer successfully saved.');
         ApexPages.addMessage(myMsg);  
         
         
            
        }catch(Exception ex){
            // Rollback the changes 
            Database.rollback(sp);
            System.debug('@@@ Exception==>'+ex.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error in saving the records.');
            ApexPages.addMessage(myMsg);
        }
          
    }
    
    private void excludeApplications(Set<String> appIds, Set<String> goalIds){
        if(appIds.size()>0 && goalIds.size()>0){
            Set<String> appgoalIds = new Set<String>();
            Set<String> responseIds = new Set<String>();
            List<CCA2_Application_Goal__c> appGoalupdatelst = new List<CCA2_Application_Goal__c>();
            for(CCA2_Application_Goal__c appG : [Select id,Exclude__c from CCA2_Application_Goal__c
                                                 where CCA2_Application__c IN : appIds AND CCA2_Account_Goal__r.CCA2_Goal__c IN : goalIds]){
                    appG.Exclude__c = true;
                  //  appgoalIds.add(appG.Id); 
                    appGoalupdatelst.add(appG);
            }
            if(appGoalupdatelst.size()>0)
                update appGoalupdatelst;
           /* if(appgoalIds.size()>0){
                for(CCA2_Application_Goal_Score__c appgs : [Select CCA2_Response__c from CCA2_Application_Goal_Score__c where CCA2_Application_Goal__c IN : appgoalIds]){
                    responseIds.add(appgs.CCA2_Response__c);
                }
            }
            if(responseIds.size()>0){
                List<CCA2_Response__c> deletereponses = [Select id from CCA2_Response__c where ID IN : responseIds];
                if(deletereponses.size()>0)
                    delete deletereponses;
            }*/
        }
    }
    
    // question model
    public class QuestionModel{
        public CCA2_Question__c question{get;set;}
        public List<SelectOption> answerOpts{get;set;}        
        public String selectedAns{get;set;}        
        public List<CCA2_Response__c> responselst{get;set;}
        public List<String> possibleAns{get;set;}
        public List<CCA2_Answer__c> possibleanslst{get;set;}
             
        
        public QuestionModel(){
            question = new CCA2_Question__c();
            answerOpts = new List<SelectOption>();
            selectedAns = '';
            responselst = new List<CCA2_Response__c>();           
            possibleAns = new List<String>();
             possibleanslst = new List<CCA2_Answer__c>();
        }
    }
    public void cancel(){
    }
    
    
    public class ModelClass{
        public CCA2_Response__c resObj{get;set;}
        public List<SelectOption> answerOptions{get;set;}
        public String selectedAnswer{get;set;}
        public boolean answered{get;set;}
        public boolean IsText{get;set;}        
        
                
        public ModelClass(){
            resObj = new CCA2_Response__c();
            answerOptions = new List<SelectOption>();
            answerOptions.add(new SelectOption('','--None--'));
            answered = IsText = false;           
        }
    }
}