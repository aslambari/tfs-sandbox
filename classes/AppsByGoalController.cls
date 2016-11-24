/*
            Name        :     AppsByGoalController
            Author      :     
            Date        :     28 Jan 2015
            Description :     Controller to show the "Apps By Goal" detail on the Account Goal Object
*/
public class AppsByGoalController{
    public List<CCA2_Application_Goal__c> applicationList {get;set;}
    public string goalName{get;set;}
    
    // Constructor
    public AppsByGoalController(){
        applicationList = new List<CCA2_Application_Goal__c>();
        String goalId =  Apexpages.currentPage().getParameters().get('goalid');
        String accId =  Apexpages.currentPage().getParameters().get('accid');
        if(goalId != null && goalId.trim().length()>0 && accId != null && accId.trim().length()>0){
            applicationList = [SELECT Id, CCA2_Application__r.Name, Total_X_Score__c, CCA2_Account_Goal__r.Account__c, CCA2_Account_Goal__r.CCA2_Goal__r.Name
                               FROM CCA2_Application_Goal__c 
                               WHERE CCA2_Account_Goal__r.CCA2_Goal__c = :goalId 
                               AND CCA2_Account_Goal__r.Account__c =: accId
                               Order By Total_X_Score__c DESC];
           
            if(applicationList.size()>0){
                goalName = applicationList[0].CCA2_Account_Goal__r.CCA2_Goal__r.Name;
            }
        }
    }
    
    public list<ModleData> getData(){
        list<ModleData> modleList = new list<ModleData>();
        for(CCA2_Application_Goal__c gScore : applicationList){             
             ModleData modelObj = new ModleData(''+gScore.CCA2_Application__r.Name, gScore.Total_X_Score__c);
             modleList.add(modelObj);
        }
        return modleList;
    }
    
    public class ModleData{
        public String appName{get;set;}
        public decimal percentageScore{get;set;}
        public ModleData(string applicationName, decimal score) {
            this.appName = applicationName;
            this.percentageScore = score != null ? score : 0;
        }
    }
}