@isTest
public class RAOCTest{
    public static testMethod void unit(){
        //Admin RecordType
        list<RecordType> AdminRTID = [ select id from recordtype where name='Admin' limit 1];

        /*Create Admin*/
        Person__c perAdmin = new Person__c();
        perAdmin.Name = 'testAdm';
        perAdmin.Reddit_Username__c = 'testAdmRed';
        perAdmin.Email__c = 'vishnu1@gmail.com';
        perAdmin.phone__c = '12346789';
        perAdmin.passwordT__c='1234567889';
        perAdmin.recordtypeid = AdminRTID[0].id;
        insert perAdmin;
        perAdmin = [ select Reddit_Username__c ,id,Email__c ,phone__c ,name,passwordT__c from person__c where id =: perAdmin.id limit 1];
        system.assertEquals('1234567889',perAdmin.passwordT__c );
        
        Person__c perRec = new Person__c();
        
        /*RegistrationController --------Start here-------*/
        RegistrationController RegCntl = new RegistrationController();
        RegCntl.initForRegistration();
        RegCntl.personObj.Name = 'testRec';
        RegCntl.personObj.Reddit_Username__c = 'testRecRed';
        RegCntl.personObj.Email__c = 'vishnu@gmail.com';
        RegCntl.personObj.phone__c = '12346789';
        RegCntl.personObj.PasswordT__c = '12345678';
        RegCntl.confirmPassword = '12345678';
        RegCntl.RegisterationOfReceiver();
        
        RegCntl.personObj.Name = '';
        RegCntl.personObj.Reddit_Username__c = '';
        RegCntl.personObj.Email__c = '';
        RegCntl.personObj.phone__c = '';
        RegCntl.personObj.PasswordT__c = '';
        RegCntl.confirmPassword = '';
        RegCntl.RegisterationOfReceiver();
        
        RegCntl.personObj.Email__c = 'ssss';
        RegCntl.personObj.PasswordT__c = '123';
        RegCntl.confirmPassword = '234';
        RegCntl.RegisterationOfReceiver();
        /*RegistrationController --------End here-------*/
        
        /*SignInController --------Start here-------*/
        SignInController SIC = new SignInController();
        SIC.init();
        SIC.username = '';
        SIC.password = '';
        SIC.login();
        
        SIC.username = 'testRcRed';
        SIC.password = '1234578';
        SIC.login();
        
        SIC.username = 'testRecRed';
        SIC.password = '12345678';
        SIC.login();
        
        HomeController Hctrl = new HomeController();
        Hctrl.logout();
        
        ApexPages.currentPage().getParameters().put('un','testRecRed');
        ApexPages.currentPage().getParameters().put('pw','12345678');
        SIC.init();
        /*SignInController --------End here-------*/
        
        perRec = [ select id,name from person__c where name='testRec' limit 1];
        perRec.Registration_Status__c = 'Awaiting Review';
        update perRec;
        
        /*HomeController--------Start here-------*/
        SIC.username = 'testRecRed';
        SIC.password = '12345678';
        SIC.login();
        Hctrl = new HomeController();
        Hctrl.initForHomePage();
        Hctrl.initForEditInformation();
        Hctrl.submitForReview();
        Hctrl.goToEditMode();
        Hctrl.cancelMode();
        Hctrl.savePersonInfo();
        ApexPages.currentPage().getParameters().put('chId','');
        ApexPages.currentPage().getParameters().put('chName','vishChild');
        ApexPages.currentPage().getParameters().put('chAge','15');
        ApexPages.currentPage().getParameters().put('chwishlist','www.google.com');
        Hctrl.updateChild();
        ApexPages.currentPage().getParameters().put('chId','');
        ApexPages.currentPage().getParameters().put('chName','vishChild1');
        ApexPages.currentPage().getParameters().put('chAge','15');
        ApexPages.currentPage().getParameters().put('chwishlist','www.google.com');
        Hctrl.updateChild();
        list<person__c> listChild = [ select id,name,age__c from person__c where name='vishChild' limit 1];
        ApexPages.currentPage().getParameters().put('chId',listChild[0].id);
        ApexPages.currentPage().getParameters().put('chName','vishChild');
        ApexPages.currentPage().getParameters().put('chAge','16');
        ApexPages.currentPage().getParameters().put('chwishlist','www.google.com');
        Hctrl.updateChild();
        Hctrl.imgbody = blob.valueOf('test');
        Hctrl.imgtype = '.jpeg';
        Hctrl.uploadChildImage();
        list<Attachment> listAttc= [ select id,parentid from attachment where name='ChildImage' limit 1];
        Hctrl.deleteAttachId = listAttc[0].id;
        Hctrl.deleteChildAttachment();
        Hctrl.childID = listChild[0].id;
        Hctrl.deleteChild();

        RegisteredUserController RUC = new RegisteredUserController();
        RUC.init();
        Hctrl.logout();
        SIC.username = perAdmin.reddit_username__c;
        SIC.password = perAdmin.passwordT__c;
        SIC.login();       
        Hctrl.initForHomePage();
        perRec.Registration_Status__c  = 'Awaiting Review';
        update perRec;
        ApexPages.currentPage().getParameters().put('rid',perRec.id);
        Hctrl.initForReceiverVerification();
        Hctrl.initForGiftsGiven();
        Hctrl.rejectTheReceiver();
        
        perRec.Registration_Status__c  = 'Awaiting Review';
        update perRec;
        ApexPages.currentPage().getParameters().put('rid',perRec.id);
        Hctrl.initForReceiverVerification();
        Hctrl.verifyTheReceiver();
        //Hctrl.nextUnverRec();
        //Hctrl.prevUnverRec();
        RUC = new RegisteredUserController();
        RUC.init();
        RUC.first();
        RUC.next();
        RUC.prev();
        RUC.last();
        
        ApexPages.currentPage().getParameters().put('aid',perAdmin.id);
        Hctrl.initForResendPassword();
        Hctrl.oldPassword = '123456788';
        Hctrl.newPassword = '12345';
        Hctrl.confirmPassword = '123456';
        Hctrl.changePasswordFromPage();
        Hctrl.oldPassword = '1234567889';
        Hctrl.newPassword = '123456788';
        Hctrl.confirmPassword = '123456788';
        Hctrl.changePasswordFromPage();
        /*HomeController--------End here-------*/
        Hctrl.logout();
        
        AssignGiftCtrl agctrl = new AssignGiftCtrl();
        agctrl.initForAssignGiftCtrl();
        agctrl.receiverRedditName = 'testRecRed';
        agctrl.findReceiver();
        agctrl.selectedReceiver =  perRec.id;
        listChild = [ select id,name,age__c from person__c where name='vishChild1' limit 1];
        agctrl.findChildrens();
        list<string> lstSelChild = new list<String>();
        lstSelChild.add(listChild [0].id);
        agctrl.selectedChilds = lstSelChild;
        
        agctrl.newGift.Giver_Reddit_Username__c ='testgiver';
        agctrl.newGift.Name='testg';
        agctrl.newGift.Gift_Value__c=200;
        agctrl.newGift.Expected_Delivery__c=date.today()+5;
        agctrl.sendGift();
        
        agctrl.newGift.Giver_Reddit_Username__c ='';
        agctrl.newGift.Name='';
        agctrl.newGift.Gift_Value__c = 0;
        agctrl.newGift.Expected_Delivery__c=date.today()-2;
        agctrl.sendGift();
        agctrl.newGift.Gift_Value__c = null;
        agctrl.newGift.Expected_Delivery__c=null;
        agctrl.sendGift();
        
        SIC.username = 'testRecRed';
        SIC.password = '12345678';
        SIC.login();
        Hctrl.initForRegisterReceivedGift();
        list <Gift__c> lstgift = [ select id from Gift__c limit 1];
        Hctrl.giftReceivedId = lstgift[0].id ;
        Hctrl.giftReceived();
        
        contact con = new contact(lastname='RAOC Admin');
        insert con;
        
        gift__c g = new gift__c();
        g.Giver_Reddit_Username__c ='testgiver1';
        g.Name='testg';
        g.Gift_Value__c=200;
        g.ip_address__c='1';
        g.Expected_Delivery__c=date.today()+5;
        insert g;
        Suspicious_IP_Address__c sus = new Suspicious_IP_Address__c();
        sus.Gift__c = g.id;
        sus.Reason__c = 'test';
        insert sus;
        delete sus;
        g = new gift__c();
        g.Giver_Reddit_Username__c ='testgiver';
        g.Name='testg';
        g.Gift_Value__c=200;
        g.ip_address__c='1';
        g.Expected_Delivery__c=date.today()+5;
        insert g;
        //Hctrl.nextUnverRec();
        //Hctrl.prevUnverRec();
    }    
}