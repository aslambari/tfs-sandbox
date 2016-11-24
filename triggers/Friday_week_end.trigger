trigger Friday_week_end on Time_Card__c (before insert, before update) {
    for (Time_card__c card: Trigger.New) {
        Card.week_Ending__c = card.day__c.toStartOfWeek().addDays(5);
        Card.month_ending__c = card.day__c.toStartOfMonth();
        Card.month_ending__c = card.month_ending__c.addMonths(1);
        Card.month_ending__c = card.month_ending__c.addDays(-1);
    } 
}