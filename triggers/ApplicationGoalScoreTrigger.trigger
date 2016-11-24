/*
        Name        : ApplicationGoalScoreTrigger
        Author      : iBirds
        Date        : 21 Jan, 2015
        Description : Trigger for delete all Application Goal Score For exclued Application.
*/
trigger ApplicationGoalScoreTrigger on CCA2_Application_Goal_Score__c (after update) {    
    Set<String> appGoalIds = new Set<String>();  
    for(CCA2_Application_Goal_Score__c ags : trigger.new){
         appGoalIds.add(ags.CCA2_Application_Goal__c);
    }  
   
    
    If(appGoalIds.size()>0) {
        list<CCA2_Application_Goal_Score__c> AppGoalScoreList = [SELECT Id,CCA2_Application_Goal__c FROM CCA2_Application_Goal_Score__c 
                                                                  where CCA2_Application_Goal__c IN : appGoalIds
                                                                  AND CCA2_Application_Goal__r.Exclude__c =: true
                                                                  AND CCA2_Response__r.Answer__c =: null];        
        if(AppGoalScoreList.size()>0)
            delete AppGoalScoreList;
    }
    //Mark as Completed
    set<string> applicationGoalIds = new set<string>();
    for(CCA2_Application_Goal_Score__c ags : Trigger.New){
        if(ags.Score__c != null && ags.Score__c != Trigger.oldMap.get(ags.Id).Score__c && ags.CCA2_Application_Goal__c!=null){
            applicationGoalIds.add(ags.CCA2_Application_Goal__c);
            
        }
    }
    system.debug('#####@@applicationGoalIds------>'+applicationGoalIds);
    if(applicationGoalIds.size()>0){
        //List<CCA2_Application_Goal__c> appGoalsCompleted = ApplicationGoalScoreHelper.getCompletedApplicationGoals(applicationGoalIds);
        ApplicationGoalScoreHelper.MarkAsCompleted(applicationGoalIds);
    }   
}