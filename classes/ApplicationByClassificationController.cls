/*
                Name:      ApplicationByClassificationController
                Author:    
                Date:      28 Jan 2015
                Description: Controller to Group the applications According to the classification 
*/
public class ApplicationByClassificationController{
    public List<MainModel> mainModelList {get;set;}
    public string agsId;
    public String questxt{get;set;}
    
    //Constructor
    public ApplicationByClassificationController(){
        questxt = '';
        integer size = 15;
        mainModelList = new List<MainModel>();
        agsId = ApexPages.currentPage().getParameters().get('id');
        if(agsId!=null && agsId.trim().length()>0){
            
            list<CCA2_Application_Goal_Score__c> tempAGSList = [SELECT Id, Question__c,CCA2_Application_Goal__r.CCA2_Account_Goal__r.Account__r.Id, CCA2_Response__c, CCA2_Response__r.CCA2_Question__c FROM CCA2_Application_Goal_Score__c WHERE Id =: agsId];
            
            if(tempAGSList.size()>0){
                questxt = tempAGSList[0].Question__c;
                set<string> appIds = new set<string>();
                set<string> AccountIds = new set<string>();
                decimal maxQusScore = 0;
                
                for(CCA2_Application_Goal_Score__c ags : tempAGSList){
                    AccountIds.add(ags.CCA2_Application_Goal__r.CCA2_Account_Goal__r.Account__r.Id);
                }
                system.debug('####AccountIds--->'+AccountIds);
                AggregateResult[] groupedResults = [SELECT CCA2_Goals__c, Answer__r.Question__c, MAX(Score__c)maxScore 
                                                    FROM CCA2_Goal_Score__c 
                                                    WHERE Answer__r.Question__c =: tempAGSList[0].CCA2_Response__r.CCA2_Question__c 
                                                    GROUP BY Answer__r.Question__c, CCA2_Goals__c];
                
                if(groupedResults.size()>0){
                    for(AggregateResult agg : groupedResults){
                        string temp3 = ''+agg.get('maxScore')!=null ? ''+agg.get('maxScore') : '0';
                        maxQusScore += decimal.valueOf(temp3);
                    }
                }
            
                /*for(CCA2_Response__c res : [SELECT Id, CCA2_Application__c, CCA2_Question__c FROM CCA2_Response__c WHERE Id =: tempAGSList[0].CCA2_Response__c]){
                    appIds.add(res.CCA2_Application__c);
                }*/
                
                if(AccountIds.size()>0){
                    List<Application__c> applst = [SELECT name,ID, Classification__c 
                                                  FROM Application__c  
                                                  WHERE Account__c IN: AccountIds                                            
                                                  ORDER BY  Classification__c ASC LIMIT 1000];
                    for(Application__c app : applst){
                         appIds.add(app.Id);
                    }
                    system.debug('####appIds--->'+appIds);
                    if(appIds.size()>0){
                        map<string, decimal> appTotScoreMap = new map<string, decimal>();
                        for(AggregateResult agg : [SELECT CCA2_Application_Goal__r.CCA2_Application__c applId, SUM(score__c)totScore
                                                   FROM CCA2_Application_Goal_Score__c 
                                                   WHERE CCA2_Application_Goal__r.CCA2_Application__c IN: appIds 
                                                   AND CCA2_Response__c =: tempAGSList[0].CCA2_Response__c
                                                   Group by  CCA2_Application_Goal__r.CCA2_Application__c]){
                            if(!appTotScoreMap.containsKey(''+agg.get('applId'))){
                                string temp = ''+agg.get('totScore')!=null ? ''+agg.get('totScore') : '0';
                                appTotScoreMap.put(''+agg.get('applId'), decimal.valueOf(temp));
                            }
                            /*
                            if(!appTotScoreMap.containsKey(''+agg.get('applId'))){
                                string temp = ''+agg.get('maxScore')!=null ? ''+agg.get('maxScore') : '0';
                                appTotScoreMap.put(''+agg.get('applId'), decimal.valueOf(temp));
                            }else if(appTotScoreMap.containsKey(''+agg.get('applId'))){
                                string temp2 = ''+agg.get('maxScore')!=null ? ''+agg.get('maxScore') : '0';
                                appTotScoreMap.put(''+agg.get('applId'), appTotScoreMap.get(''+agg.get('applId'))+decimal.valueOf(temp2));
                            }*/
                        }
                    
                        Map<String,List<Application__c>> applicationMap = new Map<String,List<Application__c>>();
                        for(Application__c app : [SELECT name,  Classification__c 
                                                  FROM Application__c 
                                                  WHERE Id IN: appIds
                                                  ORDER BY  Classification__c ASC LIMIT 1000]){
                            List<Application__c> appList = applicationMap.get(app.Classification__c);
                            if(appList == null){
                                appList =  new List<Application__c>();
                            }
                            appList.add(app);
                            applicationMap.put(app.Classification__c, appList);
                        }
                        for(String classification : applicationMap.keySet()){
                            MainModel mModel = new MainModel();
                            mModel.classification = classification;
                            mModel.applicationModelList = new List<ApplicationListModel>();
                            Integer i = 1;
                            ApplicationListModel appModelList = new ApplicationListModel();
                            for(Application__c app : applicationMap.get(classification)){
                                    ApplicationModel appModel = new ApplicationModel();
                                    appModel.appName = app.Name;
                                    if(appTotScoreMap.containsKey(app.Id)){
                                        appModel.percentScore = appTotScoreMap.get(app.Id)>0 && maxQusScore>0 ? appTotScoreMap.get(app.Id)/maxQusScore*100 : 0;
                                    }
                                    
                                    appModelList.applicationList.add(appModel);
                                    if(math.mod(i,size)==0){
                                        mModel.applicationModelList.add(appModelList);
                                        appModelList = new ApplicationListModel();   
                                    }
                                    i++;     
                            }
                            for(integer p=0;p <= size-math.mod(i,size);p++){
                                appModelList.applicationList.add(new ApplicationModel());
                            }
                            if(math.mod(i,size)!=1){
                                 mModel.applicationModelList.add(appModelList);
                            }
                            mainModelList.add(mModel);
                        }
                    }
                }
            }
        }
    }
    
    public class MainModel{
        public String classification {get;set;}
        public List<ApplicationListModel> applicationModelList {get;set;}
        public MainModel(){
            applicationModelList = new List<ApplicationListModel>();
        }
    }
    public class ApplicationListModel{
        public List<ApplicationModel> applicationList {get;set;}
        public ApplicationListModel(){
            applicationList = new List<ApplicationModel>();
        }
    }
    public class ApplicationModel{
        public string appName{get;set;}
        public decimal percentScore{get;set;}
        
        public ApplicationModel(){
            percentScore = 0;
        }
    }
}