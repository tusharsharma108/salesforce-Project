import { LightningElement, wire, track } from 'lwc';
import regionalManager from '@salesforce/apex/salesRegion.findRegionalManager';
export default class SalesRegion extends LightningElement {

    showApproveProperties = false;
    selectedRegionId = '';
    
    handleApproveCommission(){
        // Get the first region's ID (or you could modify to handle multiple regions)
        if(this.regionalManagerData && this.regionalManagerData.length > 0){
            this.selectedRegionId = this.regionalManagerData[0].Id;
            this.showApproveProperties = true;
        }
    }
    
    handleBackToSalesRegion(){
        this.showApproveProperties = false;
    }
    
    @track regionalManagerData = [];
    error;
    @wire(regionalManager)
    wiredRegionalManager(response){
        if(response.data){
            this.regionalManagerData = response.data;
            this.error = undefined;
        }else if(response.error){
            this.error = response.error.body.message;
        }
    }
}