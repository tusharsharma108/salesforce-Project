import { LightningElement, wire } from 'lwc';
import getPlace from '@salesforce/apex/getSalesOffice.findSalesOffice';

export default class SalesOffice extends LightningElement {

    place = '';
    salesOffice(event){
        this.place = event.target.value;
    }
    placeData = {};
    error;
    showClaimProperty = false;

    @wire(getPlace, {place: '$place'})
    wiredPlace(response){
        if(response.data){
            // The query returns an array, but we want the first result
            this.placeData = response.data.length > 0 ? response.data[0] : {};
            this.error = undefined;
        }else if(response.error){
            this.error = response.error.body.message;
            this.placeData = {};
        }
    }
    
    handleClaimProperty() {
        if(this.place && this.placeData.Name != null){
            console.log('Showing available properties for:', this.place);
            this.showClaimProperty = true;
        }
    }

    handleBackToSalesOffice() {
        // Hide the avilableProperties component and show sales office
        this.showClaimProperty = false;
    }
}