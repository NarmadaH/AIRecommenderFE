public class AssessmentResponseCustomWrapper {
    
    private List<AssessmentResponseCustom> assessmentResponseCustomList;
    
    public AssessmentResponseCustomWrapper(List<AssessmentResponseCustom> assessmentResponseCustomList){
        this.assessmentResponseCustomList = assessmentResponseCustomList;
    }
    
    public List<AssessmentResponseCustom> getAssessmentResponseCustomList(){
        return this.assessmentResponseCustomList;
    }

}