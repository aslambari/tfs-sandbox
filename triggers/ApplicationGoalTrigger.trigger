trigger ApplicationGoalTrigger on CCA2_Application_Goal__c (after update){
    if(ApplicationGoalScoreHelper.stopApplicationGoalTrigger == false){
        set<string> appIds = new set<string>();
        Set<String> excludedAGIds = new Set<String>();
        Set<String> appGoalIds = new Set<String>();
        for(CCA2_Application_Goal__c ag : Trigger.New){
            appGoalIds.add(ag.Id);
            if(ag.CCA2_Application__c!=null){
                appIds.add(ag.CCA2_Application__c);
            }
            if(ag.Exclude__c){
                excludedAGIds.add(ag.Id);
            }
        }
        
        //delete excluded AGS records.
        If(excludedAGIds.size()>0) {
            list<CCA2_Application_Goal_Score__c> AppGoalScoreList = [SELECT Id,CCA2_Application_Goal__c FROM CCA2_Application_Goal_Score__c 
                                                                      where CCA2_Application_Goal__c IN : excludedAGIds                                                                 
                                                                      AND CCA2_Response__r.Answer__c =: null];        
            if(AppGoalScoreList.size()>0)
                delete AppGoalScoreList;
        }    
        
        if(appGoalIds.size()>0){
            ApplicationGoalScoreHelper.stopApplicationGoalTrigger = true;
            ApplicationGoalScoreHelper.MarkAsCompleted(appGoalIds);            
            ApplicationGoalScoreHelper.stopApplicationGoalTrigger = false;
        }
           
        
        if(appIds.size()>0){
            ApplicationGoalHelper.MarkAsCompleted(appIds);
        }
    }    
}