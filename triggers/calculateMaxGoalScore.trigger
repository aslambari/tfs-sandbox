trigger calculateMaxGoalScore on CCA2_Goal_Score__c (after delete, after insert, after undelete, 
after update) {


	//Get the goals associated with these goalScore records
	Set<Id> goals = new Set<Id>();
	if (trigger.new != null) {	
		for (CCA2_Goal_Score__c gs : trigger.new) {
			goals.add (gs.CCA2_Goals__c);
		}
	}
	if (trigger.old != null) {
		for (CCA2_Goal_Score__c gs : trigger.old) { 
			goals.add (gs.CCA2_Goals__c);
		}
	}
	
	//Get all the GoalScores for the Goals associated with these GoalScore records
	List<CCA2_Goal_Score__c> allGSs = [select Answer__c, Answer__r.Question__c, CCA2_Goals__c, Score__c from CCA2_Goal_Score__c where CCA2_Goals__c IN :goals];
	
	//create a map of Goal -> (Question -> MaxScore)
	Map<Id, Map<id,Integer>> goalToQuestionToMaxScore = new Map<Id, Map<id,Integer>>();
	
	for (CCA2_Goal_Score__c gs : allGSs) {
		if (goalToQuestionToMaxScore.get(gs.CCA2_Goals__c) == null)
			goalToQuestionToMaxScore.put(gs.CCA2_Goals__c, new Map<id,Integer>());
		Map<Id, Integer> questionToMaxScore = goalToQuestionToMaxScore.get(gs.CCA2_Goals__c);
		
		if (questionToMaxScore.get(gs.Answer__r.Question__c) == null)
			questionToMaxScore.put(gs.Answer__r.Question__c, 0);
			
		if (gs.Score__c > questionToMaxScore.get(gs.Answer__r.Question__c))	
			questionToMaxScore.put(gs.Answer__r.Question__c, (Integer)gs.Score__c);	
	}
	Map<id, Integer> goalToMaxScore = new Map<id, Integer>();
	for (Id goal : goalToQuestionToMaxScore.keySet()) {
		Integer maxScoreForGoal = 0;
		Map<Id, Integer> questionToMaxScore = goalToQuestionToMaxScore.get(goal);
		for (Id question : questionToMaxScore.keySet()) {
			maxScoreForGoal += questionToMaxScore.get(question);
		}
		goalToMaxScore.put(goal, maxScoreForGoal);
	}
	
	//Update the goals with the new Maximum score for that goal
	List<CCA2_Goal__c> goalsToUpdate = [select id, Max_Goal_Score__c from CCA2_Goal__c where id IN :goalToMaxScore.keySet()];
	for (CCA2_Goal__c currGoal : goalsToUpdate) {
		currGoal.Max_Goal_Score__c = goalToMaxScore.get(currGoal.id);
	}
	update goalsToUpdate;
	
}