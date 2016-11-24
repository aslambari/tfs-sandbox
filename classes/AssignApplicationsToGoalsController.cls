public class AssignApplicationsToGoalsController{
    
    Private String accountId{get;set;}
    Private Map<String , CCA2_Goal__c> goalMap;
    Private Map<String, CCA2_Account_Goal__c> accountGoalMap;
    Private map<String, CCA2_Application_Goal__c > applicationGoalMap;
    Private set<String> applicationIdSet;
    Private set<String> questionIds;
    private Map<String , CCA2_Response__c> responceRecordMap;
    Private integer next=0;
    Private List<CCA2_Question__c> questionList;
    Private String ownerid;
    private set<String> qAppIdSet;
    
    Public String selectedGate{set;get;}
    Public integer listsize{get;set;}
    Public integer paginationLimit{get;set;}
    Public String goalListValue{set;get;}
    Public List<SelectOption> goalsList {set;get;}
    Public List<SelectOption> gateValues{set;get;}
    Public List<ModalApplication> modalList{set;get;}
    Public List<ModalApplication> modalAllList;
    Public Boolean unsignedApp{get;set;}
    public List<SelectOption> pagesizeOpts{get;set;}
   
    Public String SortDir{set;get;}
    Public String SortField{set;get;}    
    
    Public AssignApplicationsToGoalsController(){
        pagesizeOpts = new List<SelectOption>();
        pagesizeOpts.add(new SelectOption('10','10'));
        pagesizeOpts.add(new SelectOption('25','25'));
        pagesizeOpts.add(new SelectOption('50','50'));
        pagesizeOpts.add(new SelectOption('100','100'));
        selectedGate = '1';
        paginationLimit = 10;
        SortDir = 'ASC';
        SortField = 'Score';
        listsize = 0;
        ownerid = [select Id from Group where Name = 'unassigned' and Type = 'Queue' limit 1].id;
        System.debug('----ownerid----' + ownerid);
        // Inserting the Goal(Round) Values... Start
        gateValues = new List<SelectOption>();       
        List<AggregateResult> agglsttemp = [Select MAX(Gate__c) maxvlaue from CCA2_Question__c];
        integer gateVal;
        if(agglsttemp != NULL && agglsttemp.size()>0){ 
            AggregateResult aggResult = agglsttemp[0];           
            gateVal = Integer.valueOf(aggResult.get('maxvlaue')) ;
        }else{
            gateVal = 2;
        }
        System.debug('-------'+ gateVal );
        for(integer i = 1; i <= gateVal; i++){
            gateValues.add(new SelectOption(String.valueOf(i),String.valueOf(i))); 
        }
        if(gateValues.size()>0){
            selectedGate = String.valueOf(gateValues[0].getLabel());
        }
       // Inserting the Goal(Round) Values... End
        
        
        
        qAppIdSet = new set<String>();
        questionList = new List<CCA2_Question__c>();
        modalAllList = new List<ModalApplication>(); 
        applicationIdSet = new Set<String>();
        applicationGoalMap = new Map<String, CCA2_Application_Goal__c>();
        unsignedApp = false;
        modalList = new List<ModalApplication>();
        accountGoalMap = new Map<String, CCA2_Account_Goal__c>();
        goalMap = new Map<String , CCA2_Goal__c>();
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        goalsList = new List<SelectOption>();
        if(accountId !=NULL && accountId.trim().length()>0 ){
            goalsList = getItems();
            if(goalsList.size()>0)
                goalListValue = goalsList[0].getValue();
            addApplication(accountId);
        }
    }
    private List<SelectOption> getItems() {
        List<CCA2_Goal__c> glList = [SELECT id , name FROM CCA2_Goal__c];
        if(glList != null && glList.size()>0){
            for(CCA2_Goal__c goalObj : glList ){
                goalMap.put(goalObj.id , goalObj);  
            }
        }
        List<CCA2_Account_Goal__c> accountGoalList = [SELECT id, name, CCA2_Goal__r.name, CCA2_Goal__c FROM CCA2_Account_Goal__c where Account__c =: accountId];
        List<SelectOption> options = new List<SelectOption>();
        if(accountGoalList != null && accountGoalList.size()>0){
            for(CCA2_Account_Goal__c accObj : accountGoalList ){
                options.add(new SelectOption(accObj.CCA2_Goal__c , accObj.CCA2_Goal__r.name)); 
            }
        }
        options.sort();
        return options;
    }
    //Add the data in modal when gate piklist is change
    /*public void changeGate(){
        List<ModalApplication> modList = new List<ModalApplication>();
        set<String> appid = new set<String>();
        if(modalAllList.size()>0){
            for(ModalApplication mObj : modalAllList){
                appid.add(mObj.applicationObject.id);
            }
        }
        List<AggregateResult> acGlList = new List<AggregateResult>();
        acGlList = [SELECT Sum(Total_Score__c) total, CCA2_Application__c FROM CCA2_Application_Goal__c where CCA2_Application__r.id in:appid GROUP BY CCA2_Application__c];
        Map<String,Decimal> totalScoreMap = new Map<String,Decimal>(); 
        if(acGlList.size()>0){
            for(AggregateResult obj : acGlList){
                totalScoreMap.put((String)obj.get('CCA2_Application__c'),(Decimal)obj.get('total'));
            }
        }
        List<Application__c> apList = new List<Application__c>();
        apList = [SELECT id FROM Application__c WHERE id in:appid];
        creatingNewResponceRecord();
        modalAllList.clear();
        for(Application__c apObj : apList){
            ModalApplication tModalObj = new ModalApplication ();
            if(qAppIdSet.contains(apObj.id)){
                if(unsignedApp){
                   continue; 
                }
                modalObj.status = true;
                modalObj.already = true;
            }else{
                modalObj.status = false;
            }
        }
    }*/
    
    // This method add the date in the modal Object
    private void addApplication(String accId){
        modalAllList.clear();
        modalList.clear();
        applicationIdSet.clear();
        //Fetching Application Object which is child of Account
        List<Application__c> appList = [SELECT id, name, Type__c, Description__c,createddate FROM Application__c WHERE Account__c =: accId ORDER BY Name];
        
        //Create a set of Application ids for evaluation the total score
        set<String> appIds = new set<String>();
        if(appList != NULL && appList.size()>0){
             for(Application__c appObj : appList){
                appIds.add(appObj.id);
            }
        }
        //Fetching responce record
        Decimal tempRoundValue = decimal.valueOf(selectedGate);
        
        Set<string> alreadyCreatedResponse = new set<string>();
        set<string> currentRoundAppIds = new Set<String>();
        
       
       
        //Fetching the Application Goal for checking the existing application goal record (For assigning checkboxes)
        List<CCA2_Application_Goal__c> accGoalList = new List<CCA2_Application_Goal__c>();
        accGoalList = [SELECT id, name,  CCA2_Application__c, CCA2_Application__r.id FROM CCA2_Application_Goal__c where CCA2_Account_Goal__r.Account__r.id =:accId  AND CCA2_Account_Goal__r.CCA2_Goal__c =: goalListValue];
        set<String> AGIds =  new Set<String>();
        Set<String> applicationGoalAppIds = new Set<String>();
        if(accGoalList != NULL && accGoalList.size()>0){
            for(CCA2_Application_Goal__c  AGObj : accGoalList){
                AGIds.add(AGObj.CCA2_Application__r.id + '-' + goalListValue + '-' + selectedGate);
                applicationGoalMap.put(AGObj.CCA2_Application__r.id, AGObj);
                applicationGoalAppIds.add(AGObj.CCA2_Application__c);
            }
        }
        
        for(CCA2_Response__c rObj : [SELECT CCA2_Application__c, gate__c FROM CCA2_Response__c where CCA2_Application__c in: applicationGoalAppIds And Gate__c =: tempRoundValue-1 ]){
            alreadyCreatedResponse.add(rObj.CCA2_Application__c + '-' + goalListValue + '-' + rObj.gate__c);
        }
        for(CCA2_Response__c rObj : [SELECT CCA2_Application__c, gate__c FROM CCA2_Response__c where CCA2_Application__c in: applicationGoalAppIds And Gate__c =: tempRoundValue]){
            currentRoundAppIds.add(rObj.CCA2_Application__c + '-' + goalListValue + '-' + rObj.gate__c);
        }
        
        //Fetching the total score
        List<AggregateResult> acGlList = new List<AggregateResult>();
        acGlList = [SELECT Sum(Total_Score__c) total, CCA2_Application__c FROM CCA2_Application_Goal__c where CCA2_Application__r.id in:appIds  GROUP BY CCA2_Application__c];
        Map<String,Decimal> totalScoreMap = new Map<String,Decimal>(); 
        Set<String> excludedAppGoalIds = new Set<String>();
        if(acGlList.size()>0){
            for(AggregateResult obj : acGlList){
                totalScoreMap.put((String)obj.get('CCA2_Application__c'),(Decimal)obj.get('total'));                
            }
        }
        
        for(CCA2_Application_Goal__c obj : [select CCA2_Application__c, CCA2_Account_Goal__r.CCA2_Goal__c from CCA2_Application_Goal__c where CCA2_Application__r.id in:appIds AND Exclude__c = true]){
            excludedAppGoalIds.add(obj.CCA2_Application__c+'-'+obj.CCA2_Account_Goal__r.CCA2_Goal__c);
        }
        System.debug('@@@ excludedAppGoalIds==>'+excludedAppGoalIds);
        //Filling the Map of Application ,TotalScore and checkbox
         System.debug('-------alreadyCreatedResponse-----' + alreadyCreatedResponse);
        if(appList != NULL && appList.size()>0){
            for(Application__c appObj : appList){
                if(tempRoundValue > 1 && ! alreadyCreatedResponse.contains(appObj.id + '-' + goalListValue + '-' + (tempRoundValue-1))){
                   System.debug( appObj.id+'-------in if Ns-----' + alreadyCreatedResponse);
                   continue;
                }
                applicationIdSet.add(appObj.id);
                ModalApplication modalObj = new ModalApplication();
                System.debug('--NN--' + appObj.id);
                if(currentRoundAppIds.contains(appObj.id + '-' + goalListValue + '-' + selectedGate) && AGIds.contains(appObj.id + '-' + goalListValue  + '-' + selectedGate)){
                    if(unsignedApp){
                       continue; 
                    }
                    modalObj.status = true;
                    modalObj.already = true;
                }else{
                    modalObj.status = false;
                }
                system.debug('####excludedAppGoalIds---->'+excludedAppGoalIds.contains(appObj.id + '-' + goalListValue));
                if(excludedAppGoalIds.contains(appObj.id + '-' + goalListValue))
                    modalObj.excluded = true;
                if(totalScoreMap.containsKey(appObj.id)){
                    modalObj.score = Integer.valueOf(totalScoreMap.get(appObj.id));
                }else{
                    modalObj.score = 0;
                }
                modalObj.applicationObject = appObj;                
                modalAllList.add(modalObj); 
            }
            system.debug('####modalAllList---->'+modalAllList);
            //Pagingation Record Filling
            for(integer i=next; i< modalAllList.size() && i<next+paginationLimit; i++){
                modalList.add(modalAllList.get(i));
            } 
            system.debug('####modalList---->'+modalList);
            listsize = modalAllList.size();
            sortData();
        }
    }
   
    //Assigning all Application to Goal
    public pagereference assignedAll(){
        if(modalAllList.size()>0){
            for(integer i = 0; i<modalAllList.size(); i++){
                modalAllList[i].status = true;
            }  
        }
        pagereference obj = saveData();
        return obj;
    }
    public void accountGoal(){
        accountGoalMap.clear();
        List<CCA2_Account_Goal__c> accountGoalList = [SELECT id, name, CCA2_Goal__c,  CCA2_Goal__r.name FROM CCA2_Account_Goal__c where Account__c =: accountId AND CCA2_Goal__c =: goalListValue];
        if(accountGoalList  != NULL && accountGoalList.size()>0){
            for(CCA2_Account_Goal__c accGoalObj : accountGoalList ){
                 accountGoalMap.put(accountId + '-' + accGoalObj.CCA2_Goal__c  ,accGoalObj );
            }
        }
    }
    public pagereference saveData(){
        accountGoal();
        set<String> alreadyCreatedAppGoal = new set<String>();
        for(CCA2_Application_Goal__c  apGlObj : [Select id, CCA2_Application__c, CCA2_Account_Goal__c from CCA2_Application_Goal__c where CCA2_Application__c in: applicationIdSet] ){
            alreadyCreatedAppGoal.add(apGlObj.CCA2_Application__c + '-' + apGlObj.CCA2_Account_Goal__c);
        }
        List<CCA2_Account_Goal__c> accGoalList = new List<CCA2_Account_Goal__c>();
        list<CCA2_Application_Goal__c > saveApplicationGoalData = new List<CCA2_Application_Goal__c >();
        list<CCA2_Application_Goal__c > deleteApplicationGoalData = new List<CCA2_Application_Goal__c >();
        List<CCA2_Response__c> saveResponceRecord = new List<CCA2_Response__c>();
        List<CCA2_Response__c> deleteResponceRecord = new List<CCA2_Response__c>();
        CCA2_Account_Goal__c acGlObj = new CCA2_Account_Goal__c();
        if (! accountGoalMap.containsKey(accountId + '-' + goalListValue)){
            acGlObj.Account__c = accountId;
            acGlObj.CCA2_Goal__c = goalMap.get(goalListValue).id;
            insert acGlObj;
            System.debug('--Account Goal---');
            
        }else{
            acGlObj = accountGoalMap.get(accountId + '-' + goalListValue);
        }
        Set<String> selectedAppIds = new Set<String>();
        map<string, list<CCA2_Application_Goal__c>> AppGoalMap = new map<string, list<CCA2_Application_Goal__c>>();
        
        for(ModalApplication modalObj : modalAllList){
            if(!alreadyCreatedAppGoal.contains(modalObj.applicationObject.id + '-' + acGlObj.id) && modalObj.status){
                CCA2_Application_Goal__c  appGoalObj = new CCA2_Application_Goal__c();
                appGoalObj.CCA2_Account_Goal__c = acGlObj.id;
                appGoalObj.CCA2_Application__c = modalObj.applicationObject.id;
                saveApplicationGoalData.add(appGoalObj);
                
                if(!AppGoalMap.containsKey(''+appGoalObj.CCA2_Application__c)){
                    AppGoalMap.put(''+appGoalObj.CCA2_Application__c, new list<CCA2_Application_Goal__c>());
                }
                AppGoalMap.get(''+appGoalObj.CCA2_Application__c).add(appGoalObj);
                
            }
            if(modalObj.status){
                selectedAppIds.add(modalObj.applicationObject.id);
            }
        }
        
        if(saveApplicationGoalData.size()>0)
            insert saveApplicationGoalData;
        if(selectedAppIds.size()>0){            
            System.debug('----savedata NNS-----' + saveApplicationGoalData);
            creatingNewResponceRecord();
            System.debug('----creatingNewResponceRecord NNS-----'+ responceRecordMap);
            System.debug('@@@ questionIds==>'+questionIds);
            for(String aId : selectedAppIds){
                for(String qId : questionIds){
                    if(!responceRecordMap.containsKey(aId + '-' + qId)){
                        CCA2_Response__c resObj    = new CCA2_Response__c();
                        resObj.CCA2_Application__c = aId;
                        resObj.CCA2_Question__c    = qId;
                        resObj.Gate__c             = Decimal.valueOf(selectedGate);
                        resObj.Ownerid             = ownerid;
                        saveResponceRecord.add(resObj);
                    }
                }
            }
            System.debug('----NNS-----' + saveResponceRecord);
            if(saveResponceRecord.size()>0){
                insert saveResponceRecord;
                System.debug('-------NSNS-----' + questionList);
                
                System.debug('####saveResponceRecord--->'+saveResponceRecord.size()+'<----->'+saveResponceRecord);
                System.debug('####AppGoalMap--->'+AppGoalMap);
                System.debug('####saveApplicationGoalData--->'+saveApplicationGoalData.size());
                System.debug('####saveResponceRecord--->'+saveResponceRecord.size());
                list<CCA2_Application_Goal_Score__c> insertAGS = new list<CCA2_Application_Goal_Score__c>();
                
                Set<String> appGoalIds = new Set<String>();
                for(CCA2_Application_Goal__c appGoal : saveApplicationGoalData){
                    appGoalIds.add(appGoal.Id);
                }
                
                List<CCA2_Application_Goal__c> insetedAGlst = [Select id,CCA2_Account_Goal__r.CCA2_Goal__c,CCA2_Application__c from CCA2_Application_Goal__c where Id IN : appGoalIds];
                Map<String,Set<String>> goalQuesMap = new Map<String,Set<String>>();                      
                for(CCA2_Goal_Question__c gq : [SELECT Id, CCA2_Goal__c, CCA2_Question__c, CCA2_Question__r.id, CCA2_Question__r.Gate__c, Unique_Id__c 
                                                   FROM CCA2_Goal_Question__c
                                                   WHERE CCA2_Goal__c =: goalListValue]){
                      Set<String> templst = goalQuesMap.get(gq.CCA2_Goal__c);
                      if(templst == null)
                          templst = new Set<String>();
                      templst.add(gq.CCA2_Question__c);
                      goalQuesMap.put(gq.CCA2_Goal__c,templst);
                }
                
                
                for(CCA2_Application_Goal__c appGoal : insetedAGlst){
                    for(CCA2_Response__c res : saveResponceRecord){
                        set<String> questionIdSet = goalQuesMap.get(appGoal.CCA2_Account_Goal__r.CCA2_Goal__c);
                        if(questionIdSet != null && questionIdSet.contains(res.CCA2_Question__c)){
                            CCA2_Application_Goal_Score__c ags = new CCA2_Application_Goal_Score__c();
                            ags.CCA2_Application_Goal__c = appGoal.Id;
                            ags.CCA2_Response__c = res.Id;
                            insertAGS.add(ags);
                        }
                    }
                }
                System.debug('####insertAGS--->'+insertAGS);
                if(insertAGS.size()>0){
                    insert insertAGS;
                }
                
                /*
                if(questionList.size()>0){
                    System.debug('-------NSNS -in if----'+ questionList[0].Gate__c);
                    //integer i=0;
                    for(Integer i = 0; i<questionList.size(); i++){
                        if(questionList[i].Gate__c == NULL || (Integer.valueOf(selectedGate) > questionList[i].Gate__c)){
                            questionList[i].Gate__c = Integer.valueOf(selectedGate);
                        }
                    }
                    System.debug('----NNS before upsert-----' + questionList);
                    upsert questionList;
                }
                */
            }
       }
        for(ModalApplication modalObj : modalList){
            if(modalObj.status == false && modalObj.already){
                //System.debug('-----NN--already' + modalObj );
                if(applicationGoalMap.containsKey(modalObj.applicationObject.id)){
                    deleteApplicationGoalData.add(applicationGoalMap.get(modalObj.applicationObject.id));
                }
            }
        }
        if(deleteApplicationGoalData.size()>0){
            //System.debug('-----NN--already--delete' + deleteApplicationGoalData);
            creatingNewResponceRecord();
            for(CCA2_Application_Goal__c apGlObj : deleteApplicationGoalData){
                for(String qId : questionIds){
                    if(responceRecordMap.containsKey(apGlObj.CCA2_Application__r.id + '-' + qId)){
                        deleteResponceRecord.add(responceRecordMap.get(apGlObj.CCA2_Application__r.id + '-' + qId));
                    }
                }
            }
            if(deleteResponceRecord.size()>0){
                delete deleteResponceRecord;
            }
            delete deleteApplicationGoalData;
        }
        //return new pagereference('/' + accountId);
        return new pagereference('/apex/AssignApplicationsToGoals?accountId='+accountId);
    }
    public void changeSelectList(){
        next = 0;
        modalList.clear();
        modalAllList.clear();
        addApplication(accountId);
    }
    public pagereference cancel(){
         return new pagereference('/' + accountId);
    }
    public void creatingNewResponceRecord(){
        Decimal gt = Decimal.valueOf(selectedGate);
        List<CCA2_Goal_Question__c> goalQuestionList = [SELECT id, name, CCA2_Question__c, CCA2_Question__r.id FROM CCA2_Goal_Question__c WHERE CCA2_Goal__c =: goalListValue And CCA2_Question__r.Gate__c=: gt];
        questionIds = new Set<String>();
        if(goalQuestionList != NULL && goalQuestionList.size()>0){
            for(CCA2_Goal_Question__c GQObj : goalQuestionList){
                questionIds.add(GQObj.CCA2_Question__r.id);
            }
        }
        questionList.clear();
        if(questionIds.size()>0)
            questionList = [SELECT id, name, Gate__c FROM CCA2_Question__c where id in: questionIds];
        chkResponceRecord();
        
    }
    public void chkResponceRecord(){
        List<CCA2_Response__c> responceRecordList = [SELECT id, name, CCA2_Question__c, CCA2_Application__r.id ,CCA2_Question__r.id  FROM CCA2_Response__c where CCA2_Application__c in: applicationIdSet AND CCA2_Question__c in: questionIds];
        responceRecordMap = new Map<String , CCA2_Response__c>();
        qAppIdSet.clear();
        if(responceRecordList != NULL && responceRecordList.size()>0){
            for(CCA2_Response__c resObj : responceRecordList){
                responceRecordMap.put(resObj.CCA2_Application__r.id + '-' + resObj.CCA2_Question__r.id ,resObj);
                qAppIdSet.add(resObj.CCA2_Application__r.id);
            }
        }
    }
    
     /*Pagination Functionallity start here*/
    //Next
    public void next(){
        next += paginationLimit;
        modalList.clear();
        for(integer i=next; i< modalAllList.size() && i<next+paginationLimit; i++){     
            modalList.add(modalAllList.get(i));
        }   
    }
    
    //First
    public void first(){
        next = 0;
        modalList.clear();
        for(integer i=next; i< modalAllList.size() && i<next+paginationLimit; i++){     
            modalList.add(modalAllList.get(i));     
        }       
    }
    
    //Last
    public void last(){
        next = math.mod(integer.valueOf(modalAllList.size()),paginationLimit);
        if(next==0){
            next=paginationLimit;
        }
        modalList.clear();
        for(integer i=modalAllList.size()-next; i< modalAllList.size() ; i++){       
            modalList.add(modalAllList.get(i));
        }   
        next=modalAllList.size()-next;  
    }
   
    //Prev
    public void prev(){
        next -= paginationLimit;
        modalList.clear();
        for(integer i=next; i< modalAllList.size() && i<next+paginationLimit; i++){       
            modalList.add(modalAllList.get(i));       
        }          
    }
    
    public integer getPagePosition(){
        return next;
    }
    
    public void sortData(){
        list<ApplicationWraper> ApplicationWraperList = new list<ApplicationWraper>();
        for(ModalApplication ma : modalAllList){
            ApplicationWraper aw = new ApplicationWraper(ma.status, ma.already, ma.excluded, ma.unsignedStatus, ma.score, ma.applicationObject);
            ApplicationWraperList.add(aw);
        }
        
        if(SortField == 'ApplicationName'){
            ApplicationWraper.SORT_FIELD = ApplicationWraper.SortField.ApplicationName;
        }else if(SortField == 'Type'){
            ApplicationWraper.SORT_FIELD = ApplicationWraper.SortField.Type;
        }else if(SortField == 'CreatedDate'){
            ApplicationWraper.SORT_FIELD = ApplicationWraper.SortField.CreatedDate;
        }else if(SortField == 'Score'){
            ApplicationWraper.SORT_FIELD = ApplicationWraper.SortField.Score;
        }
        system.debug('#####SortDir ---->'+SortDir);
        if(SortDir == 'ASC'){
            ApplicationWraper.SORT_DIR = ApplicationWraper.SortDirection.DESCENDING;
            SortDir = 'DESC';
        }else{
            ApplicationWraper.SORT_DIR = ApplicationWraper.SortDirection.ASCENDING;
            SortDir = 'ASC';
        }
        
        ApplicationWraperList.sort();
        modalAllList.clear();
        for(ApplicationWraper aw : ApplicationWraperList){
            ModalApplication ma = new ModalApplication();
            ma.unsignedStatus = aw.unsignedStatus;
            ma.status = aw.status;
            ma.excluded = aw.excluded;
            ma.already = aw.already;
            ma.applicationObject = aw.applicationObject;
            ma.Score = aw.Score;
            modalAllList.add(ma);
        }
        modalList.clear();
        next = 0;
        for(integer i=next; i< modalAllList.size() && i<next+paginationLimit; i++){
            modalList.add(modalAllList.get(i));
        } 
        listsize = modalAllList.size();
    }
    
    /*Pagination Functionallity end here*/
    public class ModalApplication{
        Public Boolean unsignedStatus{set;get;}
        Public Boolean status{set;get;}
        Public Boolean already{set;get;}
        public Boolean excluded{get;set;}
        Public Application__c applicationObject{get;set;}
        Public Integer score {set;get;}
        public ModalApplication(){
            status = false;
            excluded = false;
            already = false;
            unsignedStatus = false;
            score = 0;
            applicationObject = new Application__C();
        }
    }
}