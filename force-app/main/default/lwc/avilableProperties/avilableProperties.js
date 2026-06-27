import { LightningElement, wire, track, api } from 'lwc';
import propert from '@salesforce/apex/getSalesOffice.findPropertyByPlace';
import claimProperties from '@salesforce/apex/getSalesOffice.claimProperties';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class AvilableProperties extends LightningElement {

    columns = [
        {label: 'Name', fieldName: 'Name'},
        {label: 'Property City', fieldName: 'Property_City__c'},
        {label: 'Property Address', fieldName: 'Proprty_Address__c'},
        {label: 'Sales Price', fieldName: 'Sales_Price__c', type: 'currency'},
        {label: 'Status', fieldName: 'Status__c'}
    ];

    @track propertyDetails = [];
    @track selectedRowIds = [];
    
    // Public property to receive city from parent component
    @api propertyCity = '';
    
    // Header properties
    propertiesClaimedCount = 0;
    agentYTDSales = '$0';
    agentYTDCommissions = '$0';
    
    // Infinite loading
    enableInfiniteLoading = false;
    
    error;

    // Getter for salesOfficeName to display dynamic place
    get salesOfficeName() {
        return this.propertyCity ? `Available Properties - ${this.propertyCity}` : 'Available Properties';
    }

    wiredPropertyResult;
    
    @wire(propert, {place: '$propertyCity'})
    wiredPropert(response){
        this.wiredPropertyResult = response;
        if(response.data){
            this.propertyDetails = response.data;
            this.error = undefined;
        } else if(response.error){
            this.error = response.error.body.message;
            this.propertyDetails = [];
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowIds = selectedRows.map(row => row.Id);
    }

    handleLoadMore(event) {
        // Implement pagination logic here if needed
        event.target.isLoading = false;
    }

    claimProperties() {
        if(this.selectedRowIds.length === 0) {
            this.showToast('Warning', 'Please select at least one property to claim', 'warning');
            return;
        }
        
        // Call Apex to claim properties
        claimProperties({ propertyIds: this.selectedRowIds })
            .then(result => {
                this.showToast('Success', `Successfully claimed ${this.selectedRowIds.length} propert${this.selectedRowIds.length > 1 ? 'ies' : 'y'}`, 'success');
                this.selectedRowIds = [];
                // Refresh the property list
                return refreshApex(this.wiredPropertyResult);
            })
            .catch(error => {
                const errorMessage = error.body?.message || error.message || 'Unknown error occurred';
                this.showToast('Error', 'Error claiming properties: ' + errorMessage, 'error');
            });
    }

    claimAndContinue() {
        this.claimProperties();
        // Add continue logic here
    }

    cancel() {
        // Clear selections
        this.selectedRowIds = [];
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}