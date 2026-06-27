public class TempClass {

    public static List<Sales_Office__c> findSalesOffice(String place){
        List<Sales_Office__c> getOffice = [SELECT Name, Sales_Region__c, Year_to_Date_Sales__c 
                                           FROM Sales_Office__c WHERE Name =: place];
        system.debug(getOffice);
        return getOffice;
    }
    public static List<Property__c> findPropertyByPlace(String place){
        List<Property__c> getPropert = [SELECT Name, Property_City__c, Proprty_Address__c, Sales_Price__c, Status__c  
                                        FROM Property__c WHERE Property_City__c =: place AND Status__c = 'Open'];
        system.debug(getPropert);
        return getPropert;
    }
}