/**
 
 */
@isTest
global class MockObjects implements HttpCalloutMock{
 	
 	global HttpResponse respond(HttpRequest req){
 		
 		//Only creating a generic respons at the moment.
 		
 		HttpResponse res = new HttpResponse();
 		res.setHeader('Content-Type', 'application/json');
 		res.setStatusCode(202);
 		String statusBody = '';
 		
 		res.setBody(statusBody);
 		return res;
 				
 	}      
}