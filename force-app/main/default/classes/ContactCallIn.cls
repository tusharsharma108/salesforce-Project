@restResource(urlMapping='/getContactData')
Global class ContactCallIn {
    // TO GET CONTACT 
    @HttpGet
    global static List<Contact> getContact(){
        Map<String, Object> params = RestContext.Request.params;
        String firstName = (String) params.get('firstName');
        String lastName = (String) params.get('lastName');
        List<Contact> con = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact 
                             WHERE FirstName =: firstName AND LastName =: lastName];
        Return con;
    }
    
    // TO INSERT CONTACT
    @HttpPost
    global static Contact createContact(){
        String requestBody = RestContext.Request.requestBody.toString();
        RequestWrapper requestWrap = (RequestWrapper) JSON.deserialize(requestBody, RequestWrapper.class);
        
        Contact con = new Contact();
        con.firstName = requestWrap.firstName;
        con.lastName = requestWrap.lastName;
        con.phone = requestWrap.phone;
        con.email = requestWrap.email;
        insert con;
        return con;
        
    }
    
    // TO UPDATE CONTACT
    @HttpPut
    global static Contact updateContact(){
        
        Map<String, Object> params = RestContext.Request.params;
        String firstName = (String) params.get('firstName');
        String lastName = (String) params.get('lastName');
        List<Contact> getCon = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact 
                                WHERE FirstName =: firstName AND LastName =: lastName];
        
        Contact con = new Contact();
        if(!getCon.isEmpty()){
            String requestBody = RestContext.Request.requestBody.toString();
            //RequestWrapper requestWrap = (RequestWrapper) JSON.deserialize(requestBody, RequestWrapper.class);
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
            
            /*Contact con = new Contact();
              con.firstName = requestWrap.firstName;
              con.lastName = requestWrap.lastName;
              con.phone = requestWrap.phone;
              con.email = requestWrap.email; */
            con = getCon[0];
            con.firstName = (String)requestMap.get('firstName');
            con.lastName = (String)requestMap.get('lastName');
            con.phone = (String)requestMap.get('phone');
            con.email = (String)requestMap.get('email');
            
            update con;   
        }
        return con;
    }
    
    // TO DELETE CONTACT
    @HttpDelete
    global static List<Contact> deleteContact(){
        Map<String, Object> params = RestContext.Request.params;
        String firstName = (String) params.get('firstName');
        String lastName = (String) params.get('lastName');
        List<Contact> con = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact 
                             WHERE FirstName =: firstName AND LastName =: lastName];
        Delete con;
        Return con;
    }
    
    public class RequestWrapper{
        public String firstName;
        public String lastName;
        public String phone;
        public String email;
    }

}