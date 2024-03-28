import { LightningElement, api, track } from 'lwc';
import handleAIIntergration from '@salesforce/apex/LWCController.handleAIIntergration';

import { NavigationMixin } from 'lightning/navigation';

export default class AIIntergrationButton extends NavigationMixin (LightningElement) {
    @track showModal = false;
    modalData ;
     //modalData ;
    @ track modalError ;
    @track modalResult ;
    @api recordId;
    //@track AIPlanRecordId;


    // openModal(){
    //         this.handleButtonClick();
    //         // this.modalData = "integrated"
    //          //this.showModal = true;
           
    //         //console.log(this.modalData)
    //         this.getmodalData();
    // }


    openModal() {
        this.handleButtonClick()
            .then(() => {
                this.getmodalData();
                this.showModal = true;
            })
            .catch(error => {
                console.error('Error in openModal', error);
                // Handle the error if needed
            });
    }
    

   

    closeModal() {
        this.showModal = false;
    }

    getmodalData(){

        //this.modalData = 'handled integration'
        if (this.modalResult) {
            // Result is empty or falsy
           this.modalData = this.modalResult;
          

            //this.showModal = true;
        } else {
            // Result is not empty or truthy
             this.modalData = this.modalError;
             //this.showModal = true;
        }
    }

//     handleButtonClick() {

//         // Return a promise from the API call
//     return new Promise((resolve, reject) => {
        
//         handleAIIntergration({ assessmentRecordId :this.recordId })
//             .then(result => {
//                 console.log('Success calling handleAIIntergration');
//                 console.log(this.recordId);
//                 console.log(result);
//                 this.modalResult = result;
//                 resolve(); // Resolve the promise when done
//                 //this.getmodalData();
               
                

//             //     this.AIPlanRecordId = result;


//             //     if (this.AIPlanRecordId == null) {
//             //         onsole.log('Error handleBatchAssessmentResponses - Null plan ID');
//             //     } 
//             //     else {

//             //         this[NavigationMixin.GenerateUrl]({
//             //             type: 'standard__recordPage',
//             //             attributes: {
//             //                 recordId: this.AIPlanRecordId,
//             //                 objectApiName: 'Auto_Settlement_Plan__c', // Replace with your object's API name
//             //                 actionName: 'view'
//             //             }
//             //         }).then(url => {
//             //             window.open(url, "_blank");
//             //         });

//             //         console.log('Navigating handleBatchAssessmentResponses');
//             // }
//             }
//             )
//             .catch(error => {
//                 console.log('Error calling handleAIIntergration');
//                 console.log(error);
//                 this.modalError = error;
//                 //this.getmodalData();
//                 reject(error); // Reject the promise on error
//             });
//     }
// }


handleButtonClick() {
    // Return a promise from the API call
    return new Promise((resolve, reject) => {
        handleAIIntergration({ assessmentRecordId: this.recordId })
            .then(result => {
                console.log('Success calling handleAIIntergration');
                console.log(this.recordId);
                console.log(result);
                // Handle the API result here
                this.modalResult = result;
                resolve(); // Resolve the promise when done
            })
            .catch(error => {
                console.log('Error calling handleAIIntergration');
                console.log(error);
                // Handle API errors here
                error = 'Error - Adding AI actions to plan failed';
                this.modalError = 'Error - Adding AI actions to plan failed';

                reject(error); // Reject the promise on error
            });
    });
}}