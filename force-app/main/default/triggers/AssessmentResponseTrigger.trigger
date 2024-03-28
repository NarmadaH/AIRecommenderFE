trigger AssessmentResponseTrigger on ymcaswo_k2__Assessment_Response__c (after update) {
    static string urlOfDefaultActionFile = 'Default Actions for Statements v 1.0.xlsx'; 
    List<AssessmentResponseCustom> assessmentResponseCustomList = new List<AssessmentResponseCustom>();
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('Trigger Started !!!');
        for(ymcaswo_k2__Assessment_Response__c assessmentResponseObj: trigger.new){
            if(assessmentResponseObj.ymcaswo_k2__Priority__c != Trigger.oldMap.get(assessmentResponseObj.id).ymcaswo_k2__Priority__c && 
               assessmentResponseObj.ymcaswo_k2__Priority__c){
                   
                   ID assessmentId = assessmentResponseObj.ymcaswo_k2__Assessment__c;
                   /**
                   Schema.SObjectType sobjectType = myId.getSObjectType();
                   String sobjectName = sobjectType.getDescribe().getName();

                   SObject assessmentObj = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = :myId');
                   **/
                   List<Auto_Settlement_Plan__c> settlementPlanIdList = [Select Settlement_Plan_ID__c from Auto_Settlement_Plan__c Where Assessment__c = :assessmentId];
                   Auto_Settlement_Plan__c settlementPlanObj;
                   
                   if (settlementPlanIdList.size() == 0) {
                       //08/10 - Bug fix - do not add actions if the settlement plan is not already created by - AI plan button
                       return;
                       
                       /*
                       // Create new Settlement Plan
                       settlementPlanObj = new Auto_Settlement_Plan__c();
                       settlementPlanObj.Assessment__c = assessmentId;
                       //settlementPlanObj.Name = assessmentId;
                       
                        // Bug fix
                        System.debug('Creating New AI Plan');
                        
                        //Get contact name
                        List<ymcaswo_k2__Assessment__c> assessments = [SELECT ymcaswo_k2__Contact__r.Name FROM ymcaswo_k2__Assessment__c WHERE Id = :assessmentId];
                
                        string contactName;
                        if (!assessments.isEmpty() && assessments[0].ymcaswo_k2__Contact__r != null) {
                            contactName = assessments[0].ymcaswo_k2__Contact__r.Name;
                            System.debug('Name Object: ' + contactName);
                            settlementPlanObj.Contact__c = contactName;
                        }
                        else {
                            System.debug('Error! in gettong contact name');
                        }
                       
                        String generatedString = 'AI-' + String.valueOf((Integer)Math.floor(Math.random() * 900000) + 100000);
						settlementPlanObj.Settlement_Plan_ID__c = generatedString;
                        
                        
                        insert settlementPlanObj;
                        
                        List<Auto_Settlement_Plan__c> settlementPlanIdListNew = [Select Settlement_Plan_ID__c from Auto_Settlement_Plan__c 
                                                                          Where Assessment__c = :assessmentId];
                        
                        settlementPlanObj = settlementPlanIdListNew.get(0);
                        System.debug('Creating New AI Plan - success');
						*/
                       
                   } else if (settlementPlanIdList.size() == 1) {
                       System.debug('AI Plan exists');
                       settlementPlanObj = settlementPlanIdList.get(0);
                   }
                   
                   if (settlementPlanIdList.size() <= 1) {
                       assessmentResponseCustomList.add(new AssessmentResponseCustom(assessmentResponseObj.ymcaswo_k2__Response_Text__c, 
                                                                                 assessmentResponseObj.ymcaswo_k2__Statement__c,
                                                                                 assessmentResponseObj.id, settlementPlanObj.Id, 
                                                                                     urlOfDefaultActionFile, assessmentResponseObj.ymcaswo_k2__Indicator__c, assessmentResponseObj.ymcaswo_k2__Category__c, assessmentResponseObj.LastModifiedById));
                   }
        
                   
                    /**                    
                   assessmentResponseCustomList.add(new AssessmentResponseCustom(assessmentResponseObj.ymcaswo_k2__Response_Text__c, 
                                                                                 assessmentResponseObj.ymcaswo_k2__Statement__c,
                                                                                 'a1p4g000000eoXTAAY', settlementPlanId.get(0).Name)); 
                                                                                //assessmentResponseObj.id, )); 
                   **/    
            } else if (assessmentResponseObj.ymcaswo_k2__Priority__c != Trigger.oldMap.get(assessmentResponseObj.id).ymcaswo_k2__Priority__c && 
                       !assessmentResponseObj.ymcaswo_k2__Priority__c) {
                           ID assessmentId = assessmentResponseObj.ymcaswo_k2__Assessment__c;
                           List<Auto_Settlement_Plan__c> settlementPlanIdList = [Select Settlement_Plan_ID__c from Auto_Settlement_Plan__c Where Assessment__c = :assessmentId];
                
                           if (settlementPlanIdList.size()==1) {
               
                               List<Auto_Recomandation__c> aiRecommendationList = [select id, Auto_Settlement_Plan__r.id, 
                                            Statement_ID__c from Auto_Recomandation__c Where Auto_Settlement_Plan__r.id  = :settlementPlanIdList.get(0).id
                                           and Statement_ID__c = :assessmentResponseObj.id];
                               if(aiRecommendationList.size() == 1){
                                   Auto_Recomandation__c recommendationObj = aiRecommendationList.get(0);
                                   List<Recommended_Action__c> recommendedActionList = [select id, Auto_Recomandation__r.id, Action__c, Action_ID__c from Recommended_Action__c Where Auto_Recomandation__r.id  = :recommendationObj.Id];
                                   try {
                                       if (recommendedActionList.size()>0) {
                                           delete recommendedActionList;
                                       }
                                       delete aiRecommendationList;
                                   } catch(Exception ex) {
                                       System.debug('Unable to Delete Previous Recommended Actions');
                                       System.debug(ex);
                                       return;
                                   }
                               }                    
                           }
                           
                           
            }
        }
        if(assessmentResponseCustomList.size()>0){
            AssessmentTriggerHandler.handleUpdateAssessmentRequest(assessmentResponseCustomList);
        }
    }              
}