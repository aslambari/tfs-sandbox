public class AssigningtheQuestionsController{
    private String accId;
    public List<SelectOption> listOfSelOpt {get;set;}
    public string selectedUser {get;set;}
    public boolean shoUnsQueOnly {get;set;}
    public list<AnsweringModel> listOfModel ;
    public list<AnsweringModel> listOfModelForPage {get;set;}
    private integer next=0;
    public integer paginationLimit{get;set;}
    public integer listsize{get;set;}
    public string direc {get;set;}
    public string fiedlsToSort {get;set;}
    public List<SelectOption> pagesizeOpts{get;set;}
    
    private list<profile> listProfile;
    private string OldfiedlsToSort ;
    //Constructor
    public AssigningtheQuestionsController(){  
        listsize=0;
        pagesizeOpts = new List<SelectOption>();
        pagesizeOpts.add(new SelectOption('10','10'));
        pagesizeOpts.add(new SelectOption('25','25'));
        pagesizeOpts.add(new SelectOption('50','50'));
        pagesizeOpts.add(new SelectOption('100','100'));
        paginationLimit = 10;
        fiedlsToSort = 'CCA2_Application__r.name';
        OldfiedlsToSort = '';
        direc = 'Asc';
        
        accId = ApexPages.currentPage().getParameters().get('accid');
        //Filling list of portal user 
        listOfSelOpt = new List<SelectOption>();            
        for( User usr : getAccountUsers( accId ) ){
            listOfSelOpt.add(new SelectOption(usr.id,usr.name));
        }
        listOfSelOpt.sort();  
        fetchData();
    }
    
    //Function for fetch users
    private List<User> getAccountUsers(String accountId){
        listProfile = [ select id from profile where name ='High Volume Customer Portal User' ];
        //list<user> lstUser = [ select IsPortalEnabled,AccountId,name,id from user where IsPortalEnabled = true and AccountId =: accountId and ProfileId =: listProfile[0].id ];
        List<user> lstUser = new list<user>();
        
        lstUser = [ select IsPortalEnabled,AccountId,name,id from user where id =:  Userinfo.getUserId()  ];
        return lstUser;
    }
    
    public void fetchUnassignedQues(){
        next=0;
        fetchData();
    }
    
    //public method for fetch data
    public void fetchData(){
        list<Account> lstAccount = [ select id from account where id =: accId];
        if( lstAccount.size() > 0 ){
            list<Application__c> lstAppli = [ select id from Application__c where Account__c =: lstAccount[0].id ];
            String idStr='';
            integer vk=1;
            for( Application__c app : lstAppli ){
                if( vk == lstAppli.size() ){
                    idStr+='\''+app.id+'\'';
                }else{
                    idStr+='\''+app.id+'\',';
                }
                vk++;
            }
            if( lstAppli .size() > 0 ){
                String query = ''; 
                list<CCA2_Response__c > listRespTemp ;     
                  
                query  = 'select ownerid,owner.name,CCA2_Application__c,CCA2_Application__r.name,CCA2_Application__r.Id,CCA2_Question__c,CCA2_Question__r.Id,CCA2_Question__r.Name ,CCA2_Question__r.Category__c,id from CCA2_Response__c where CCA2_Application__c in ('+ idStr +')';
                if( shoUnsQueOnly == true ){
                    list<Group> listOfGroup = [ select Id from Group where Name = 'unassigned' and Type = 'Queue' ] ;
                    if( listOfGroup.size() > 0 ){
                        query +=' and ownerID = \'' + listOfGroup[0].id + '\'' ;
                    }
                }
                if( OldfiedlsToSort != fiedlsToSort ){
                    direc = 'Asc';
                }            
                query +=' order by '+fiedlsToSort + ' ' + direc;
                listRespTemp = database.query(query);

                OldfiedlsToSort = fiedlsToSort ;
                listOfModel = new list<AnsweringModel>();
                listOfModel.clear();
                for( CCA2_Response__c repObj : listRespTemp ){
                        AnsweringModel AM = new AnsweringModel();
                        AM.Application  = repObj.CCA2_Application__r.name ;
                        AM.Category = repObj.CCA2_Question__r.Category__c;
                        AM.Questions = repObj.CCA2_Question__r.Name ;
                        AM.AssignedTo = repObj.owner.name;                        
                        AM.tempResponse = repObj;
                        if( repObj.ownerID == '005i0000001f12i'){
                            //AM.AssignedTo = '';    
                        }
                        
                        AM.ID = repObj.id;
                        AM.status = false;
                        listOfModel.add(AM);
                }
                listOfModelForPage = new list<AnsweringModel>();        
                for(integer i=next; i< listOfModel.size() && i<next+paginationLimit; i++){
                    listOfModelForPage.add(listOfModel.get(i));
                } 
                listsize = listOfModel.size();
            }
        }
    }
     
    //Update data
    public pagereference updateData(){
        list<CCA2_Response__c > updtResponse = new list<CCA2_Response__c>();
        for( AnsweringModel AM : listOfModel ){
            if(AM.status == true ){
                CCA2_Response__c repObj = new CCA2_Response__c ();
                repObj.id = AM.ID ;
                repObj.ownerId = selectedUser ;
                updtResponse.add(repObj);
            }
        }
        if( updtResponse.size() > 0 ){
            try{
                update updtResponse;
            }catch(Exception e){}
        }
        fetchData();
        pagereference pg=new pagereference('/apex/AssigningtheQuestions?accId='+accId);
        pg.setRedirect(True);
        return pg;
    }
    
    /*Pagination Functionallity start here*/
    //Next
    public void next(){
        next += paginationLimit;
        listOfModelForPage.clear();
        for(integer i=next; i< listOfModel.size() && i<next+paginationLimit; i++){     
            listOfModelForPage.add(listOfModel.get(i));
        }   
    }
    
    //First
    public void first(){
        next = 0;
        listOfModelForPage.clear();
        for(integer i=next; i< listOfModel.size() && i<next+paginationLimit; i++){     
            listOfModelForPage.add(listOfModel.get(i));     
        }       
    }
    
    //Last
    public void last(){
        next = math.mod(integer.valueOf(listOfModel.size()),paginationLimit);
        if(next==0){
            next=paginationLimit;
        }
        listOfModelForPage.clear();
        for(integer i=listOfModel.size()-next; i< listOfModel.size() ; i++){       
            listOfModelForPage.add(listOfModel.get(i));
        }   
        next=listOfModel.size()-next;  
    }
   
    //Prev
    public void prev(){
        next -= paginationLimit;
        listOfModelForPage.clear();
        for(integer i=next; i< listOfModel.size() && i<next+paginationLimit; i++){       
            listOfModelForPage.add(listOfModel.get(i));       
        }          
    }
    
    public integer getPagePosition(){
        return next;
    }
    /*Pagination Functionallity end here*/
    
    //Model class for Assigning questions
    public class AnsweringModel{
        public string Application {get;set;}
        public string Category {get;set;}
        public string Questions {get;set;}
        public string AssignedTo {get;set;}
        public string ID {get;set;}
        public boolean status {get;set;}       
        public CCA2_Response__c tempResponse{get;set;}
    }
}