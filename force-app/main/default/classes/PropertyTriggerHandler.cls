public class PropertyTriggerHandler {
    
    public static void validateFivePropertyPerAgent(List<Property__c> newList){
        Set<Id> agentIds = new Set<Id>();
        for(Property__c pro :newList){
            if(pro.Agent__c != null){
                agentIds.add(pro.Agent__c);
            }
        }
        Map<Id, Integer> agentIdvsNoOfProperty = new Map<Id, Integer>();
        Map<Id, Decimal> agentIdvsDefalutCommission = new Map<Id, Decimal>();
        List<Contact> agentList = [SELECT Id, Name, Default_Commission_Split__c, Agent_User__c, (SELECT Name, Status__c FROM Properties__r WHERE Status__c = 'Working') 
                                   FROM Contact WHERE Id IN :agentIds];
            for(Contact con :agentList){
                agentIdvsNoOfProperty.put(con.Id, con.Properties__r.size());
                agentIdvsDefalutCommission.put(con.Id, con.Default_Commission_Split__c);
            }
        for(Property__c pro :newList){
            if(pro.Agent__c != null && agentIdvsNoOfProperty.get(pro.Agent__c) > 4){
                pro.addError('One Agent can work on only 5 properties');
            }else if(pro.Agent__c != null){
                pro.Agent_Commission_Percentage__c = agentIdvsDefalutCommission.get(pro.Agent__c);
            }
        }
    }
 
//Closed Pending Approval

    public static void updateSalesPrice(List<Property__c> newList) {
        
        Set<Id> agentContactIds = new Set<Id>();
        Set<Id> salesOfficeIds = new Set<Id>();
        
        for (Property__c prop : newList) {
            if (prop.Agent__c != null && prop.Status__c == 'Closed Pending Approval') {
                agentContactIds.add(prop.Agent__c);
            }
            if (prop.Sales_Office__c != null && prop.Status__c == 'Closed Pending Approval') {
                salesOfficeIds.add(prop.Sales_Office__c);
            }
        }
        
        if (agentContactIds.isEmpty() && salesOfficeIds.isEmpty()) {
            return;
        }
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Year_To_Date_Total_Sales__c FROM Contact WHERE Id IN :agentContactIds]);
        
        Map<Id, Sales_Office__c> officesMap = new Map<Id, Sales_Office__c>([SELECT Id, Year_To_Date_Sales__c FROM Sales_Office__c WHERE Id IN :salesOfficeIds]);
        
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Sales_Office__c> officesToUpdate = new List<Sales_Office__c>();
        
        for (Property__c prop : newList) {
            if (prop.Sales_Price__c == null) continue;

            if (prop.Agent__c != null) {
                Contact con = contactsMap.get(prop.Agent__c);
                if (con != null) {
                    Decimal current = (con.Year_To_Date_Total_Sales__c != null) ? con.Year_To_Date_Total_Sales__c : 0;
                    con.Year_To_Date_Total_Sales__c = current + prop.Sales_Price__c;
                    contactsToUpdate.add(con);
                }
            }
            
            if (prop.Sales_Office__c != null) {
                Sales_Office__c office = officesMap.get(prop.Sales_Office__c);
                if (office != null) {
                    Decimal current = (office.Year_To_Date_Sales__c != null) ? office.Year_To_Date_Sales__c : 0;
                    office.Year_To_Date_Sales__c = current + prop.Sales_Price__c;
                    officesToUpdate.add(office);
                }
            }
        }
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        if (!officesToUpdate.isEmpty()) {
            update officesToUpdate;
        }
    }
    
    public static void updateCommissionsOnApproval(List<Property__c> newList, Map<Id, Property__c> oldMap) {
    
    List<Property__c> approvedProperties = new List<Property__c>();
    
    // Identify properties where status changed to "Closed Approved"
    for (Property__c prop : newList) {
        Property__c oldProp = (oldMap != null) ? oldMap.get(prop.Id) : null;
        
        if (prop.Status__c == 'Closed Approved' 
            && (oldProp == null || oldProp.Status__c != 'Closed Approved')) {
            
            approvedProperties.add(prop);
        }
    }
    
    if (approvedProperties.isEmpty()) {
        return;
    }
    
    Set<Id> agentContactIds = new Set<Id>();
    for (Property__c prop : approvedProperties) {
        if (prop.Agent__c != null) {
            agentContactIds.add(prop.Agent__c);
        }
    }
    
    // Query current commission totals
    Map<Id, Contact> contactsMap = new Map<Id, Contact>([
        SELECT Id, Year_to_Date_Total_Commissions__c 
        FROM Contact 
        WHERE Id IN :agentContactIds
    ]);
    
    List<Contact> contactsToUpdate = new List<Contact>();
    List<Property__c> propertiesToUpdate = new List<Property__c>();   // Separate list for updates
    
    for (Property__c prop : approvedProperties) {
        
        if (prop.Sales_Price__c == null || prop.Agent_Commission_Percentage__c == null) {
            continue;
        }
        
        Decimal agencyRate = 0.03; // 3%
        Decimal commissionAmount = prop.Sales_Price__c * agencyRate * prop.Agent_Commission_Percentage__c/100;
        
        // IMPORTANT: Create a NEW record for update (do NOT modify Trigger.new record)
        Property__c propToUpdate = new Property__c(
            Id = prop.Id,
            Agent_Commission_Amount__c = commissionAmount
        );
        propertiesToUpdate.add(propToUpdate);
        
        // Update Agent's Year to Date Total Commissions
        if (prop.Agent__c != null) {
            Contact con = contactsMap.get(prop.Agent__c);
            if (con != null) {
                Decimal currentCommission = (con.Year_to_Date_Total_Commissions__c != null) 
                                          ? con.Year_to_Date_Total_Commissions__c : 0;
                
                con.Year_to_Date_Total_Commissions__c = currentCommission + commissionAmount;
                contactsToUpdate.add(con);
            }
        }
    }
    
    // Perform DML
    if (!propertiesToUpdate.isEmpty()) {
        update propertiesToUpdate;
    }
    
    if (!contactsToUpdate.isEmpty()) {
        update contactsToUpdate;
    }
}
// Restrict User to close approve
/*   
    public static void validateUser(List<Property__c> newList){
        Set<Id> agentIds = new Set<Id>();
        for(Property__c pro :newList){
            if(pro.Agent__c != null && pro.Status__c == 'Closed Approved'){
                agentIds.add(pro.Agent__c);
            }
        }
        Set<Id> restrictAgentList = new Set<Id>();
        List<Contact> agentList = [SELECT Id, Title FROM Contact WHERE Id IN :agentIds AND Title = 'Agent'];
        for(Contact con :agentList){
            if(con.Title == 'Agent'){
            restrictAgentList.add(con.Id);
            }
        }
        for(Property__c pro :newList){
            if(pro.Agent__c != null && pro.Status__c == 'Closed Approved' && restrictAgentList.contains(pro.Agent__c)){
                pro.addError('YOU ARE NOT AUTHORISE TO APPROVE RECORD');
            }
        }
    }
    */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}