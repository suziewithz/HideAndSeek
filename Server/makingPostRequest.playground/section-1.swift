// Playground - noun: a place where people can play

import UIKit

var request = NSMutableURLRequest(URL: NSURL(string: "http://54.200.204.64:5000/")!)
    
var session = NSURLSession.sharedSession()

request.HTTPMethod = "POST"



var params = ["key":"hi i am key", "xCoordinate" : "hi i am xcoordinate", "yCoordinate" : "hi i am yCoordinate", "password":"hi i am password"] as Dictionary



var err: NSError?

request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)

request.addValue("application/json", forHTTPHeaderField: "Content-Type")

request.addValue("application/json", forHTTPHeaderField: "Accept")



var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
    
    println("Response: \(response)")
    
    var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
    
    println("Body: \(strData)\n\n")
    
    var err: NSError?
    
    var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
    
    // json = {"response":"Success","msg":"User login successfully."}
    if((err) != nil) {
        
        println(err!.localizedDescription)
        
    }
        
    else {
        
        var success = json["response"] as? String
        
        println("Succes: \(success)")
        
        
        
        if json["response"] as NSString == "Success"
        
        {
            
            println("Login Successfull")
            
        }
        
        var responseMsg = json["msg"] as String
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.loginStatusLB.text = responseMsg
            
        })
        
        
        
    }
    
})

task.resume()