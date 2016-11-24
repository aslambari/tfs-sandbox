/*
            Name            :    HomeController
            Author          :    
            Date            :    
            Description     :    This class id used on Header.component,Homepage.page,InfoEdit.page
*/
public class HomeController{
    public string username{get;set;}
    public list<person__c> listPerson {get;set;}
    public list<childModel> childList {get;set;}
    public boolean personEditMode {get;set;}
    public String childID {get;set;}
    public String chUpdateString {get;set;}
    String errMsg = '';
    public boolean errorStatus {get;set;}
    public blob imgbody{get;set;}
    public String imgtype{get;set;}
    public String recordtype{get;set;}
    public String aid {get;set;}
    public integer totalImages {get;set;}
    public string childWhoGotGift {get;set;}
    public list<childModelP> childList_P {get;set;}
    public Gift__c objgift {get;set;}
    public String userid{get;set;}
    public String imgname{get;set;}
    public list<GiftGived> listGiftGived {get;set;}
    public boolean providerEditMode {get;set;}
    public String rejectionReason {get;set;}
    public list<person__c> listOfUnVerReceiver {get;set;}
    public integer offsetVar {get;set;}
    public integer listSizeUnRec {get;set;}
    public list<Gift__c> listGift {get;set;}
    public integer receiverAttchCount {get;set;}
    public boolean submitForReviewShow {get;set;}
    public list<attachment> listAtt {get;set;}
    public String deleteAttachId {get;set;}
    public String giftReceivedId {get;set;}
    public list<Gift_Reported__c> listOfGiftRept{get;set;}
    public list<gift__c> listOfGifts {get;set;}
    public string oldPassword {get;set;}
    public string newPassword {get;set;}
    public string confirmPassword {get;set;}
    public string errorMsg{get;set;}
    public boolean passwordChanged{get;set;}

    //Constructor
    public HomeController(){    
        if( CookieHelperController.fetchCookieValue() != null && CookieHelperController.fetchCookieValue().length() != 0 ){
            listPerson = [ select Notes_to_the_Moderators__c,Registration_Status__c,name,reddit_username__c,email__c,phone__c,recordtype.name from person__c where id =: CookieHelperController.fetchCookieValue()];
            if(listPerson.size() > 0){
                username = listPerson[0].name;  
                userid = listPerson[0].id;
                recordtype=listPerson[0].recordtype.name;
                CookieHelperController.makeCookie(listPerson[0].id);
            }
        }
        
    }

    /*---Start-----------HomePage---------------*/
    //Init for Homaepage ( HomePage )
    public pagereference initForHomePage(){
        

        receiverAttchCount = 0 ;
        offsetVar = 0;
        submitForReviewShow = false;
        if( CookieHelperController.fetchCookieValue() != null ){
            listPerson = [ select Notes_to_the_Moderators__c,Rejection_Reason__c,Registration_Status__c,name,reddit_username__c,email__c,phone__c from person__c where id =: CookieHelperController.fetchCookieValue()];
            if(listPerson.size() > 0){
                if( recordtype == 'Receiver' ){
                    username = listPerson[0].name;
                    CookieHelperController.makeCookie(listPerson[0].id);
                    childList = new list<childModel>();
                    integer i=1;
                    for(person__c per : [ select Wishlist_URL__c,Id,name,age__c,receiver__r.name from person__c where receiver__c =: listPerson[0].id order by name]){
                        childModel cm = new childModel();
                        cm.childObj = per ;
                        cm.index = i ;
                        cm.editMode =false;                    
                        childList.add(cm);
                        i++;
                    }   
                    listSizeUnRec = childList.size();
                    listAtt = [ select id from attachment where parentid =: listPerson[0].id ] ;
                    totalImages = listAtt .size();
                    receiverAttchCount = listAtt.size();
                    if( receiverAttchCount > 0 && listSizeUnRec > 0 && ( listPerson[0].Registration_Status__c == 'Registration in Progress' || listPerson[0].Registration_Status__c == 'Action Required' ) ){
                        submitForReviewShow = true ;
                    }
                }
                else if( recordtype == 'Admin' ){
                    fetchUnverReceivers();
                }
            }
        }
        return null;  
    }
    
    //Fetch UnVerified Receivers ( HomePage )
    private void fetchUnverReceivers(){
        username = listPerson[0].name;
        CookieHelperController.makeCookie(listPerson[0].id); 
        String query = ' select reddit_username__c,recordtype.name,email__c,name,id from person__c where recordtype.name = \'Receiver\' and Registration_Status__c = \'Awaiting Review\' LIMIT 10 OFFSET '+offsetVar;
        listOfUnVerReceiver = Database.Query(query);
        listSizeUnRec = [select id from person__c where recordtype.name = 'Receiver' and Registration_Status__c = 'Awaiting Review' ].size();
    }
    
    //Next ( HomePage )
    public void nextUnverRec(){
        offsetVar += 10;
        fetchUnverReceivers();
    }
    
    //Prev ( HomePage )
    public void prevUnverRec(){
        offsetVar -= 10;
        fetchUnverReceivers();
    }
    /*---End-----------HomePage---------------*/
     
   /*---Start-----------InfoEdit---------------*/
    //Init for editInfo page ( InfoEdit )
    public pagereference initForEditInformation(){
        personEditMode = false;
        errorStatus = true;
        if( CookieHelperController.fetchCookieValue() != null ){
            listPerson = [ select Notes_to_the_Moderators__c,recordtype.name,name,reddit_username__c,email__c,phone__c from person__c where id =: CookieHelperController.fetchCookieValue()];
            if( listPerson[0].recordtype.name == 'Receiver' ){
                if(listPerson.size() > 0){
                    initForHomePage();
                    username = listPerson[0].name;  
                    CookieHelperController.makeCookie(listPerson[0].id);
                    return null;
                }
            }
        }
        return page.loginpage;
    }
    
    //Functionality of submt for review ( InfoEdit )
    public void submitForReview(){
        listPerson[0].Registration_Status__c = 'Awaiting Review' ;
        listPerson[0].Rejection_Reason__c='';
        update listPerson;
        submitForReviewShow = false;
    }
    
    //Update receiver information ( InfoEdit )
    public pagereference savePersonInfo(){
        if(validateForm()){
            personEditMode = false;
            try{
                update listPerson;  
            }catch(Exception e){}
            
        }
        else{
            errorStatus = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errMsg));
            return null;
        }
        initForHomePage();
        return page.InfoEdit;
    }
    
    //Edit mode switching ( InfoEdit )
    public void goToEditMode(){
        personEditMode = true;
    }
    
    //Person edit mode cancelation ( InfoEdit )
    public void cancelMode(){
        personEditMode = false;
        initForHomePage();
    }
    
    //Delete child record ( InfoEdit )
    public void deleteChild(){
        list<person__c> childToDel = [ select id,name,Receiver__c,Receiver__r.name from person__c where id =: childID];
        if(childToDel.size() > 0){
            String parentId = childToDel[0].Receiver__c;
            String attname = childToDel[0].Receiver__r.name+''+childToDel[0].Id;
            List<Attachment> attlst = [Select id from Attachment where parentId =: parentId AND Name =: attname];            
            try{
                delete childToDel[0];
                if(attlst.size()>0)
                    delete attlst;
            }
            catch(Exception e){}
        }
        initForHomePage();
    }
    
    //Update and Insert Child Information ( InfoEdit )
    public void updateChild(){
        String chId = ApexPages.currentPage().getParameters().get('chId');
        String chName = ApexPages.currentPage().getParameters().get('chName');
        String chAge = ApexPages.currentPage().getParameters().get('chAge');
        String chwishlisturl = ApexPages.currentPage().getParameters().get('chwishlisturl');
        if(chId != null && chId.length()>1){
            Person__c pUpdt = [ select id,name,age__c, Wishlist_URL__c from person__c where id =: chId];
            pUpdt.name = chName;
            pUpdt.age__c = Decimal.valueOf(chAge);
            pUpdt.Wishlist_URL__c = chwishlisturl ;
            try{
                update pUpdt;             
            }catch(Exception e){}
        }else if((chId == null || chId == '') && chName != '' && chAge != '' ){
            list<recordtype> listrecType = [select id,name from recordtype where name = 'Child'];
            if(listrecType.size() > 0 ){
                Person__c pInst = new person__c();
                pInst.name = chName;
                pInst.age__c = Decimal.valueOf(chAge); 
                pInst.receiver__c = listPerson[0].id;
                pInst.RecordTypeId = listrecType[0].id;
                pInst.Wishlist_URL__c = chwishlisturl ;
                try{
                    insert pInst;
                }catch(Exception e){}
            }
        }       
        initForHomePage();
    }
    
    //Upload Attachment ( InfoEdit )
    public pagereference uploadChildImage(){
        if(imgbody != null && imgtype != null){
            Attachment att = new Attachment(name = 'ChildImage',parentid = listPerson[0].id, body = imgbody,contenttype = imgtype);
            insert att;
            imgbody = null;
            imgtype = '';
        }
        return new pagereference('/infoedit');
    } 
    
    public pagereference deleteChildAttachment(){
        list<Attachment> listAtc = [ select id from attachment where id =: deleteAttachId limit 1];
        if( listAtc.size() > 0 ){
            try{
                delete listAtc;
            }catch(Exception e){}
        }
        return new pagereference('/infoedit');
    }
    
    /*---End-----------InfoEdit---------------*/ 
    
    /*---Start-----------Header Component---------------*/
    //Logout Functionality ( Header Component )
    public pagereference logout(){
         CookieHelperController.deleteCookie();
         pagereference pg = new pagereference('/homepage');
         pg.setRedirect(true);
         return pg;
    }
    /*---End-----------Header Component---------------*/
    
    /*---Start-----------Receiver Verification---------------*/
    //Init for editInfo ReceiverVerification ( Receiver Verification )
    public pagereference initForReceiverVerification(){
        pagereference pg ;
        
        if( CookieHelperController.fetchCookieValue() != null ){
            String recId = ApexPages.currentPage().getParameters().get('rid');
            listPerson = [ select Notes_to_the_Moderators__c,name,reddit_username__c,email__c,phone__c,Registration_Status__c from person__c where Registration_Status__c = 'Awaiting Review' and id =: recId and recordtype.name='Receiver' limit 1 ];
            if( listPerson .size() == 0 ){
                pg = new pagereference('/homepage');
                pg.setRedirect(true);
                return pg;
            }
            childList_P=new list<childModelP>();           
            integer i=1;
            listAtt = [ select id from attachment where parentid =: listPerson[0].id ] ;
            totalImages = listAtt .size();
            for(person__c per : [ select Wishlist_URL__c,name,age__c,receiver__r.name,receiver__c from  person__c where  recordtype.name='child' and receiver__c =: listPerson[0].id  ]){
                childModelP cm = new childModelP();
                cm.childObj = per ;
                cm.index = i ;
                cm.editMode =false;
                childList_P.add(cm);
                i++;
            } 
            return null;    
        }     
        pg = new pagereference('/loginpage');
        pg.setRedirect(true);
        return pg;
    }
    
    //Functionality of verify the receiver  ( Receiver Verification )
    public pagereference verifyTheReceiver(){
        listPerson[0].Registration_Status__c = 'Approved' ;
        listPerson[0].Date_Of_Approval__c = date.today(); 
        try{
            update listPerson;
        }catch(Exception e){}
        pagereference pg = new pagereference('/homepage');
        pg.setRedirect(true);
        return pg;
    }
    
    //Functionality of rejection ( Receiver Verification )
    public pagereference rejectTheReceiver(){
        listPerson[0].Registration_Status__c = 'Action Required' ;
        listPerson[0].Rejection_Reason__c = rejectionReason ;
        try{
            update listPerson;
        }catch(Exception e){}
        pagereference pg = new pagereference('/homepage');
        pg.setRedirect(true);
        return pg;
    }
    /*---End-----------Receiver Verification---------------*/
     
    /*---Start----------Register Received Gift---------------*/
    //Init for RegisterReceivedGift ( Register Received Gift )
    public pagereference initForRegisterReceivedGift(){
        pagereference pg ;

        if( CookieHelperController.fetchCookieValue() != null ){
            listPerson = [ select id from person__c where id =: CookieHelperController.fetchCookieValue() and recordtype.name='Receiver' limit 1 ];
            if( listPerson.size() > 0 ){
                listGift = [ select Expected_Delivery__c,id,Gift_Value__c, Status__c,name from gift__c where Receiver__c =: listPerson[0].id order by Expected_Delivery__c];
                return null;
            }     
        }
        pg = new pagereference('/loginpage');
        pg.setRedirect(true);
        return pg;
    }
    
    //Functionality of gift received( Register Received Gift )
    public pagereference giftReceived(){
        Gift__c receivedGift = new Gift__c(Id = (Id)giftReceivedId);
        receivedGift.Status__c = 'Received';
        update receivedGift;
        
        initForRegisterReceivedGift();
        pagereference pg = new pagereference('/receivedgift');
        pg.setRedirect(true);
        return pg;
    }
    /*---End----------Register Received Gift---------------*/
    
    /*---Start----------ResendPassword ---------------*/
    //Init for ResendPassword( ResendPassword )
    public pagereference initForResendPassword(){
        oldPassword ='';
        newPassword='';
        confirmPassword ='';
        aid = ApexPages.currentPage().getParameters().get('aid');
        if( aid != null ){
            listPerson  = [ select id,email__c,PasswordT__c,recordtype.name from person__c where recordtype.name='Admin' and id =: aid limit 1] ;
            if( listPerson .size() > 0 ){
                 return null;
            }
        }
        return new pagereference('/');
    }
    
    
    //Resend password ( ResendPassword )
    public void changePasswordFromPage(){
        passwordChanged =false;
        errorMsg='';
        if( listPerson[0].PasswordT__c != oldPassword ){
            errorMsg+='Old passowrd is not correct.</br>';
        }
        if( newPassword.trim().length() < 8 ){
            errorMsg+='Password shoud be 8 character long.</br>';
        }
        if( newPassword != confirmPassword && newPassword.trim().length()  >= 8 && confirmPassword.trim().length()  >= 8){
            errorMsg+='Password and Confirm Password did not matched.';
        }
        if( errorMsg.trim().length() == 0 ){
            listPerson[0].PasswordT__c = newPassword ;
            try{
            update listPerson;
            }catch(exception e){}
            passwordChanged = true;
        }
    }
    /*---End-----------ResendPassword ---------------*/
    
    /*---Start----------Gifts_Given ---------------*/
    public pagereference initForGiftsGiven(){
        pagereference pg ;

        if( CookieHelperController.fetchCookieValue() != null ){
            listPerson = [ select id,recordtype.name from person__c where id =: CookieHelperController.fetchCookieValue() and recordtype.name='Admin' limit 1 ];
            if( listPerson.size() > 0){
                listOfGifts = [ select createddate,Giver_Reddit_Username__c, Receiver__r.name,Name, Gift_Value__c, Status__c from gift__c];
                return null;
            }     
        }
        pg = new pagereference('/loginpage');
        pg.setRedirect(true);
        return pg;
    }
    /*---End----------Gifts_Given ---------------*/ 
       
    //Check Validation Functionality
    private Boolean validateForm(){
        Boolean flag = true;
        errMsg = ''; 
        if(listPerson[0].Name == null || listPerson[0].Name.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Name.</li>';
            flag = false;
        }
        
        String emailPat = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';

        if(listPerson[0].Email__c == null || listPerson[0].Email__c.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Email.</li>';
            flag = false;
        }
        else if(!Pattern.matches(emailPat, listPerson[0].Email__c)){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Valid Email Address.</li>';
            flag = false;
        }
        
        if(listPerson[0].Phone__c == null || listPerson[0].Phone__c.trim().length()==0){
            errMsg += '<li style="color:#cc0000;list-style: none;">Please Enter Phone.</li>';
            flag = false;
        }
        return flag;
    }
    
    //Modal Class For Child for Givers 
    public class childModelP{
        public person__c childObj {get;set;}
        public integer index {get;set;}
        public boolean editMode {get;set;}
        public String childImage{get;set;}
    }
    
    //Modal Class For Child
    public class childModel{
        public person__c childObj {get;set;}
        public integer index {get;set;}
        public boolean editMode {get;set;}
        public boolean isImagefound{get;set;}
    }
   
    //Modal Class For Gift Gived
    public class GiftGived{
        public gift__c gift {get;set;}
        public integer index {get;set;}
    }
   
}