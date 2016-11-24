public with sharing class ApplicationGoalScoreHelper {
    public Static boolean stopApplicationGoalTrigger = false;

    public static void MarkAsCompleted(set<string> appGoalIds){
        List<CCA2_Application_Goal__c> updateAppGoals = new List<CCA2_Application_Goal__c>();
        
        if(appGoalIds.size()>0){
            set<string> appIds = new set<string>();
            for(CCA2_Application_Goal__c appGoal : [SELECT Id, CCA2_Application__c FROM CCA2_Application_Goal__c
                                                   WHERE Id IN: appGoalIds]){
                                                   
                appIds.add(appGoal.CCA2_Application__c);
            }
            
            List<CCA2_Application_Goal__c> tempAppGoals = [SELECT Id, Completed__c,
                                                           (SELECT Id
                                                            FROM CCA2_Application_Goal_Scores__r 
                                                            WHERE CCA2_Response__r.Answer__c =: null)
                                                           FROM CCA2_Application_Goal__c
                                                           WHERE CCA2_Application__c IN: appIds]; 
                                                           
            if(tempAppGoals.size()>0){
                for(CCA2_Application_Goal__c ag : tempAppGoals){
                    if(ag.CCA2_Application_Goal_Scores__r.size()==0){
                        CCA2_Application_Goal__c tempAppGoal = ag;
                        tempAppGoal.Completed__c = true;
                        updateAppGoals.add(tempAppGoal);
                    }
                }
                if(updateAppGoals.size()>0){
                    update updateAppGoals;
                }
            }                                               
        }                                                           
        //We're only interested in AGSs where the score was updated
        //get the AGs associated with these score-updated AGSs
        //return the AGs that have no unswered AGS records associated with them
        //return result;
    }
}