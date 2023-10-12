import { LightningElement, api } from 'lwc';
export default class DisplayModal extends LightningElement {
    @api modalData;


    handleCloseClick() {
        // Dispatch an event to notify the parent component to close the modal
        const closeModalEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeModalEvent);
    }
}