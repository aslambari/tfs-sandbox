public with sharing class TimeCardEntryController {
    
    public List<Time_card__c> timecards {get;set;}
    public Time_card__c newTimeCard {get;set;}
    public Time_card__c tempTimeCard;
    public boolean haveTimecards {get;set;}
    

    public TimeCardEntryController(ApexPages.StandardController stdController) {
        newTimeCard = new Time_Card__c();
        timeCards = new List<Time_Card__c>();
        newTimeCard.Week_Ending__c = Date.today().toStartOfWeek().addDays(5);
        
        Contact dev = [select id, firstname, name from contact where firstName='aslam' ];
        newTimeCard.Developer__c = dev.id;
        haveTimecards = false;
        
        setTimeCardsList();
    }
    
    public PageReference retrieveTimeCards() {
         
        if (newTimeCard.developer__c == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter the Developer who you are entering timecards for');
            ApexPages.addMessage(msg);      
        } else 
            setTimeCardsList(); 
        haveTimecards = timeCards.size() > 0;

        return null;
    }
    
    
    
    public void setTimeCardsList() {
        newTimeCard.week_ending__c = newTimeCard.week_ending__c.toStartOfWeek().addDays(5);
        timeCards = [select id, Name, hours__c, week_ending__c, developer__c, developer__r.name,
                    day__c, Project_request__c, project_request__r.name, comments__c
                    from time_card__c where week_ending__c = :newTimeCard.week_ending__c and developer__c = :newTimeCard.developer__c
                    order by day__c asc];                        
    }
    
    public PageReference addTimeCard() {
        try {
        
            insert newTimeCard;
            
            setTimeCardsList();
            newTimeCard.hours__c = null;
            newTimeCard.id = null;
            newTimeCard.comments__c = null;
                        
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;
    }
    
    public PageReference saveTimeCards() {
        try {
            update timeCards;
                
            setTimeCardsList();
            haveTimecards = timeCards.size() > 0;       
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;
    }
    
    
}