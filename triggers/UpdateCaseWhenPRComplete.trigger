trigger UpdateCaseWhenPRComplete on Project_Request__c (after insert, after update) {
	
	Map<id, double> casesToUpdate = new Map<Id, double>();
	
	
	for (Project_Request__c pr: Trigger.NEW) {
		if (pr.case__c != null && pr.status__c == 'Closed') {
			casesToUpdate.put(pr.case__c, pr.actual_hours__c);
		}
	}
	List<Case> cases = [select id, actual_hours__c, status from case where id in :casesToUpdate.keySet()];
	system.debug('**** ' + cases.size());
	for (Case currCase : cases) {
		currCase.actual_hours__c = casesToUpdate.get(currCase.id);
		currCase.status = 'Work Complete';

	}
	update cases;
}