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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postToServerFunction(randomKeyGenerator() , xCoordinate: xCoordinate , yCoordinate: yCoordinate)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    func postToServerFunction(randomStringKey : String, xCoordinate : Double, yCoordinate:Double){
        println("let's post")
        var url: NSURL = NSURL(string: "http://54.200.204.64:5000")!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var bodyData = "key=\(randomStringKey)&xCoordinate=\(xCoordinate)&yCoordinate=\(yCoordinate)&password=password"
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                println(response)
                
        }
    }

   
}
