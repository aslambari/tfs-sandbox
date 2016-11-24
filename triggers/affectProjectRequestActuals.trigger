trigger affectProjectRequestActuals on Time_Card__c (after delete, after insert, after update) {

	PrToHoursAdjust theMap = new PrToHoursAdjust(); 
	
	if(Trigger.isUpdate){ 	
		for (Integer i = 0;i<Trigger.old.size();i++){ 
			Time_Card__c oldTC = Trigger.old[i]; 
			Time_Card__c newTC = Trigger.new[i]; 
			theMap.addHours(newTC.project_request__c, newTC.hours__c);
			theMap.subtractHours(oldTC.project_request__c, oldTC.hours__c);
		} 
	} else if (Trigger.isInsert) {
		for (Integer i = 0;i<Trigger.new.size();i++){ 
			Time_Card__c newTC = Trigger.new[i]; 
			theMap.addHours(newTC.project_request__c, newTC.hours__c);
		}
	} else if (Trigger.isDelete) {
		for (Integer i = 0;i<Trigger.old.size();i++){ 
			Time_Card__c oldTC = Trigger.old[i]; 
			theMap.subtractHours(oldTC.project_request__c, oldTC.hours__c);
		}
	} else if (Trigger.isUndelete) {
		for (Integer i = 0;i<Trigger.new.size();i++){ 
			Time_Card__c newTC = Trigger.new[i]; 
			theMap.addHours(newTC.project_request__c, newTC.hours__c);
		}
	}
	Map<id, double> result = theMap.getMap();
	Set<id> projectIds = result.keySet();
	Map<id, Project_request__c> updateMap = new Map<id, Project_request__c> ([select id, actual_hours__c from project_request__c where id in :projectIds]);
	
	for (Id projectId : projectIds) {
		double hours = result.get(projectId);
		Project_request__c pr = updateMap.get(projectId);
		System.debug('***** pr is ' + pr + ' and hours is ' + hours);
		if (pr.actual_hours__c == null)
			pr.actual_hours__c = hours;
		else 
			pr.actual_hours__c = pr.actual_hours__c + hours;
	}
	update updateMap.values();
	
}