public class SiteHomeController{
    public List<Expertise__c> expertises {get;set;}
    public SiteHomeController(){
        expertises = [SELECT Name, Tag__c, Details__c, Order__c from Expertise__c ORDER BY Order__c ASC LIMIT 3];
    
    }
    
    public Expertise__c getFirstColumn(){
        return expertises.get(0);
    }
    
    public Expertise__c getMiddleColumn(){
        return expertises.get(1);
    }
    
    public Expertise__c getLastColumn(){
        return expertises.get(2);
    }

}