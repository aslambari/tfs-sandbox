/*
           Name : TestTotalTimeCardInfoController
     Class Name : TotalTimeCardInfoController 
         Author :
           Date : 3 April 2015 
    Description : Testing TotalTimeCardInfoController controllelr in this test class
*/
@isTest
public class TestTotalTimeCardInfoController{
    
    // testing method
    @isTest private static void startTest(){
        // insert account test record
        account a = new account();
        a.name = 'Defy';
        insert a;
        System.assertEquals(a.name ,'Defy');
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        //insert contact test record
        contact con = new contact();
        con.lastname = 'Jim aurthor';
        con.accountid = a.id;
        con.hourly_rate__c = 10;
        insert con;
        System.assertEquals(con.accountid , a.id);
        // insert payment test record 
        payment__c pay = new payment__c();
        pay.amount__c = 1000;
        pay.vendor__c = a.id; 
        pay.Date_Paid__c = date.today();
        // class instance
        TotalTimeCardInfoController ttcc = new TotalTimeCardInfoController(sc);
    }
}