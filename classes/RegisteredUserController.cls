public class RegisteredUserController{
    public list<person__c> listPerson {get;set;}
    public integer listSizeUnRec{get;set;}
    public integer offsetVar {get;set;}
    
    public void init(){
        offsetVar = 0;
        listSizeUnRec= [select id from person__c where recordtype.name = 'Receiver' and Registration_Status__c = 'Approved' ].size();
        fetchApprovedUsers();
    }
    
    public void next(){
        offsetVar += 10;
        fetchApprovedUsers();
    }
    
    public void prev(){
        offsetVar -= 10;
        fetchApprovedUsers();
    }
    
    public void first(){
        offsetVar = 0;
        fetchApprovedUsers();
    }
    
    public void last(){
        offsetVar = listSizeUnRec-math.mod(listSizeUnRec,10);
        fetchApprovedUsers();
    }
    
    private void fetchApprovedUsers(){
        String query = 'select Reddit_Username__c from person__c where recordtype.name=\'Receiver\' and Registration_Status__c=\'Approved\' order by Date_Of_Approval__c desc';
        listPerson = Database.Query(query);
    }
}