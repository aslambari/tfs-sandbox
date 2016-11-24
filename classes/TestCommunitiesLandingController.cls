/*
        Name:TestCommunitiesLandingController
        
        Author:
        
        Date:3-April-2015
        
        Description:To test CommunitiesLandingController class
*/
@isTest
public class TestCommunitiesLandingController{
    @isTest
    private static void checkCommunitiesLandingController(){
        //Create an object of CommunitiesLandingController class
        CommunitiesLandingController communitiesObj=new CommunitiesLandingController();
        //Call forwardToStartPage() Method of CommunitiesLandingController class
        communitiesObj.forwardToStartPage();
    } 
}