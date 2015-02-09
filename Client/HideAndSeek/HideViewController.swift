//
//  HideViewController.swift
//  HideAndSeek
//
//  Created by suz on 2015. 2. 6..
//  Copyright (c) 2015년 suz. All rights reserved.
//

import UIKit

class HideViewController: UIViewController {

    var xCoordinate : Double!
    var yCoordinate : Double!
    var selectedFile : String!
    
    @IBOutlet weak var selectedFileLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedFileLabel.text = selectedFile
        // postToServerFunction(randomKeyGenerator() , xCoordinate: xCoordinate , yCoordinate: yCoordinate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func randomKeyGenerator() -> String {
        var arr : [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]
        
        var randomStringKey : String = ""
        
        var arrSize = arr.count
        
        for i in 0 ..< 32 {
            var randomIndex : Int = Int(arc4random()) % arrSize
            randomStringKey = randomStringKey + arr[randomIndex]
        }
        
        print ("\(randomStringKey)")
        
        return randomStringKey
    }
    
    
    func postToServerFunction(randomStringKey : String, xCoordinate : Double, yCoordinate:Double) -> String {
        println("let's post")
        var url: NSURL = NSURL(string: "http://54.200.204.64:5000/hide")!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var fileID : NSString!
        let password = "password"
        var requestDictionary = [
            "xCoordinate" : "\(xCoordinate)",
            "yCoordinate" : "\(yCoordinate)",
            "key" : "\(randomStringKey)",
            "password" : "\(password)"
        ]
        
        println("\(requestDictionary)")
        

        var error: NSError?
        let bodyData = NSJSONSerialization.dataWithJSONObject(requestDictionary, options: nil, error: &error)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData
        NSURLConnection(request:  request, delegate: self, startImmediately: true)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var err : NSError
            fileID = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println("\(fileID)")
        }
        return "error"
    }
    
    
    
}
