@isTest
public class TestTimeCardEntryController{
    @isTest
    private static void checkTimeCardEntryController(){
       account acc=new account();
       acc.name='Account First';
       insert acc;
        contact con=new contact();
        con.firstname='aslam';
        con.lastname='bari';
        con.accountId=acc.id;
        insert con;
        Project__c prjObj=new Project__c();
       prjObj.Account__c=acc.id;
       prjObj.Customer_Owner__c=con.id;
       prjObj.deployed__c=true;   
       prjObj.Description__c='aaa';
       insert prjObj;
        case caseObj=new case();
        caseObj.Origin='Email';
       caseObj.Status='New';
       caseObj.subject='aaa';
       caseObj.description='www';
       caseObj.project__c=prjObj.id;
       insert caseObj;
           Project_Request__c prjRequestObj=new Project_Request__c();
           prjRequestObj.Actual_Hours__c=10;
           prjRequestObj.Case__c=caseObj.id;
           prjRequestObj.Completion_Summary__c='aaa';
           prjRequestObj.Description__c='ww';
           prjRequestObj.Developer__c=con.id;
           prjRequestObj.Project__c=prjObj.id;
           prjRequestObj.Status__c='New';
           insert prjRequestObj;
        Time_Card__c timeCardObj=new Time_Card__c();
        timeCardObj.Comments__c='abc';
        timeCardObj.Day__c=date.today();
        timeCardObj.Developer__c=prjRequestObj.Developer__c;
        timeCardObj.Hours__c=2.0;
        timeCardObj.Month_Ending__c=date.today();
        timeCardObj.Project_Request__c=prjRequestObj.id;
        timeCardObj.Week_Ending__c=date.today().toStartOfWeek().addDays(5);
        insert timeCardObj;
        TimeCardEntryController timeCardEntryObj=new TimeCardEntryController(new ApexPages.StandardController(timeCardObj));
        timeCardEntryObj.retrieveTimeCards();
        timeCardEntryObj.setTimeCardsList();
        timeCardEntryObj.addTimeCard();
        timeCardEntryObj.saveTimeCards() ;
    }
}