public class TestTwilioCallHandler{
    @isTest
    private static void testController(){
        User u = [Select id, Twilio_Number__c from User where id=:UserInfo.getUserId()];
        ApexPages.currentPage().getParameters().put('Called',u.Twilio_Number__c);
        ApexPages.currentPage().getParameters().put('Caller',u.Twilio_Number__c);
       
        TwilioCallHandler tch = new TwilioCallHandler();
        tch.doInit();
    }

}