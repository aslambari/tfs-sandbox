public class SiteContactHandler{
    public Lead newLead {get;set;}
    public boolean leadSaved {get;set;}
    public SiteContactHandler(){
        newLead = new Lead();
        newLead.Company = 'The Force Solution';
    }
    
    public PageReference saveLead(){
        upsert newLead;
        leadSaved = true;
        return null;
    }
}