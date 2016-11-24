/*
        Name:TestCreatePRController
        
        Author:
        
        Date:3-April-2015
        
        Description:To Test CreatePRController Class
*/
@isTest
public class TestCreatePRController{
  @isTest
   private static void checkCreatePRController(){
       //Create an object of account 
       account acc=new account();
       acc.name='Account First';
       insert acc;
       
       //Create an object of contact
       contact con=new contact();
       con.lastname='ssd';
       con.accountid=acc.id;
       insert con;
       
       //Create an object of Project__c
       Project__c prjObj=new Project__c();
       prjObj.Account__c=acc.id;
       prjObj.Customer_Owner__c=con.id;
       prjObj.deployed__c=true;   
       prjObj.Description__c='aaa';
       insert prjObj;
       
       //Create an object of case
       case caseObj=new case();
       caseObj.Origin='Email';
       caseObj.Status='New';
       caseObj.subject='aaa';
       caseObj.description='www';
       caseObj.project__c=prjObj.id;
       insert caseObj;
       CreatePRController createPrControllerObj=new CreatePRController(new ApexPages.StandardController(caseObj));
       createPrControllerObj.createPR(); 
       //Create an object of Project_Request__c
       Project_Request__c prjRequestObj=new Project_Request__c();
       prjRequestObj.Actual_Hours__c=10;
       prjRequestObj.Case__c=caseObj.id;
       prjRequestObj.Completion_Summary__c='aaa';
       prjRequestObj.Description__c='ww';
       prjRequestObj.Developer__c=con.id;
       prjRequestObj.Project__c=prjObj.id;
       prjRequestObj.Status__c='New';
       insert prjRequestObj;
  
      //Create an object of CreatePRController class and pass an argument of ApexPages.StandardController class 
     CreatePRController createPrControllerObj1=new CreatePRController(new ApexPages.StandardController(caseObj));
       //Call createPR() method of CreatePRController class
       system.assertEquals('New',prjRequestObj.Status__c);
       system.assertEquals(caseObj.id,prjRequestObj.Case__c);
       createPrControllerObj1.createPR();         
   } 
}