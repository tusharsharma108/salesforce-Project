import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import fetchProperty from '@salesforce/apex/salesRegion.findPropertiesFromRegion';
import approveMultipleProperties from '@salesforce/apex/salesRegion.approveMultipleProperties';
import updatePropertyCommission from '@salesforce/apex/salesRegion.updatePropertyCommission';

export default class ApproveProperties extends LightningElement {

    columns = [
        {label: 'Name', fieldName: 'Name'},
        {label: 'Sales Office', fieldName: 'salesOfficeName'},
        {label: 'Agent', fieldName: 'agentName'},
        {label: 'Sales Price', fieldName: 'Sales_Price__c', type: 'currency'},
        {label: 'Status', fieldName: 'Status__c'},
        {label: 'Agent Commission', fieldName: 'Agent_Commission_Percentage__c', editable: true}
    ];
    @api salesRegionId = '';
    @track propertyDetails = [];
    @track selectedRowIds = [];
    wiredPropertyResult;
    changedCommissions = [];
    draftValues = [];
    
    @wire(fetchProperty, {regionId: '$salesRegionId'})
    wiredProperty(result){
        this.wiredPropertyResult = result;
        if(result.data){
            this.propertyDetails = result.data.map(property => {
                return {
                    ...property,
                    salesOfficeName: property.Sales_Office__r ? property.Sales_Office__r.Name : '',
                    agentName: property.Agent__r ? property.Agent__r.Name : ''
                };
            });
            this.error = undefined;
        }else if(result.error){
            this.error = result.error.body.message;
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowIds = selectedRows.map(row => row.Id);
    }

    handleCellChange(event) {
        const updatedFields = event.detail.draftValues;
        this.draftValues = updatedFields;
        this.changedCommissions = updatedFields.map(draft => {
            return {
                Id: draft.Id,
                Agent_Commission_Percentage__c: draft.Agent_Commission_Percentage__c
            };
        });
        this.saveCommissionChanges();
    }
    
    saveCommissionChanges() {
        if (this.changedCommissions.length === 0) {
            return;
        }
        updatePropertyCommission({ properties: this.changedCommissions })
            .then(() => {
                this.showToast('Success', 'Agent Commission updated successfully', 'success');
                this.draftValues = [];
                this.changedCommissions = [];
                return refreshApex(this.wiredPropertyResult);
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : 'Error updating commission', 'error');
            });
    }
    
    handleApproveCommissions(){
        if(this.selectedRowIds.length === 0) {
            this.showToast('Warning', 'Please select at least one property to approve', 'warning');
            return;
        }
        
        approveMultipleProperties({ propertyIds: this.selectedRowIds })
            .then(result => {
                if(result.startsWith('Success')) {
                    this.showToast('Success', result, 'success');
                    this.selectedRowIds = [];
                    return refreshApex(this.wiredPropertyResult);
                } else {
                    this.showToast('Error', result, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : 'Unknown error occurred', 'error');
            });
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
