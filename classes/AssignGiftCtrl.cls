public class AssignGiftCtrl{
    public Gift__c newGift{get;set;}
    public String receiverRedditName{get;set;}
    public List<String> selectedChilds{get;set;}
    public List<Selectoption> childOptions{get;set;}
    public List<Selectoption> receiverOptions{get;set;}
    public Attachment newAttach{get;set;}
    public String errorMsg{get;set;}
    public boolean thanks {get;set;} 
    private String receiverId;
    private String giverId;
    private Person__c receiver = new Person__c();
    public string selectedReceiver {get;set;}
    
    public AssignGiftCtrl(){        
        receiverId = null;
        receiverRedditName ='';
        errorMsg = '';
        selectedChilds = new List<String>();
        receiverOptions = new List<SelectOption>();
        childOptions = new List<SelectOption>();
        newAttach = new Attachment();
        newGift = new Gift__c();
    }
    
    //Init for Gift_Given page
    public PageReference initForAssignGiftCtrl(){
        if( CookieHelperController.fetchCookieValue() != null && CookieHelperController.fetchCookieValue().length() != 0 ){
            List<Person__c> tempList = [Select Id, recordtype.name From Person__c Where id =: CookieHelperController.fetchCookieValue() limit 1];
            if ( tempList.size() > 0 ){
                if (tempList[0].recordtype.name == 'Admin' ){
                    return page.homepage;
                }
            }
        } 
        String hostVal = ApexPages.currentPage().getHeaders().get('Host');
        String urlVal = Apexpages.currentPage().getUrl();
        if(test.isRunningTest()){
            urlVal='/apex/loginpage';
        }
        if( hostVal == 'tfs-tfs.cs22.force.com' || test.isRunningTest() ){
            String reDirectURL = 'http://tfs.force.com/raoc'+urlVal.substring(5,urlVal.length());
            pagereference pg = new pagereference(reDirectURL);
            pg.setredirect(true);
            return pg;
        }
        return null;
    }
    
    //Find Receivers
    public void findReceiver(){
        receiverOptions.clear();
        childOptions = new List<SelectOption>();
        if(receiverRedditName .trim().length() > 0 ){            
            List<Person__c> tempList = [Select Id, Name,Reddit_Username__c From Person__c Where RecordType.Name = 'Receiver' and Redit_Username_Normal__c like : '%'+ receiverRedditName + '%' and Registration_Status__c in('Approved','Registration in Progress') ];
            if( tempList.size() > 0 ){
                for(person__c rec : tempList ){
                    receiverOptions.add(new selectoption(rec.id,rec.Reddit_Username__c));
                }
                selectedReceiver = tempList[0].id;
                receiverId =  tempList[0].id;
                findChildrens();
            }
        }
    }
    
    //Find childerns of giving receiver reddit username
    public void findChildrens(){
        receiverId = selectedReceiver ;
        List<Person__c> tempList = [ Select Id,Name From Person__c Where RecordType.Name = 'Child' and Receiver__c =: receiverId  ];
        childOptions = new List<SelectOption>();
        selectedChilds = new List<String>();
        if( tempList.size()>0 ){
            for(Person__c child : tempList ){
                childOptions.add(new SelectOption((String)child.Id,child.Name));
            }
        }
    }
    
    //Functionality of send gifts to receiver
    public void sendGift(){ 
        thanks = false;   
        if( validate() ){
            try{
                newGift.IP_Address__c = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP') ;
                newGift.Receiver__c = receiverId;
                newGift.Status__c = 'Reported as Purchased';
                newGift.Name = newGift.Name.length() > 80 ? newGift.Name.subString(0,79) : newGift.Name;
                insert newGift;      
                       
                if(newAttach.Body != null){
                    newAttach.ParentId = newGift.Id;
                    insert newAttach;
                    newAttach = new Attachment();
                }
            }catch(Exception exp){}
            
            decimal valuePerChild = newGift.Gift_Value__c / selectedChilds .size();
            List<Gift_Reported__c> newGiftsReported = new List<Gift_Reported__c>();
            for(String childId : selectedChilds){
                Gift_Reported__c gr = new Gift_Reported__c();
                gr.Gift__c = newGift.Id;
                gr.Gift_Value__c = valuePerChild;
                gr.Child__c = childId;
                newGiftsReported.add(gr);
            }
            if(newGiftsReported.size()>0){
                try{
                    insert newGiftsReported;
                }catch(Exception exp){}
            }
            thanks = true ;
            receiverId = null;
            receiverRedditName ='';
            errorMsg = '';
            selectedChilds = new List<String>();
            childOptions = new List<SelectOption>();
            receiverOptions = new List<SelectOption>();
            newAttach = new Attachment();
            newGift = new Gift__c();   
        }
    }
    
    //Check validation
    private boolean validate(){
        errorMsg ='';   
        system.debug('### Username :'+newGift.Giver_Reddit_Username__c);
        if (newGift.Giver_Reddit_Username__c == null || newGift.Giver_Reddit_Username__c.trim().length()==0){
            errorMsg += '&#8226; Please enter Reddit Username <br/>';
        }
        if ( newGift.Name == null || newGift.Name.trim().length()==0){
            errorMsg += '&#8226; Please enter Gift Name <br/>';
        }
        if ( newGift.Gift_Value__c  == null){
            errorMsg += '&#8226; Please enter Gift Value <br/>';
        }
        if (newGift.Gift_Value__c  <= 0){
            errorMsg += '&#8226; Gift Value shoud be greater then zero <br/>';
        }
        if ( newGift.Expected_Delivery__c  != null && newGift.Expected_Delivery__c < System.Today() ){
            errorMsg += '&#8226; You cannot enter past date. <br/>';
        }
        if ( selectedChilds .size() == 0 ){
            errorMsg += '&#8226; Please select at least one child from child list';
        }
        
        if(errorMsg.trim().length() > 0 ){
            return false;
        }
        return true;
    }
}