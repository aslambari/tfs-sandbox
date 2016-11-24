public class RAOCUtill{
    
    @future(callout=true)
    public static void setPassword(Set<Id>personIds){
        list<Person__c> updtlist = new list<Person__c>();
        for( Person__c per : [ select id,passwordT__c from person__c where id in : personIds] ){
            Long timestamp = datetime.now().getTime();
            string password = timestamp/1000 +''; 
            per.PasswordT__c = password ;
            updtlist.add(per);
        } 
        System.debug('------'+updtlist);
        if( updtlist.size() > 0 ){
            update updtlist;
        }
    }
}