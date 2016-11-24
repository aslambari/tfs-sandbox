public with sharing class prToHoursAdjust {

	public Map<id, double> prToHours = new Map<id, double> ();
	
	public void addHours(Id projectReqId, Double hours) {
		if (prToHours.get(projectReqId) == null) {
			prToHours.put(projectReqId, hours);
		} else {
			prToHours.put(projectReqId, prToHours.get(projectReqId) + hours);
		}
	}
	
	public void subtractHours(Id projectReqId, Double hours) {
		if (prToHours.get(projectReqId) == null) {
			prToHours.put(projectReqId, -hours);
		} else {
			prToHours.put(projectReqId, prToHours.get(projectReqId) - hours);
		}
	}
	
	public Map<id, double> getMap() {
		return prToHours;
	}

}