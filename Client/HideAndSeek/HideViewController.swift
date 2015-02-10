//
//  HideViewController.swift
//  HideAndSeek
//
//  Created by suz on 2015. 2. 6..
//  Copyright (c) 2015년 suz. All rights reserved.
//

import UIKit
//import CryptoSwift

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash)
    }
}

class HideViewController: UIViewController {

    var xCoordinate : Double!
    var yCoordinate : Double!
    var selectedFile : String!
    var password : String!
    var encryptedPassword : String!
    
    @IBOutlet weak var selectedFileLabel: UILabel!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let iv = randomIVGenerator()
        
        selectedFileLabel.text = "You selected \(selectedFile)"
        
        //
        
        //let selectedData = getDataFromFile(selectedFile)
        //let encryptedData = encryptFile(selectedData, key: password, iv: iv)
        
        

        // postToServerFunction(randomIVGenerator() , xCoordinate: xCoordinate , yCoordinate: yCoordinate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func storeData(file: NSData, fileID : String){
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToWrite = "\(paths)/encrypted_\(selectedFile)"
        println("filePathToWrite")
        
        fileManager.createFileAtPath(filePathToWrite, contents: file, attributes: nil)
    }
    
    func getDataFromFile(filename: String) -> NSData {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var getDataPath = paths.stringByAppendingPathComponent(filename)
        let selectedData = NSData(contentsOfFile: getDataPath, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        return selectedData!
    }
    /*
    func encryptFile(targetFile: NSData, key: String, iv:String) -> NSData {
        
        let keyData :NSData = key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        let ivData :NSData = iv.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        
        let encryptedData :NSData = targetFile.encrypt(Cipher.AES(key: keyData, iv: ivData, blockMode: CipherBlockMode.CBC))!
        return encryptedData
        
    }
    */
    func randomIVGenerator() -> String {
        var arr : [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]
        
        var randomStringIV : String = ""
        
        var arrSize = arr.count
        
        for i in 0 ..< 32 {
            var randomIndex : Int = Int(arc4random()) % arrSize
            randomStringIV = randomStringIV + arr[randomIndex]
        }
        
        print ("\(randomStringIV)")
        
        return randomStringIV
    }
    
    
    func postToServerFunction(randomStringIV : String, xCoordinate : Double, yCoordinate:Double) -> String {
        println("let's post")
        var url: NSURL = NSURL(string: "http://54.200.204.64:5000/hide")!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var fileID : NSString!
        var requestDictionary = [
            "xCoordinate" : "\(xCoordinate)",
            "yCoordinate" : "\(yCoordinate)",
            "iv" : "\(randomStringIV)"
        ]
        
        println("\(requestDictionary)")
        

        var error: NSError?
        let bodyData = NSJSONSerialization.dataWithJSONObject(requestDictionary, options: nil, error: &error)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData
        /*NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var err : NSError
            fileID = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println("\(fileID)")
        }*/
        var response: NSURLResponse?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)

        fileID = NSString(data: urlData!, encoding: NSUTF8StringEncoding)
        print ("\(fileID)")
        return fileID
    }
    
    
    
}
