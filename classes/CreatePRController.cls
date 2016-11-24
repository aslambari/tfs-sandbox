public class CreatePRController {
  
  public Case currentCase {get;set;}
  public Project_Request__c projectRequest {get;set;}
  
  public CreatePRController(ApexPages.StandardController controller){
    currentCase = (Case)controller.getRecord();
    currentCase = [select id, subject, description, project__c from case where id = :currentCase.id];
  }

 
  public Pagereference createPR(){
    try{
      List<project_Request__c> prs = [select id from project_request__c where case__c = :currentCase.id ];
      project_Request__c projectRequest = new Project_Request__c();
      if (prs.size() == 0) {
      	 projectRequest.description__c = currentCase.description;
      	 projectRequest.project__c = currentCase.project__c;
      	 projectRequest.status__c = 'New';
      	 projectRequest.name = currentCase.subject;
      	 projectRequest.case__c = currentCase.id;
      	 insert projectRequest;
      } else {
      	 projectRequest = prs.get(0);
      }
      
      ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.INFO ,'PR has been created with is '+ projectRequest.id));
      return new Pagereference('/'+ projectRequest.Id);
    }catch(Exception ex){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()));
    }  
    return null;   
  }
  
  
}