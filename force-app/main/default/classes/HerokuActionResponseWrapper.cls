public class HerokuActionResponseWrapper {
    
    private List<HerokuActionResponse> data;
    
    public HerokuActionResponseWrapper(List<HerokuActionResponse> herokuActionResponseList){
        this.data = herokuActionResponseList;
    }
    
    public List<HerokuActionResponse> getherokuActionResponseList(){
        return this.data;
    }

}