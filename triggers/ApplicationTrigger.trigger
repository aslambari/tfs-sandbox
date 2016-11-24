trigger ApplicationTrigger on Application__c (after insert) {
    set<string> AccountIds = new set<string>();
    map<string, list<CCA2_Account_Goal__c>> Account_GoalsMap = new map<string, list<CCA2_Account_Goal__c>>();
    map<string, set<string>> AccGoalIdsMap = new map<string, set<string>>();
    
    for(Application__c app : Trigger.New){
        if(app.Account__c!=null){
            AccountIds.add(app.Account__c);
        }
    }
    
    if(AccountIds.size()>0){
        list<Account> AccountList = [Select Id, 
                                     (Select Id, CCA2_Goal__c, Account__c, Unique_Id__c From CCA2_Account_Goals__r) 
                                     From Account
                                     WHERE Id IN: AccountIds];
        if(AccountList.size()>0){
            for(Account acc : AccountList){
                if(acc.CCA2_Account_Goals__r.size()>0){
                    Account_GoalsMap.put(acc.Id, acc.CCA2_Account_Goals__r);
                }
            }
        }
        
        list<CCA2_Account_Goal__c> AccountGoals = [Select Id, CCA2_Goal__c, Account__c, Unique_Id__c 
                                                   From CCA2_Account_Goal__c 
                                                   WHERE Account__c IN: AccountIds];
        
        if(AccountGoals.size()>0){
            for(CCA2_Account_Goal__c accGoal : AccountGoals){
                if(accGoal.CCA2_Goal__c!=null){
                    if(!AccGoalIdsMap.containsKey(accGoal.Account__c)){
                        AccGoalIdsMap.put(accGoal.Account__c, new set<string>());
                    }
                    AccGoalIdsMap.get(accGoal.Account__c).add(accGoal.CCA2_Goal__c);
                }
            }
        }
        
        set<string> GoalIds = new set<string>();
        
        if(AccountList.size()>0){
            list<CCA2_Application_Goal__c> InsertApplicationGoals = new list<CCA2_Application_Goal__c>();
        
            for(Application__c app : Trigger.New){
                if(Account_GoalsMap.containsKey(app.Account__c)){
                    for(CCA2_Account_Goal__c accGoal : Account_GoalsMap.get(app.Account__c)){
                        CCA2_Application_Goal__c AppGoal = new CCA2_Application_Goal__c();
                        AppGoal.CCA2_Account_Goal__c = accGoal.Id;
                        AppGoal.CCA2_Application__c = app.Id;
                        AppGoal.Unique_Id__c = accGoal.Id+'_'+app.Id;
                        InsertApplicationGoals.add(AppGoal);
                        if(accGoal.CCA2_Goal__c!=null){
                            GoalIds.add(accGoal.CCA2_Goal__c);
                        }
                    }
                }
            }
            if(InsertApplicationGoals.size()>0){
                ApplicationGoalScoreHelper.stopApplicationGoalTrigger = true;
                insert InsertApplicationGoals;
                ApplicationGoalScoreHelper.stopApplicationGoalTrigger = false;
            }
            Map<String,Set<String>> goalQuesMap = new Map<String,Set<String>>();
            
            if(GoalIds.size()>0){
                list<CCA2_Goal_Question__c> goalQusList = [SELECT Id, CCA2_Goal__c, CCA2_Question__c, CCA2_Question__r.id, CCA2_Question__r.Gate__c, Unique_Id__c 
                                                           FROM CCA2_Goal_Question__c
                                                           WHERE CCA2_Goal__c IN: GoalIds];
                 for(CCA2_Goal_Question__c gq : goalQusList){
                      Set<String> templst = goalQuesMap.get(gq.CCA2_Goal__c);
                      if(templst == null)
                          templst = new Set<String>();
                      templst.add(gq.CCA2_Question__c);
                      goalQuesMap.put(gq.CCA2_Goal__c,templst);
                }
                                                           
                /*set<string> questionIds = new set<string>();
                map<string, decimal> quesGateMap = new map<string, decimal>();
                if(goalQusList.size()>0){
                    for(CCA2_Goal_Question__c GQ : goalQusList){
                        if(GQ.CCA2_Question__r.id!=null){
                            questionIds.add(GQ.CCA2_Question__r.id);
                            quesGateMap.put(GQ.CCA2_Question__r.id, GQ.CCA2_Question__r.Gate__c);
                        }
                    }
                }*/
                                                           
                list<CCA2_Response__c> insertResponses = new list<CCA2_Response__c>();
                set<string> UniqueIds = new set<string>();
                list<Group> listOfGroup = [ select Id from Group where Name = 'unassigned' and Type = 'Queue' LIMIT 1] ;
                if(goalQusList.size()>0 && listOfGroup.size()>0){
                    for(Application__c app : Trigger.New){
                        for(CCA2_Goal_Question__c goalQus : goalQusList){
                            set<string> tempGoalIds = AccGoalIdsMap.get(app.Account__c);
                            if(tempGoalIds.contains(goalQus.CCA2_Goal__c) && !UniqueIds.contains(app.Id+'_'+goalQus.CCA2_Question__r.id)){
                                CCA2_Response__c res    = new CCA2_Response__c();
                                res.CCA2_Application__c = app.Id;
                                res.CCA2_Question__c    = goalQus.CCA2_Question__r.id;
                                res.Gate__c             = goalQus.CCA2_Question__r.Gate__c;
                                res.Unique_Id__c        = app.Id+'_'+goalQus.CCA2_Question__r.id;
                                res.OwnerId             = listOfGroup[0].Id;
                                insertResponses.add(res);
                                
                                UniqueIds.add(app.Id+'_'+goalQus.CCA2_Question__r.id);
                            }
                        }
                    }
                    if(insertResponses.size()>0){
                        insert insertResponses;
                    
                        list<CCA2_Application_Goal_Score__c> insertAGS = new list<CCA2_Application_Goal_Score__c>();
                        
                        Set<String> tempAGIds = new Set<String>();
                        for(CCA2_Application_Goal__c ag : InsertApplicationGoals){
                            tempAGIds.add(ag.Id);
                        }
                        InsertApplicationGoals.clear();
                        
                        InsertApplicationGoals = [Select id,CCA2_Account_Goal__r.CCA2_Goal__c,CCA2_Application__c 
                                                    from CCA2_Application_Goal__c where Id IN : tempAGIds];
                
                        for(CCA2_Application_Goal__c appGoal : InsertApplicationGoals){
                            for(CCA2_Response__c res : insertResponses){
                                if(res.CCA2_Application__c == appGoal.CCA2_Application__c){
                                    set<String> questionIdSet = goalQuesMap.get(appGoal.CCA2_Account_Goal__r.CCA2_Goal__c);
                                    if(questionIdSet != null && questionIdSet.contains(res.CCA2_Question__c)){
                                        CCA2_Application_Goal_Score__c ags = new CCA2_Application_Goal_Score__c();
                                        ags.CCA2_Application_Goal__c = appGoal.Id;
                                        ags.CCA2_Response__c = res.Id;
                                        insertAGS.add(ags);
                                    }
                                }                                
                            }
                        }
                        System.debug('####insertAGS--->'+insertAGS);
                        if(insertAGS.size()>0){
                            insert insertAGS;
                        }
                    }
                }
            }
        }
    }
}