public without sharing class salesRegion {
    
    @AuraEnabled(cacheable=true)
    public static List<Sales_Region__c> findRegionalManager(){
        try {
            Id userId = UserInfo.getUserId();
            List<Sales_Region__c> saleRegion = [SELECT Name, Regional_Manager__c, Regional_Manager__r.Name FROM Sales_Region__c 
                                                WHERE Regional_Manager__c =: userId];
            return saleRegion;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Property__c> findPropertiesFromRegion(String regionId){
        try {
            Set<Id> salesOfficeIds = new Set<Id>();
            List<Sales_Office__c> salesOffices = [SELECT Id, Name, Sales_Region__c, Year_to_Date_Sales__c 
                                                  FROM Sales_Office__c WHERE Sales_Region__c =: regionId];
            for(Sales_Office__c office : salesOffices){
                salesOfficeIds.add(office.Id);
            }
            List<Property__c> properties = [SELECT Name, Sales_Price__c, Status__c, 
                                                   Sales_Office__c, Sales_Office__r.Name,
                                                   Agent__c, Agent__r.Name,
                                                   Agent_Commission_Percentage__c
                                        FROM Property__c WHERE Sales_Office__c IN :salesOfficeIds AND Status__c = 'Closed Pending Approval'];
            return properties;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String approveMultipleProperties(List<Id> propertyIds) {
        try {
            if (propertyIds == null || propertyIds.isEmpty()) {
                return 'Error: No properties selected';
            }
            List<Property__c> updatePro = new List<Property__c>();
            List<Property__c> properties = [SELECT Id, Status__c FROM Property__c WHERE Id IN :propertyIds];
            for (Property__c prop : properties) {
                prop.Status__c = 'Closed Approved';
                updatePro.add(prop);
            }
            update updatePro;
            return 'Success: ' + properties.size() + ' properties approved';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static void updatePropertyCommission(List<Property__c> properties) {
        try {
            if (properties != null && !properties.isEmpty()) {
                update properties;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating Agent Commission: ' + e.getMessage());
        }
    }
}