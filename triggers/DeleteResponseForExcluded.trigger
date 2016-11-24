/*
        Name        : DeleteResponseForExcluded
        Author      : iBirds
        Date        : 21 Jan, 2015
        Description : Trigger for delete all Response that have no Aapplication Goal Score.
*/

trigger DeleteResponseForExcluded on CCA2_Application_Goal_Score__c (after delete) {
    set<string> responseIds = new set<string>();
    
    for(CCA2_Application_Goal_Score__c oldAGS : Trigger.old){
        responseIds.add(oldAGS.CCA2_Response__c);
    }
    
    System.debug('@@@ ## responseIds==>'+responseIds);
    
    if(responseIds.size()>0){   
        for(CCA2_Application_Goal_Score__c ags : [SELECT Id,CCA2_Response__c FROM CCA2_Application_Goal_Score__c 
                                                    where CCA2_Response__c IN : responseIds]){
            if(responseIds.contains(ags.CCA2_Response__c)) 
                   responseIds.remove(ags.CCA2_Response__c);                                        
        }
        
        System.debug('#### responseIds==>'+responseIds);
        
        if(responseIds.size()>0){
            list<CCA2_Response__c> responseList = [SELECT Id FROM CCA2_Response__c WHERE Id IN: responseIds AND Answer__c = null];
            System.debug('####responseList==>'+responseList);
            if(responseList.size()>0)
                delete responseList;
        }        
    }
}