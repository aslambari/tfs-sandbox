trigger SuspiciousIPAddressTrigger on Suspicious_IP_Address__c (after insert, before delete) {
    Set<String> ipAddresses = new Set<String>();
    Boolean isSuspicious = false;
    if(Trigger.IsInsert){
        for(Suspicious_IP_Address__c ipAdd : Trigger.New){
            ipAddresses.add(ipAdd.Name);
        }
        isSuspicious = true;
    }
    else if(Trigger.IsDelete){
        for(Suspicious_IP_Address__c ipAdd : Trigger.Old){
            ipAddresses.add(ipAdd.Name);
        }
    }
    
    if(ipAddresses.size()>0){
        List<Gift__c> giftList = [Select id,Suspicious__c from Gift__c where IP_Address__c in: ipAddresses];
        for(Gift__c gft : giftList){
            gft.Suspicious__c = isSuspicious;
        }
        
        update giftList;
    }
}