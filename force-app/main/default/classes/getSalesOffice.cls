public without sharing class getSalesOffice {
    
    @AuraEnabled(cacheable=true)
    public static List<Sales_Office__c> findSalesOffice(String place){
        List<Sales_Office__c> getOffice = [SELECT Name, Sales_Region__c, Year_to_Date_Sales__c FROM Sales_Office__c WHERE Name =: place];
        return getOffice;
    }
    @AuraEnabled(cacheable=true)
    public static List<Property__c> findPropertyByPlace(String place){
        List<Property__c> getPropert = [SELECT Name, Property_City__c, Proprty_Address__c, Sales_Price__c, Status__c  
                                        FROM Property__c WHERE Property_City__c =: place AND Status__c = 'Open'];
        return getPropert;
    }

    @AuraEnabled
    public static String claimProperties(List<Id> propertyIds) {
        try {
            // Get the current user's contact
            Id userId = UserInfo.getUserId();
            List<Contact> agent = [SELECT Id, Agent_User__c FROM Contact WHERE Agent_User__c =:userId];

            if (agent.isEmpty()) {
                throw new AuraHandledException('No contact associated with current user. Please contact your administrator.');
            }

            // Get the properties to update
            List<Property__c> propertiesToUpdate = [SELECT Id, Status__c, Agent__c 
                                                    FROM Property__c WHERE Id IN :propertyIds AND Status__c = 'Open'];

            if (propertiesToUpdate.isEmpty()) {
                throw new AuraHandledException('No available properties found to claim.');
            }

            // Update properties with contact and status
            for (Property__c prop : propertiesToUpdate) {
                prop.Agent__c = agent[0].Id;
                prop.OwnerId = userId;
                prop.Status__c = 'Working';
            }

            update propertiesToUpdate;

            return 'Success: ' + propertiesToUpdate.size() + ' properties claimed successfully.';

        } catch (Exception e) {
            throw new AuraHandledException('Error claiming properties: ' + e.getMessage());
        }
    }

}