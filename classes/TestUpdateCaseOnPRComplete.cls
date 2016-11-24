public class TestUpdateCaseOnPRComplete {


	@isTest
	public static void updateCaseTest() {
		RecordType rt = [select id from recordType where sObjectType = 'Case' and name = 'Requirement' limit 1];
		Case c = new Case();
		c.recordTypeid = rt.id;
		c.origin = 'Phone';
		c.status = 'New';
		insert c;
		
		Project_Request__c pr = new Project_Request__c();
		pr.case__c = c.id;
		pr.actual_hours__c = 12.0;
		pr.status__c = 'Closed';
		insert pr;
		
		c = [select id, actual_hours__c from case where id = :c.id]; 
		
		System.assertEquals(pr.actual_hours__c, c.actual_hours__c, 'Case and PR do not have the same hours');
	}
}