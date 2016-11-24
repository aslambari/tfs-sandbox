/*
            Name            :    SignInController
            Author          :    
            Date            :    
            Description     :    This class is used on LoginPage.page
*/
public class SignInController{
    public String username {get;set;}
    public String password {get;set;}
    public String errorMsg {get;set;}
    
    //Init for loginpage
    public pagereference init(){
        if(CookieHelperController.fetchCookieValue() != null ){
            return new PageReference('/HomePage');
        }
        String un = ApexPages.currentPage().getParameters().get('un');
        String pw = ApexPages.currentPage().getParameters().get('pw');
        
        if( un != null && pw != null ){
            username = un ;
            password = pw ;
            return login();
        }
        return null;
    }    
    
    //Login Functionality
    public pagereference login(){
        if(username.trim().length() != 0 && password.trim().length() != 0){
            list<person__c> listOfPerson = [ select id,Registration_Status__c ,recordtype.name,reddit_username__c,PasswordT__c,name from person__c where reddit_username__c =: username limit 1];
            if(listOfPerson.size() > 0){
                if(listOfPerson[0].PasswordT__c == password ){
                    CookieHelperController.makeCookie(listOfPerson[0].id);
                    Pagereference pg; 
                    
                    if( listOfPerson[0].recordtype.name=='Receiver' && !( listOfPerson[0].Registration_Status__c =='Awaiting Review' || listOfPerson[0].Registration_Status__c =='Approved' )){
                        pg = new PageReference('/InfoEdit');
                    } else{
                        pg = new PageReference('/HomePage');
                    }                               
                    pg.SetRedirect(true);
                    return pg;
                }
                else{
                    errorMsg='Error : Username and password is incorrect';
                }
            }
            else{
                errorMsg='Error : Username and password is incorrect';
            }
        }else{
            errorMsg='Error : Please enter username and password';
        }
        return null;
    }
}