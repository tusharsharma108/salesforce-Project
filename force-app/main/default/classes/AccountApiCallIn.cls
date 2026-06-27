@restResource(urlMapping='/getAccount')
global class AccountApiCallIn {
    @HttpGet
    global static List<Account> getAccountDetails(){
        Map<String, Object> getAccount = RestContext.Request.params;
        String name = (String) getAccount.get('Name');
        List<Account> accList = [SELECT Id, Name, Rating FROM Account WHERE Name =:name ];
        return accList;
    }
    @HttpPost
    global static Account insertAccountDetails(){
        String RequestBody = RestContext.Request.requestBody.toString();
        RequestWrapper requestWrap = (RequestWrapper) JSON.deserialize(RequestBody, RequestWrapper.class);
        Account acc = new Account();
        acc.Name = requestWrap.name;
        acc.Rating = requestWrap.rating;
        acc.Industry = requestWrap.industry;
        Insert acc;
        return acc;
    }
    public class RequestWrapper{
        public String name;
        public String rating;
        public String industry;   
    }
}