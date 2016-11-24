/*
            Name                :    RegistrationController
            Author              :    
            Date                :    
            Description         :    This class is used in createProfile.page and ThankYouPage.page
*/

public class RegistrationController{
    public Person__c personObj {get;set;}
    private boolean registered;
    public string confirmPassword {get;set;}
    String errMsg = ''; 
    
    //Constructor
    public RegistrationController(){           
        registered=false;
        errMsg = '';
        personObj = new Person__c();
        confirmPassword = '';
        personObj.PasswordT__c = '';
    }
    
    public pagereference initForRegistration(){
        if( CookieHelperController.fetchCookieValue() != null && CookieHelperController.fetchCookieValue().length() != 0 ){
           return new PageReference('/HomePage').setRedirect(True);
        }
        return null;
    }

    
    //Registration of receiver
    public pagereference RegisterationOfReceiver(){
        if(validateForm()){
            list<Person__c> listPerson = [select id from person__c where Reddit_Username__c =: personObj.Reddit_Username__c ];
            if(listPerson.size() == 0 ){
                list<RecordType> listOfRT = [ select id,name from RecordType where name = 'Receiver' ];
                if( listOfRT.size() > 0 ){
                    personObj.RecordTypeid = listOfRT[0].id;
                    try{
                        personObj.IP_Address__c = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP') ;
                        personObj.Registration_Status__c = 'Registration in Progress';
                        insert personObj;      
                        registered=true;
                        Pagereference pg = new Pagereference('/loginPage?un='+personObj.Reddit_Username__c.trim()+'&pw='+personObj.PasswordT__c);
                        return pg;
                    }catch(Exception e){}    
                }            
            }
            else{
                errmsg='<li style="color:#cc0000;list-style: none;">This Reddit username already registered.</li>';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errMsg));
                return null;
            }
            
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errMsg));
            return null;
        }
        return null;
    }
    
    //Form validation checking
    private Boolean validateForm(){
        Boolean flag = true;
        errMsg = ''; 
        if(personObj.Name == null || personObj.Name.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Name.</li>';
            flag = false;
        }
        if(personObj.Reddit_Username__c== null || personObj.Reddit_Username__c.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Reddit Username.</li>';
            flag = false;
        }
        String emailPat = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';

        if(personObj.Email__c == null || personObj.Email__c.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Email.</li>';
            flag = false;
        }
        else if(!Pattern.matches(emailPat, personObj.Email__c)){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Valid Email Address.</li>';
            flag = false;
        }
        
        if(personObj.Phone__c == null || personObj.Phone__c.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Phone.</li>';
            flag = false;
        }
        
        if(personObj.PasswordT__c== null || personObj.PasswordT__c.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Password.</li>';
            flag = false;
        }
        else if(personObj.PasswordT__c.trim().length()<8){
            errMsg += '<li style="color:#cc0000;list-style: none;">Password should be 8 character long.</li>';
            flag = false;
        }
        if(confirmPassword == null || confirmPassword.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Confirm Password.</li>';
            flag = false;
        }
        else if(personObj.PasswordT__c != null && confirmPassword != personObj.PasswordT__c){
            errMsg += '<li style="color:#cc0000;list-style: none;">Password and Confirm Password did not matched.</li>';
            flag = false;
        }
        return flag;
    }
}