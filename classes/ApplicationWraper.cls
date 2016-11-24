global class ApplicationWraper implements Comparable {
   
    // Which field should be considered for sorting
    public enum SortField {
        ApplicationName, CreatedDate, Type, Score
    }
  
    // Sorting direction ASCENDING or DESCENDING
    public enum SortDirection {
        ASCENDING, DESCENDING
    }
    
    // default sorting would be ascending
    public static SortDirection SORT_DIR = SortDirection.ASCENDING;
    // default sorting would be on name
    public static SortField SORT_FIELD = SortField.ApplicationName;
  
    Public Boolean unsignedStatus{set;get;}
    Public Boolean status{set;get;}
    Public Boolean already{set;get;}
    public Boolean excluded{get;set;}
    Public Application__c applicationObject{get;set;}
    Public Integer Score {set;get;}
     
    public String ApplicationName;
    public String Type;
    public DateTime CreatedDate;
  
    public ApplicationWraper (boolean stats, boolean alredy, boolean exclud, boolean unsignedStats, integer s, Application__c app) {
        this.status = stats;
        this.already = alredy;
        this.excluded = exclud;
        this.unsignedStatus = unsignedStats;
        this.Score = s;
        this.applicationObject = app;
    
        this.ApplicationName = app.Name!=null ? app.Name : '';
        this.Type = app.Type__c!=null ? app.Type__c : '';
        this.CreatedDate = app.CreatedDate;
    }
  
    /*
    Comparable.compareTo() implementation
    */
    global Integer compareTo(Object other) {
        if (SORT_FIELD == SortField.ApplicationName) {
            return compareToApplicationName(other);
        } else if (SORT_FIELD == SortField.Type) {
            return compareToType(other);
        } else if (SORT_FIELD == SortField.CreatedDate) {
            return compareToCreatedDate(other);
        } else if (SORT_FIELD == SortField.Score) {
            return compareToScore(other);
        }
        // this shouldn't be the case, add your error handling
        // here as required
        return 0;
    }
  
    // Compares ApplicationName field
    Integer compareToApplicationName(Object other) {
        String otherName = other != null ? ((ApplicationWraper)other).ApplicationName : '';  
        if (SORT_DIR == SortDirection.ASCENDING)    
            return this.ApplicationName.compareTo(otherName);  
        else
            return otherName.compareTo(this.ApplicationName);
    }
    
    Integer compareToType(Object other) {
        String otherName = other != null ? ((ApplicationWraper)other).Type : '';  
        if (SORT_DIR == SortDirection.ASCENDING)    
            return this.Type.compareTo(otherName);  
        else
            return otherName.compareTo(this.Type);
    }
    
    // Compares CreatedDate field
    Integer compareToCreatedDate(Object other) {
        // assuming if their is no datetime, it would be NOW
        // this might not be applicable for your biz logic
        // so please take care of that
        DateTime otherCheckInTime = other != null ? ((ApplicationWraper)other).CreatedDate : System.now();  
        // use Datetime.getTime() to do get the numeric time in millis
        if (SORT_DIR == SortDirection.ASCENDING)
            return (this.CreatedDate.getTime() - otherCheckInTime.getTime()).intValue();
        else
            return (otherCheckInTime.getTime() - this.CreatedDate.getTime()).intValue();
    }
 
    // Compares Score field
    Integer compareToScore(Object other) {
    Integer otherSocre = other != null ? ((ApplicationWraper)other).Score : 0;  
    if (SORT_DIR == SortDirection.ASCENDING)   
        return this.Score - otherSocre;
    else
        return otherSocre - this.Score;  
    }
}