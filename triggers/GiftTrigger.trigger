trigger GiftTrigger on Gift__c (after insert){
    map<String,String>giftMap = new map<String,String>();
    for(Gift__c gft : Trigger.New){
        if(gft.IP_Address__c != null){
            giftMap.put(gft.Id,gft.IP_Address__c);
        }
    }
    if(giftMap.size()>0){
        Map<String,String>ipUserMap = new Map<String,String>();
        for(Gift__c gft : [Select IP_Address__c, Giver_Reddit_Username__c From Gift__c 
        Where Id Not in: giftMap.keySet() And IP_Address__c in: giftMap.values()]){
            ipUserMap.put(gft.IP_Address__c,gft.Giver_Reddit_Username__c);
        }
        if(ipUserMap.size()>0){
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            String templateId = [Select id From EmailTemplate Where DeveloperName = 'Suspicious_Gift' Limit 1].Id;
            String contactId = [Select id From Contact Where Name = 'RAOC Admin' Limit 1].Id;
            for(Gift__c gft : Trigger.New){                
                if(gft.IP_Address__c != null && ipUserMap.containsKey(gft.IP_Address__c) && 
                ipUserMap.get(gft.IP_Address__c)!= gft.Giver_Reddit_Username__c){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(templateId);                   
                    mail.setTargetObjectId(contactId);
                    mail.setWhatId(gft.Id);
                    mail.setSaveAsActivity(false);
                    mail.setReplyTo('randomactsofxmas@gmail.com');
                    mail.setSenderDisplayName('No-Reply');
                    emails.add(mail);
                }
            }
            if(emails.size()>0){
                if(! (Test.isRunningTest()) ){
                    Messaging.sendEmail(emails);
                }
            }
        }
    }
}