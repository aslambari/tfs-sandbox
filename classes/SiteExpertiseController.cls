public class SiteExpertiseController{
    public List<Expertise__c> allExpertise{get;set;}
    public Expertise__c selectedExpertise{get;set;}
    public string details {get;set;}
    public string selectedId {get;set;}
    public SiteExpertiseController(){
        selectedId = ApexPages.currentPage().getParameters().get('id');
        allExpertise = [SELECT Id, Name, Tag__c, Details__c, Order__c from Expertise__c ORDER BY Order__c ASC];
        for(Expertise__c exp: allExpertise){
            if(selectedId == exp.Id){
                selectedExpertise = exp;
                details = selectedExpertise.Details__c;
                details = details.replaceAll('\n','<br/>');
                break;
            }
        }
        if(selectedExpertise == null){
            selectedExpertise = allExpertise.get(0);
            details = selectedExpertise.Details__c;
            details = details.replaceAll('\n','<br/>');
            selectedId = selectedExpertise.Id;
        }
    }
}