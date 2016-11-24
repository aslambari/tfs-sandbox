public class CookieHelperController{
    public static void makeCookie(String usrId){
        Cookie UserId = new Cookie('UserId',usrId,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{UserId});        
    }
    
    public static String fetchCookieValue(){
        Cookie UserId = ApexPages.currentPage().getCookies().get('UserId');
        if(UserId != null && UserId.getValue().trim().length() > 0 ){
            return UserId.getValue();
        }
        return null;
    }
    
    public static void deleteCookie(){
        Cookie UserId = new Cookie('UserId','',null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{UserId});
    }
}