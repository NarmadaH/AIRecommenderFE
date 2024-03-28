public class AssessmentTriggerHandler {
    
    private static Integer batchSize = 50;
    private static String endpoint = 'https://k2aitestv1.herokuapp.com';
    private static String endpoint1 = 'https://ymcars-rayhaan.herokuapp.com/';
    
    public static void handleUpdateAssessmentRequest(List<AssessmentResponseCustom> assessmentResponseCustomList) {
        
        List<List<AssessmentResponseCustom>> assessmentResponseSplitList = new List<List<AssessmentResponseCustom>>();
        
        if(assessmentResponseCustomList.size()>batchSize){
            for(Integer i = 0 ; i < (assessmentResponseCustomList.size() / batchSize)+1 ; i++){
                List<AssessmentResponseCustom> assessmentResponseSizedList = new List<AssessmentResponseCustom>();
                for(Integer j = (i*batchSize); (j<(i*batchSize)+batchSize) && j < assessmentResponseCustomList.size() ; j++){
                    assessmentResponseSizedList.add(assessmentResponseCustomList.get(j));
                }
                assessmentResponseSplitList.add(assessmentResponseSizedList);
            }
        }else{
            assessmentResponseSplitList.add(assessmentResponseCustomList);
        }
        sendAssessmentResponseCustomObject(assessmentResponseSplitList);
    }
    
    
    private static void sendAssessmentResponseCustomObject(List<List<AssessmentResponseCustom>> assessmentResponseSplitList){
        
        for(Integer i = 0; i<assessmentResponseSplitList.size();i++){
            try{            	
                callHerokuApi(JSON.serialize(new AssessmentResponseCustomWrapper(assessmentResponseSplitList.get(i))));
            } catch (exception ex) {
                System.debug('Exception occured while calling Heroku Api');
            	System.debug(ex);
            }
        }
        
    }
    
    //Resend the request after the timeout
    //Do it 3 times, and if you don't get a response, then just move on
    //Set timeout to 20 seconds instead of 30
    @future(callout=true)
    private static void callHerokuApi(String data){
        
        /*HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint1);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        Map<String, List<AssessmentResponseCustom>> tags = new Map<String, List<AssessmentResponseCustom>>();
        AssessmentResponseCustomWrapper assessmentResponseCustomWrapper = (AssessmentResponseCustomWrapper) JSON.deserialize(data,AssessmentResponseCustomWrapper.class);
        tags.put('data', assessmentResponseCustomWrapper.getAssessmentResponseCustomList());
		req.setbody(JSON.serialize(tags));
        Http http = new Http();
        System.debug('Sending data to heroku Api for actions');
        HTTPResponse response = http.send(req);*/
        
        //Set the number of re-tries to 3
        Integer numberOfRetries = 3;
        
        Double timeoutInSeconds = 0.1; // Set the timeout to 20 seconds
		DateTime startTime = DateTime.now();
        
        HTTPResponse response;
        
        do {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint1);
            req.setMethod('POST');
            req.setHeader('Content-type', 'application/json');
            
            // Prepare your request body
            Map<String, List<AssessmentResponseCustom>> tags = new Map<String, List<AssessmentResponseCustom>>();
            AssessmentResponseCustomWrapper assessmentResponseCustomWrapper = (AssessmentResponseCustomWrapper) JSON.deserialize(data, AssessmentResponseCustomWrapper.class);
            tags.put('data', assessmentResponseCustomWrapper.getAssessmentResponseCustomList());
            req.setBody(JSON.serialize(tags));
            
            Http http = new Http();
            System.debug('Sending data to Heroku API for actions');
            // HTTPResponse response = http.send(req);
            response = http.send(req);
            // Check if a response is received
            if (response.getStatusCode() != null) {
                // Handle your response here
                break; // Exit the loop since we received a response
            }
            
            // Check for timeout
            // Integer elapsedTime = DateTime.now().difference(startTime).getSeconds();
            Long elapsedTime = Datetime.now().getTime() - startTime.getTime();
            if (elapsedTime >= timeoutInSeconds) {
                // Handle timeout scenario here (e.g., log, throw exception, etc.)
                System.debug('Timeout occurred. No response received within the specified time.');
                break; // Exit the loop due to timeout
            }
            
            numberOfRetries -= 1;
            
            // Sleep before sending the next request (optional)
            // You may adjust the time based on your needs
            // Integer waitTimeMillis = 5000; // Wait for 5 seconds before the next request
            // System.sleep(5000);
            Datetime currentTimeSleep = Datetime.now();
            
            Long timeDifferenceSleep = 5000;
            
            do {
                timeDifferenceSleep = Datetime.now().getTime() - currentTimeSleep.getTime();
                
            }
            while(timeDifferenceSleep >= 0);
    
		} while (numberOfRetries > 0); // Keep looping until a response or timeout occurs
        
        
        
        //req.setTimeout(30000);
		System.debug('Response body from heroku Api' + response.getBody());        
        if(response.getstatusCode() == 200 && response.getbody() != null){
            HerokuActionResponseWrapper herokuActionResponseWrapper = (HerokuActionResponseWrapper) JSON.deserialize(response.getBody(), HerokuActionResponseWrapper.class);
        	List<HerokuActionResponse> actionList = herokuActionResponseWrapper.getherokuActionResponseList();
        	updateOrInsertActionList(actionList);
        } else {
            System.debug('Heroku Api response not correct');
        }
        
    }
    
    private static void updateOrInsertActionList(List<HerokuActionResponse> actionList){
        
        List<Recommended_Action__c> recommendedActionListToInsert = new List<Recommended_Action__c>();
        
        for(Integer i=0; i < actionList.size(); i++){
            System.debug('Test success insert 0!!');
            HerokuActionResponse herokuActionResponse = actionList.get(i);
            String settlementId = herokuActionResponse.getSettlementPlanId();
            String responseId = herokuActionResponse.getResponseId();
            List<RecommendedAction> responseActionList = herokuActionResponse.getActions();
            List<Auto_Recomandation__c> aiRecommendationList = [select id, Auto_Settlement_Plan__r.id, 
                                            Statement_ID__c from Auto_Recomandation__c Where Auto_Settlement_Plan__r.id  = :settlementId
                                           and Statement_ID__c = :responseId];
            Auto_Recomandation__c recommendationObj;
            
            if(aiRecommendationList.size() == 1){
                recommendationObj = aiRecommendationList.get(0);
                //recommendationObj.LastModifiedById = herokuActionResponse.getLastModifiedId();
				List<Recommended_Action__c> recommendedActionList = [select id, Auto_Recomandation__r.id, Action__c, Action_ID__c from Recommended_Action__c Where Auto_Recomandation__r.id  = :recommendationObj.Id];
                if (recommendedActionList.size()>0) {
                    try {
                        delete recommendedActionList;
                        
                    } catch(Exception ex) {
                    	System.debug('Unable to Delete Previous Recommended Actions');
                    	System.debug(ex);
                        return;
                    }
                }
            } else if (aiRecommendationList.size() == 0) {
                recommendationObj = new Auto_Recomandation__c();
                ymcaswo_k2__Referral__c referralObj = new ymcaswo_k2__Referral__c();
                recommendationObj.Statement__c = herokuActionResponse.getStatement();
                recommendationObj.Auto_Settlement_Plan__c = settlementId;
                recommendationObj.Statement_ID__c = responseId;
                recommendationObj.Statement_Category__c = herokuActionResponse.getStatementCategory();
                //recommendationObj.Name = herokuActionResponse.getStatement();
                recommendationObj.Name_New__c = herokuActionResponse.getStatement();                
                recommendationObj.Statement_Main_Catergory__c = herokuActionResponse.getStatementMainCategory();
                recommendationObj.Referral__c = referralObj.id;
                //recommendationObj.LastModifiedById = herokuActionResponse.getLastModifiedId();
                insert recommendationObj;
                System.debug('Test success insert 1!!');
                
            }
            
            Integer priority = 0;
            
            if (recommendationObj != null) {
            
                for(Integer j=0; j < responseActionList.size(); j++){
                    Recommended_Action__c recommendedAction = new Recommended_Action__c();
                    recommendedAction.Action__c = responseActionList.get(j).getAction();
                    recommendedAction.Action_ID__c = responseActionList.get(j).getActionId();
                    recommendedAction.Auto_Recomandation__c = recommendationObj.Id;
                    recommendedActionListToInsert.add(recommendedAction);
                    System.debug('Test success insert 2!!');
                    
                   if (priority == 0){
                        recommendedAction.isSelected__c = 1;
                   } else {
                       recommendedAction.isSelected__c = 0;
                   }
                    
                    priority++;
                }
                
                // Adding other recommendation Action to the list
                Recommended_Action__c recommendedAction = new Recommended_Action__c();
                recommendedAction.Action__c = 'Other';
                recommendedAction.Action_ID__c = 'Other';
                recommendedAction.isSelected__c = 0;
                recommendedAction.Auto_Recomandation__c = recommendationObj.Id;
                recommendedActionListToInsert.add(recommendedAction);
                System.debug('Test success insert 3!!');
			            
            }   
        }
        
        try {
        	
            upsert recommendedActionListToInsert;
            system.debug('Updated Recommendation and Actions Successfully... !!!');
        } catch(Exception ex) {
            System.debug('Unable to Update Actions');
            System.debug(ex);
        }
    }

}