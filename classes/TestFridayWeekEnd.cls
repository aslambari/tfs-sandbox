public with sharing class TestFridayWeekEnd {

	@isTest
	public static void testFridayWeekEnding () {
		
		Time_card__c tCard = new Time_card__c();
		Date weekEndDate = Date.today().toStartOfWeek();
		tCard.week_Ending__c = weekEndDate;
		try {
			insert tcard;
		} catch (Exception e) {
			System.debug('all is well');
		}
	}
}