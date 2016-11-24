public with sharing class TotalTimeCardInfoController {
	
	public string accountId;
	public Account thisAccount;
	public double totalTimeCards {get;set;}
	public double totalPayments {get;set;}
	public double totalOwed {get;set;}
	
	public TotalTimeCardInfoController (ApexPages.StandardController stdController) {
		accountID = stdController.getId();
		thisAccount = [select id from Account where id = :accountId limit 1];
		system.debug('accountid is ' + accountID);
		totalTimeCards = 0;
		List<Contact> contacts = [select id, Total_Hours_Worked__c, hourly_rate__c from Contact where accountid = :accountId];
		for (Contact cont : contacts) {
			if (cont.Total_Hours_Worked__c != null && cont.hourly_Rate__c !=null) {
				System.debug('hours/rate is ' + cont.Total_Hours_Worked__c + '/' + cont.hourly_Rate__c);
				totalTimeCards += cont.Total_Hours_Worked__c * cont.hourly_Rate__c;
			}
		}
		totalPayments = 0;
		List<Payment__c> payments = [select id, amount__c, vendor__c from Payment__c where vendor__c = :accountId];
		for (Payment__c pay : payments) {
			totalPayments += pay.amount__c;
		}
		totalOwed = totalTimeCards - totalPayments;
	}
	
	

	
	
}