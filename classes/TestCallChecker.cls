public class TestCallChecker{
    @isTest
    private static void testController(){
        User u = [Select id, Twilio_Number__c from User where id=:UserInfo.getUserId()];
        Twilio_Call_History__c twh = new Twilio_Call_History__c();
        twh.Status__c = 'New';
        twh.To__c = u.Twilio_Number__c;
        insert twh;
        CallChecker cc = new CallChecker();
        cc.callagain();
        cc.handledCall();    
    }



}