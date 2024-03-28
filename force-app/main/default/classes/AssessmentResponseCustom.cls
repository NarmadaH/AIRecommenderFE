public class AssessmentResponseCustom {
    
    private String responseText;
    private String statement;
    private String responseId;
    private String settlementPlanId;
    private String url;
    private String statementCategory;
    private String statementMainCategory;
    private ID lastModifiedId;
    
    public AssessmentResponseCustom(String responseText, String statement, String responseId, String settlementPlanId, String url, String statementCategory, String statementMainCategory, ID lastModifiedId){
        this.responseText = responseText;
        this.statement = statement;
        this.responseId = responseId;
        this.settlementPlanId = settlementPlanId;
        this.url = url;
        this.statementCategory = statementCategory;
        this.statementMainCategory = statementMainCategory;
        this.lastModifiedId = lastModifiedId;
        
    }
    

}