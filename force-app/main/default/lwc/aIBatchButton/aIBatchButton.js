import { LightningElement, api, wire, track } from 'lwc';

import handleBatchAssessmentResponses from '@salesforce/apex/LWCController.handleBatchAssessmentResponses';

import { NavigationMixin } from 'lightning/navigation';

export default class AIBatchButton extends NavigationMixin (LightningElement) {
    @track showModal = false;
    @api recordId;
    @track AIPlanRecordId;
    @track modalError; 
    modalData; 

    // // Wire the method and get the result
    // @wire(handleBatchAssessmentResponses, { assessmentRecordId: '$recordId' })
    // wiredResult({ data, error }) {
    //     if (data) {
    //         // Handle the data returned from the Apex method
    //         console.log('Result:', data);
    //     } else if (error) {
    //         // Handle any errors
    //         console.error('Error:', error);
    //     }
    // }


//     openModal(){
//         this.handleButtonClick();
//         // this.modalData = "integrated"
//          //this.showModal = true;
       
//         //console.log(this.modalData)
//         //this.getmodalData();
// }




openModal(){
    this.handleButtonClick()
        .then(() => {
            // The promise has resolved, set modalData with the result
            this.getmodalData();
            //this.modalData = this.AIPlanRecordId;
            //this.showModal = true; // Open the modal
        })
        .catch(error => {
            console.log('Error in openModal', error);
            this.modalError = error;
            this.getmodalData();
            //this.showModal = true; // Open the modal with an error message
        });
}



closeModal() {
    this.showModal = false;
}

getmodalData(){

    //this.modalData = 'handled integration'
    if (this.modalError) {
        // Result is empty or falsy
       this.modalData = this.modalError;
        this.showModal = true;
    } 
}

    handleButtonClick() {
        return new Promise((resolve, reject) => {
        
        handleBatchAssessmentResponses({ assessmentRecordId :this.recordId })
            .then(result => {
                console.log('Success calling handleBatchAssessmentResponses 7');
                console.log(this.recordId);
                console.log(result);

                this.AIPlanRecordId = result;
                

                if (this.AIPlanRecordId == null) {
                    onsole.log('Error handleBatchAssessmentResponses - Null plan ID');
                } 
                else {

                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.AIPlanRecordId,
                            objectApiName: 'Auto_Settlement_Plan__c', // Replace with your object's API name
                            actionName: 'view'
                        }
                    }).then(url => {
                        window.open(url, "_blank");
                    });

                    console.log('Navigating handleBatchAssessmentResponses');
                    resolve();
            }})
            .catch(error => {
                console.log('Error calling handleBatchAssessmentResponses');
                this.modalError = 'Error - Generating AI plan failed'; 
                reject(error); 
            });
    });

}}