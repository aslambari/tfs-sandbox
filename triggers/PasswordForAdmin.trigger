trigger PasswordForAdmin on Person__c (after insert ) { 
    Set<id> setofid = new set<id>();
    List<RecordType> recType = [Select id From RecordType Where DeveloperName = 'Admin'];
    for( Person__c  per : trigger.new ) {
        if( per.RecordTypeId == recType.get(0).Id ){
            setofid .add(per.id);
        }
    } 
    if(setofid .size() > 0){
        RAOCUtill.setPassword(setofid );
    }
}