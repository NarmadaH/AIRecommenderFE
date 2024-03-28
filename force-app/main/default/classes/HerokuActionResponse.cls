public class HerokuActionResponse {
    
    private String statement;
    private String responseId;
    private String settlementPlanId;
    private String responseText;
    private String statementCategory;
    private String statementMainCategory;
    private List<RecommendedAction> actions;
    private ID lastModifiedId;
    
    public HerokuActionResponse(String responseText, String statement, String settlementPlanId, String responseId,List<RecommendedAction> actions, String statementCategory, String statementMainCategory, ID lastModifiedId){
        this.statement = statement;
        this.responseText = responseText;
        this.settlementPlanId = settlementPlanId;
        this.responseId = responseId;
        this.actions = actions;
        this.statementCategory = statementCategory;
        this.statementMainCategory = statementMainCategory;
        this.lastModifiedId = lastModifiedId;
    }
    
    public String getSettlementPlanId(){
        return this.settlementPlanId;
    }
    
    public String getStatement(){
        return this.statement;
    }
    
    public String getResponseId(){
        return this.responseId;
    }
   
    public List<RecommendedAction> getActions(){
        return this.actions;
    }
    
    public String getStatementCategory(){
        return this.statementCategory;
    }
    
    public String getStatementMainCategory(){
        return this.statementMainCategory;
    }
    
    public ID getLastModifiedId(){
        return this.lastModifiedId;
    }
}