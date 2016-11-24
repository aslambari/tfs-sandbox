public class ApplicationResultController{
    private string appId;
    public String appName{get;set;}

    public ApplicationResultController(){
        appId = ApexPages.currentPage().getParameters().get('id');
        List<Application__c> applst = [Select id,name from Application__c where id =: appId ];
        appName = '';
        if(applst.size()>0)
            appName = applst[0].name;
    }
    
    public list<ModleData> getData(){
       
        list<ModleData> modleList = new list<ModleData>();
        for(CCA2_Application_Goal__c gScore:[select id,Application_Name__c,CCA2_Account_Goal__r.CCA2_Goal__r.Name,Total_X_Score__c from CCA2_Application_Goal__c where CCA2_Application__c=:appId]){             
             ModleData modelObj = new ModleData(gScore.CCA2_Account_Goal__r.CCA2_Goal__r.Name,gScore.Total_X_Score__c);
             modleList.add(modelObj);
        }
        return modleList;
    }
    
    public class ModleData{
        public String goalName{get;set;}
        public decimal percentageScore{get;set;}
        public ModleData(string golName, decimal score) {
            this.goalName = golName;
            this.percentageScore = score != null ? score : 0;
        }
    }
}