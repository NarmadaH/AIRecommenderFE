public class AIIntergration {
    
    private static String assesmentId;
    private static String k2PlanId;
    
    private static ymcaswo_k2__Assessment__c assessment;
    private static ymcaswo_k2__Settlement_Plan__c k2Plan;
    private static List<ymcaswo_k2__Assessment_Response__c> AssessmentResponseList;
    private static Map<String, ymcaswo_k2__Assessment_Response__c> AssessmentResponseMap;
    private static List <ymcaswo_k2__Action__c> ActionLib;
    private static Map<String, ymcaswo_k2__Action__c> ActionLibMap;
    
    private static Map<Auto_Recomandation__c, List<Recommended_Action__c>> childToSubChildMap;
    private static List<ymcaswo_k2__Settlement_Plan_Action__c> newSettlementPlanActionList;
    private static List<ymcaswo_k2__Response_Action__c> newResponseActionList;
    private static Map<String, List<ymcaswo_k2__Response_Action__c>> actionToResponseActionMap;
    private static List<ymcaswo_k2__Settlement_Plan_Action__c> committedSettlementPlanActionList;
    private static Map<String, ymcaswo_k2__Settlement_Plan_Action__c> SettlementPlanActionMap;
    
        
    public static String handleAIIntergration(String AIPlanRecordId){
        
        String Error = 'AI Plan Actions Successfully Added';
                
        System.debug('AI Intergration Started !!!');
        
        
        //********************* K2 Plan Objects **********************//
        
        //Get assesment ID
        List<Auto_Settlement_Plan__c> AIPlan = [SELECT Assessment__c, Name FROM Auto_Settlement_Plan__c WHERE id = :AIPlanRecordId];
        
        if (AIPlan.size() == 0){
            Error = 'Error - AI Plan Intergration failed due to error';
            System.debug('Error! - ' + Error);
            
            return Error;                
        } 
        
        assesmentId = AIPlan[0].Assessment__c;
        
        if (assesmentId == ''){
            Error = 'Error - AI Plan Intergration failed due to empty Assesment ID';
            System.debug('Error! - ' + Error);
            
            return Error;                
        }
		System.debug('assesment id: ' + assesmentId);    

        
        //Get Assesmnet obj
        List<ymcaswo_k2__Assessment__c> assessmnetList = [Select Name, id from ymcaswo_k2__Assessment__c where id = :assesmentID Limit 1];
        
        if (assessmnetList.size() == 0){
            Error = 'Error - AI Plan Intergration failed due to error';
            System.debug('Error! - ' + Error);
            
            return Error;                
        }           
        
        assessment = assessmnetList[0];
        
        if (assessment == null){
            Error = 'Error - AI Plan Intergration failed due to empty Assesment';
            System.debug('Error! - ' + Error);
            
            return Error;                
        }       
        System.debug('assesment Name: ' + assessment.Name);
        
        
        //Get k2 settlement plan
        List<ymcaswo_k2__Settlement_Plan__c> K2PlanList = [Select Name, id from ymcaswo_k2__Settlement_Plan__c where ymcaswo_k2__Assessment__c =:assesmentID];
                
        if (K2PlanList == null || K2PlanList.size() == 0){
            Error = 'Error - Please create a Settlment Plan prior to adding the Actions';
            System.debug('Error! - ' + Error);
            
            return Error;                
        }
        
        k2Plan = K2PlanList[0];
        k2PlanId = k2Plan.id;
        System.debug('k2 plan name: ' + k2Plan.Name);
        
        
        //Prevent AI Intergration from happening multiple times
        List<ymcaswo_k2__Settlement_Plan_Action__c> existingSettementActions = [Select Name, id from ymcaswo_k2__Settlement_Plan_Action__c where ymcaswo_k2__Settlement_Plan__c =:k2PlanId];
        
        if (existingSettementActions.size() > 0){
            Error = 'Error - The AI actions have already been added. To add or remove actions, use the Settlement Plan Builder';
            System.debug('Error! - ' + Error);
            
            return Error;             
        }
        

        
        // Get k2 Assesment Responses 
        // this has the driving statements - I don't have drivers license
        AssessmentResponseList = [Select Name, id, ymcaswo_k2__Category__c, ymcaswo_k2__Statement__c from ymcaswo_k2__Assessment_Response__c where ymcaswo_k2__Assessment__c =:assesmentId];
		
        if (AssessmentResponseList.size() == 0){
            Error = 'Error - AI Plan Intergration failed due to empty Assesment Responses';
            System.debug('Error! - ' + Error);
            
            return Error;             
        }   
        else{
           System.debug('K2 Assesments exist - ' + AssessmentResponseList.size()); 
        }
        
        for (ymcaswo_k2__Assessment_Response__c response : AssessmentResponseList) 
        {
            System.debug('response Object: ' + response.ymcaswo_k2__Statement__c);
            System.debug('response Object ID: ' + response.id);
        }
        
        //create AssessmentResponse Map from AssessmentResponseList
        //create a map with {key(response.id) , Value(ymcaswo_k2__Assessment_Response__c obj)}
        
        AssessmentResponseMap = new Map<String, ymcaswo_k2__Assessment_Response__c>();

		for (ymcaswo_k2__Assessment_Response__c response : AssessmentResponseList) 
		{
    		String responseId = response.id;
    		AssessmentResponseMap.put(responseId, response);
		}

        
        
        
        //Get K2 Action Library
        //this has all the actions in the system - Apply for bus pass
        ActionLib = [Select Name, id, Import_ID__c, ymcaswo_k2__Assessment_Category__c from ymcaswo_k2__Action__c];
        
        if (ActionLib.size() == 0){
            Error = 'Error - AI Plan Intergration failed due to error in Action Library';
            System.debug('Error! - ' + Error);
            
            return Error;             
        } 
        
        System.debug('Action Lib size: ' + ActionLib.size());
        
        for (ymcaswo_k2__Action__c act : ActionLib) 
        {
            System.debug('Action Object: ' + act.Name);
            System.debug('Action Object ID: ' + act.Import_ID__c);
        }
        
   
        //Create Action map - key - act.Import_ID__c      
		ActionLibMap = new Map<String, ymcaswo_k2__Action__c>();

		for (ymcaswo_k2__Action__c act : ActionLib) 
		{   
             String importId = act.Import_ID__c;    
             ActionLibMap.put(importId, act);
		}
        
        //********************* AI Plan Objects **********************//        
        
        //Auto_Recomandation__c - has driving statements - I don't have drivers license
        //Recommended_Action__c - has the actios - Apply for bus pass
        
        childToSubChildMap = new Map<Auto_Recomandation__c, List<Recommended_Action__c>>();

        List<Auto_Recomandation__c> childRecords = [SELECT Id,Name, Statement_ID__c, Statement__c, Statement_Category__c, Statement_Main_Catergory__c, Status__c, (SELECT Id, Name, Action__c, Action_ID__c, Other_Data__c, Chosen__c, isSelected__c, Order__c, Other_Unquie_ID__c FROM Recommended_Actions__r WHERE isSelected__c = 1 ORDER BY Order__c) FROM Auto_Recomandation__c WHERE Auto_Settlement_Plan__c = :AIPlanRecordId];

        for (Auto_Recomandation__c child : childRecords) 
        {
            List<Recommended_Action__c> subChildRecords = child.Recommended_Actions__r;
            childToSubChildMap.put(child, subChildRecords);
        }
        

        if (childToSubChildMap.size() == 0){
            Error = 'Error - AI Plan Intergration failed due to system error';
            System.debug('Error! - ' + Error);
            
            return Error;             
        }   
        else{
           System.debug('AI objects exist - ' + AssessmentResponseList.size()); 
           System.debug(childToSubChildMap);
        }        
        
        

		//Map AI Objects to K2  
		          
        System.debug('Start Mapping !!');
        
        // Create newSettlementPlanActionList & actionToResponseActionMap
        
        actionToResponseActionMap = new Map<String, List<ymcaswo_k2__Response_Action__c>>();
        newResponseActionList = new List<ymcaswo_k2__Response_Action__c>();
        newSettlementPlanActionList = new List<ymcaswo_k2__Settlement_Plan_Action__c>();
        
        
        for(Auto_Recomandation__c child : childToSubChildMap.keySet()) {
            System.debug('Child Object: ' + child.Name);
            System.debug('Child Object ID: ' + child.Statement_ID__c);
            
            String statementId = child.Statement_ID__c;
            ymcaswo_k2__Assessment_Response__c assessmentResponseItem = AssessmentResponseMap.get(statementId);
            
			if (assessmentResponseItem != null) {                                
                List<Recommended_Action__c> subChildList = childToSubChildMap.get(child);
                
                if (subChildList != null && subChildList.size() != 0) {
                    
                    //Call settlementPlanActionMapping
                    settlementPlanActionMapping(assessmentResponseItem, subChildList);                    
                }
                else {
                    
                    System.debug('Error !! subchild - response action list missing or empty for: ' + child.Name);
                }               
            }
			else {
                System.debug('Error !! No matching Assessment Response found' + child.Name);
            }
        } 
        
        if (newSettlementPlanActionList.size() > 45){
            Error = 'Error - Exceeded Settlement Plan Action Limit - Only 45 Actions can be added to a Settlement Plan. Please remove actions to meet this limit';
            System.debug('Error! - ' + Error);
            
            return Error;             
        }
        
        
        //Commit newSettlementPlanActionList objs to db
        for (ymcaswo_k2__Settlement_Plan_Action__c nsplItem: newSettlementPlanActionList){
            System.debug('nsplItem - ' + nsplItem);
        }
        
        if (newSettlementPlanActionList != null) {
        	insert newSettlementPlanActionList;
        }
        
        //create SettlementPlanActionMap to map Response actions
        committedSettlementPlanActionList = [SELECT Id, Name, AIAction_Import_ID__c, ymcaswo_k2__Category__c from ymcaswo_k2__Settlement_Plan_Action__c where ymcaswo_k2__Settlement_Plan__c =:k2PlanId];
        
        if (committedSettlementPlanActionList == null || committedSettlementPlanActionList.size() == 0 ) {
            Error = 'Error - AI Plan Intergration failed due to System Error';
            System.debug('Error! - ' + Error);
            
            return Error;               
        }
        
        SettlementPlanActionMap = new Map<String, ymcaswo_k2__Settlement_Plan_Action__c>();

		for (ymcaswo_k2__Settlement_Plan_Action__c settlementPlanAct : committedSettlementPlanActionList) {
    		String unquieId = settlementPlanAct.AIAction_Import_ID__c + '|' + settlementPlanAct.ymcaswo_k2__Category__c;
    		SettlementPlanActionMap.put(unquieId, settlementPlanAct);
		} 
        System.debug('SettlementPlanActionMap! - ' + SettlementPlanActionMap);
        
        
        //Call responseActionMapping
        newSettlementPlanActionList = new List<ymcaswo_k2__Settlement_Plan_Action__c>();
        responseActionMapping(); 
        
        //Commit newResponseActionList objs to db
        if (newResponseActionList != null) {
        	insert newResponseActionList;
        }
        
        //Commit update to newSettlementPlanActionList - Field - AI_Recommended_Action
        if (!newSettlementPlanActionList.isEmpty()) {
            try {
                update newSettlementPlanActionList;
            } catch (DmlException e) {
                // Handle any exceptions that may occur during the update
                System.debug('Error updating records: ' + e.getMessage());
            }
		}

        
        
        System.debug('AI Intergration Completed !!!');
        
        return Error;
    }
  
    
    private static void settlementPlanActionMapping (ymcaswo_k2__Assessment_Response__c assessmentResponseItem, List<Recommended_Action__c> AiActions){
    	
        System.debug('Start settlementPlanActionMapping');
        System.debug('Assessment Response Object ID: ' + assessmentResponseItem.ymcaswo_k2__Category__c);
        System.debug('Assessment Response Object Name: ' + assessmentResponseItem.Name);  
        
        String actionCatergory = assessmentResponseItem.ymcaswo_k2__Category__c;
        
        for(Recommended_Action__c aiAction : AiActions)
        {
            System.debug('Sub-Child Object: ' + aiAction.Action__c);
            System.debug('Sub-Child Object Unqiue id: ' + aiAction.Action_ID__c); 
            
            String commonId;
            String otherActionUniqueId;
            String actionUniqueId = aiAction.Action_ID__c;              
            ymcaswo_k2__Action__c actionLibItem = ActionLibMap.get(actionUniqueId);
            
            if (actionLibItem != null) {
                
                System.debug('Start creating Settlement Plan Action for : ' + aiAction.Name);
                System.debug('Object Name: ' + actionLibItem.Name);  
                commonId = actionUniqueId+'|'+actionCatergory;

            } else if (actionUniqueId == 'Other') {
                
                System.debug('handle other action - : ' + aiAction.Other_Unquie_ID__c);
                
                //Note - By new requirments - need to handle multiple other actions that comes in Other_Unquie_ID__c as a string 
                //seperated by |. This was moved to new method
                //todo - refactor this & new method - to remove duplicate code
                
                handleOtherActionMapping(assessmentResponseItem, aiAction);
                continue;
                
                
                // ----- comment original code ----
                //otherActionUniqueId = aiAction.Other_Unquie_ID__c;
                //actionLibItem = ActionLibMap.get(otherActionUniqueId);
                
                //if (actionLibItem == null){
                //    System.debug('handle other action - error');
                //    continue;
                //}
                
                //commonId = otherActionUniqueId;
                
                //continue;
                
            } else {
                System.debug('Error settlementPlanActionMapping !! AI action not found in action lib: ' + aiAction.Action__c);
                continue;
            }
            
            
            //check if settlementPlanAction is already created
            if (actionToResponseActionMap.containsKey(commonId)) {
                System.debug('settlementPlanAction already created');
            } else {
                System.debug('craete new settlementPlanAction');
                ymcaswo_k2__Settlement_Plan_Action__c settlementPlanAction = new ymcaswo_k2__Settlement_Plan_Action__c();
                
                settlementPlanAction.ymcaswo_k2__Settlement_Plan__c = k2PlanId;
                settlementPlanAction.ymcaswo_k2__Action__c = actionLibItem.id;
                settlementPlanAction.ymcaswo_k2__Category__c = assessmentResponseItem.ymcaswo_k2__Category__c;
                
                if (actionUniqueId != 'Other'){
                    settlementPlanAction.AIAction_Import_ID__c = actionUniqueId;
                } else {
                    settlementPlanAction.AIAction_Import_ID__c = otherActionUniqueId;
                }
                    
                System.debug('craete new settlementPlanAction DONE!' + settlementPlanAction);
                newSettlementPlanActionList.add(settlementPlanAction);
            }
                        
            //create Respose Action
            ymcaswo_k2__Response_Action__c responseAction = new ymcaswo_k2__Response_Action__c();
            responseAction.ymcaswo_k2__Assessment_Response__c = assessmentResponseItem.id;
            
            if (actionUniqueId != 'Other'){
                responseAction.Action_Source__c = 'AI Recommended';
            } else {
                responseAction.Action_Source__c = 'Staff Recommended';
            }
            
            //Add to actionToResponseActionMap
            if (actionToResponseActionMap != null) {            
                if (actionToResponseActionMap.containsKey(commonId)) {
                    // The actionUniqueId already exists in the map
                    actionToResponseActionMap.get(commonId).add(responseAction);
                } else {
                    // The actionUniqueId does not exist in the map
                    List<ymcaswo_k2__Response_Action__c> newList = new List<ymcaswo_k2__Response_Action__c>();
                    newList.add(responseAction);
                    actionToResponseActionMap.put(commonId, newList);
                } 
            }
            
        }         
    }
    
    
    private static void handleOtherActionMapping(ymcaswo_k2__Assessment_Response__c assessmentResponseItem, Recommended_Action__c otherAction){
        System.debug('Start handleOtherActionMapping ' + otherAction.Other_Unquie_ID__c);
        
        String actionCatergory = assessmentResponseItem.ymcaswo_k2__Category__c;
        
        // Using '\\|' to escape the '|' character
        List<String> idList = otherAction.Other_Unquie_ID__c.split('\\|'); 
        
        for (String idItem : idList){
            ymcaswo_k2__Action__c actionLibItem;
            String commonId;
            String otherActionUniqueId = idItem;
            String actionUniqueId = 'Other';
            
            System.debug('other id Name: ' + idItem); 
            
            actionLibItem = ActionLibMap.get(otherActionUniqueId);
            
            if (actionLibItem == null){
                System.debug('handle other action - error');
                continue;
            }
            
            commonId = otherActionUniqueId +'|'+actionCatergory;
            

            
            //check if settlementPlanAction is already created
            if (actionToResponseActionMap.containsKey(commonId)) {
                System.debug('settlementPlanAction already created');
            } else {
                System.debug('craete new settlementPlanAction');
                ymcaswo_k2__Settlement_Plan_Action__c settlementPlanAction = new ymcaswo_k2__Settlement_Plan_Action__c();
                
                settlementPlanAction.ymcaswo_k2__Settlement_Plan__c = k2PlanId;
                settlementPlanAction.ymcaswo_k2__Action__c = actionLibItem.id;
                settlementPlanAction.ymcaswo_k2__Category__c = assessmentResponseItem.ymcaswo_k2__Category__c;
                
                if (actionUniqueId != 'Other'){
                    settlementPlanAction.AIAction_Import_ID__c = actionUniqueId;
                } else {
                    settlementPlanAction.AIAction_Import_ID__c = otherActionUniqueId;
                }
                    
                System.debug('craete new settlementPlanAction DONE!' + settlementPlanAction);
                newSettlementPlanActionList.add(settlementPlanAction);
            }
                        
            //create Respose Action
            ymcaswo_k2__Response_Action__c responseAction = new ymcaswo_k2__Response_Action__c();
            responseAction.ymcaswo_k2__Assessment_Response__c = assessmentResponseItem.id;
            
            if (actionUniqueId != 'Other'){
                responseAction.Action_Source__c = 'AI Recommended';
            } else {
                responseAction.Action_Source__c = 'Staff Recommended';
            }
            
            //Add to actionToResponseActionMap
            if (actionToResponseActionMap != null) {            
                if (actionToResponseActionMap.containsKey(commonId)) {
                    // The actionUniqueId already exists in the map
                    actionToResponseActionMap.get(commonId).add(responseAction);
                } else {
                    // The actionUniqueId does not exist in the map
                    List<ymcaswo_k2__Response_Action__c> newList = new List<ymcaswo_k2__Response_Action__c>();
                    newList.add(responseAction);
                    actionToResponseActionMap.put(commonId, newList);
                } 
            }            
            
        }
        
    }
    
    
    private static void responseActionMapping(){
        
        System.debug('Start responseActionMapping');
        
        if (actionToResponseActionMap == null || actionToResponseActionMap.size() == 0){
            System.debug('Error! actionToResponseActionMap is null or empty');            
            return;             
        } 
        
        for(String unquieActionId : actionToResponseActionMap.keySet()) {
            
            List<ymcaswo_k2__Response_Action__c> ResActList = actionToResponseActionMap.get(unquieActionId);
            
            if (ResActList == null || ResActList.size() == 0){
                System.debug('error empty ResActList for ' + unquieActionId);
                continue;                
            }
            
            Integer AICount = 0;
            Integer StaffCount = 0;
            ymcaswo_k2__Settlement_Plan_Action__c setPlanActItem = null;
            
            for (ymcaswo_k2__Response_Action__c resAct : ResActList){
                setPlanActItem = SettlementPlanActionMap.get(unquieActionId);
                
                if (setPlanActItem == null){
                    System.debug('error null setPlanActItem for ' + unquieActionId);
                    continue;  
                }
                
                //map settlment plan action to response action
                resAct.ymcaswo_k2__Settlement_Plan_Action__c = setPlanActItem.id;
                
                if (resAct.Action_Source__c == 'AI Recommended'){
                    AICount ++;
                } else {
                    StaffCount ++;
                }
                
                //add resAct to global map
                newResponseActionList.add(resAct);               
            }
            
            if (AICount != 0 && StaffCount != 0){
                setPlanActItem.AI_Recommended_Action__c = 'AI & Staff Recommended';
            } else if (AICount != 0 && StaffCount == 0){
                setPlanActItem.AI_Recommended_Action__c = 'AI Recommended';
            }else{
               setPlanActItem.AI_Recommended_Action__c = 'Staff Recommended'; 
            }
            
            newSettlementPlanActionList.add(setPlanActItem);
            
        }
    }

    
}