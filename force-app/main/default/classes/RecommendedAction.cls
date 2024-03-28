public class RecommendedAction {
    private String actionId;
    private String action;

    public RecommendedAction(String actionId, String action) {
        this.actionId = actionId;
        this.action = action;
    }
    
    public RecommendedAction(String action) {
        this.action = action;
    }
    
    
    public String getActionId() {
        return this.actionId;
    }
    
    public String getAction() {
        return this.action;
    }
}