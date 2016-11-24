public class CallChecker{
    public string userphone {get;set;}
    public string contactId {get;set;}
    public string log {get;set;}
    public CallChecker(){
        userphone = [Select Id, Twilio_Number__c from User where id=:UserInfo.getUserId()].Twilio_Number__c;
        userphone = userphone.trim();
        contactId = '';
    }
    
    public PageReference callagain(){
        List<Twilio_Call_History__c> callList =  [SELECT Id, To__c, From__c, Status__c from Twilio_Call_History__c WHERE Status__c ='New' and To__c =:userphone order by createddate desc limit 1];
        log = callList.size() + '-ttt';
        if(callList.size() > 0){
            Twilio_Call_History__c tch = callList.get(0);
            List<Contact> contactList = [SELECT Id from Contact where Normalize_Phone__c =:tch.From__c LIMIT 1];
            if(contactList.size() > 0){
                contactId = contactList.get(0).Id;
            }
            tch.Status__c = 'Picked';
            update tch;
        }
        return null;
    }
    
    public PageReference handledcall(){ 
        contactId = '';
        return null;
    }
}