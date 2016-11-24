public class TwilioCallHandler{
    public string caller {get;set;}
    public string called {get;set;}
    public string phoneNumber {get;set;}
    public TwilioCallHandler(){
        caller = ApexPages.currentPage().getParameters().get('Caller');
        if (caller.startsWith('+1'))
			caller = caller.substring(2);
        called = ApexPages.currentPage().getParameters().get('Called');
        if (called.startsWith('+1'))
			called = called.substring(2); 
        List<User> lstUsers = [SELECT Twilio_Number__c, Normalize_Phone__c from User where Twilio_Number__c =:called];
        if(lstUsers.size() > 0){
            phoneNumber = lstUsers.get(0).Normalize_Phone__c;
        }
    }
    
    public PageReference doInit(){
        Twilio_Call_History__c tch = new Twilio_Call_History__c();

        tch.To__c = called;          
        tch.From__c = caller;      
        tch.Status__c = 'New';
        insert tch;    
        return null;
    }
}