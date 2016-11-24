public with sharing class ApplicationGoalHelper {

    public static void MarkAsCompleted(set<string> appIds) {
        list<Application__c> Applications = [SELECT Id, Completed__c, //Best_Fit_Goal__c,
                                             (SELECT Id, Completed__c, CCA2_Application__c, Total_X_Score__c, CCA2_Account_Goal__r.CCA2_Goal__r.Name
                                              FROM CCA2_Application_Goals__r 
                                              ORDER BY Total_X_Score__c DESC)
                                             FROM Application__c
                                             WHERE Id IN: appIds];
                                             
        Map<String,Application__c> applicationMap = new Map<string,Application__c>([SELECT Id, Completed__c, //Best_Fit_Goal__c,
                                                                                 (SELECT Id,Number_of_Answered_Questions_Formula__c, CCA2_Account_Goal__r.CCA2_Goal__r.Name
                                                                                  FROM CCA2_Application_Goals__r 
                                                                                  ORDER BY Number_of_Answered_Questions_Formula__c DESC)
                                                                                 FROM Application__c
                                                                                 WHERE Id IN: appIds]);
    
        if(Applications.size()>0){
            for(Application__c app : Applications){
                if(app.CCA2_Application_Goals__r.size()>0){
                    app.Completed__c = true;                    
                    for(CCA2_Application_Goal__c appGoal : app.CCA2_Application_Goals__r){
                        if(!appGoal.Completed__c){
                            app.Completed__c = false;
                        }
                    }
                    if(app.Completed__c){
                        app.Best_Fit_Goal__c = app.CCA2_Application_Goals__r[0].Total_X_Score__c>0 ? app.CCA2_Application_Goals__r[0].CCA2_Account_Goal__r.CCA2_Goal__r.Name : 'Keep on premise';
                        
                        if(applicationMap.containskey(app.Id) &&  applicationMap.get(app.Id).CCA2_Application_Goals__r.size()>0){
                            Application__c tempApp = applicationMap.get(app.Id);
                            app.Best_Goal_For_App_Number_Of_Questions__c = tempApp.CCA2_Application_Goals__r[0].Number_of_Answered_Questions_Formula__c > 0 ? tempApp.CCA2_Application_Goals__r[0].CCA2_Account_Goal__r.CCA2_Goal__r.Name : 'Keep on premise';
                        }
                    }
                }
            }
            update Applications;
        }
    }
}