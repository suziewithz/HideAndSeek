//
//  HideViewController.swift
//  HideAndSeek
//
//  Created by suz on 2015. 2. 6..
//  Copyright (c) 2015년 suz. All rights reserved.
//

import UIKit
import CryptoSwift
import Security

extension NSData {
    func AES256EncryptDataWithKey(key: String, iv:String) -> NSData {
        let keyData: NSData! = (key as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let keyBytes         = UnsafePointer<UInt8>(keyData.bytes)
        let keyLength        = size_t(kCCKeySizeAES256)
        let dataLength    = UInt(self.length)
        let dataBytes     = UnsafePointer<UInt8>(self.bytes)
        let bufferData :NSMutableData = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)!
        var bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        let bufferLength  = size_t(bufferData.length)
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
        let ivData: NSData! = (iv as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let ivPointer = UnsafePointer<UInt8>(ivData.bytes)
        var numBytesEncrypted: UInt = 0
        var cryptStatus = CCCrypt(operation,
            algoritm,
            options,
            keyBytes, keyLength,
            ivPointer,
            dataBytes, dataLength,
            bufferPointer, bufferLength,
            &numBytesEncrypted)
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            bufferData.length = Int(numBytesEncrypted) // Requiered to adjust buffer size
            return bufferData as NSData
        } else {
            println("Error: \(cryptStatus)")
            return NSData()
        }
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
        password = "password"
        encryptedPassword = password.md5()
        
        let selectedData = getDataFromFile(selectedFile)
        
        //let encryptedData = encryptFile(selectedData, key: encryptedPassword, iv: iv)
        let encryptedData = selectedData.AES256EncryptDataWithKey(encryptedPassword, iv: iv)

        let fileID : String! = postToServerFunction(randomIVGenerator() , xCoordinate: xCoordinate , yCoordinate: yCoordinate)
        
        storeEncryptedData(encryptedData, fileID: fileID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func storeEncryptedData(file: NSData, fileID : String){
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToWrite = "\(paths)/encrypted_\(selectedFile)"
        println("\(filePathToWrite)")
        
        fileManager.createFileAtPath(filePathToWrite, contents: file, attributes: nil)
    }
    
    func getDataFromFile(filename: String) -> NSData {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var getDataPath = paths.stringByAppendingPathComponent(filename)
        let selectedData = NSData(contentsOfFile: getDataPath, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        return selectedData!
    }
    
    func encryptFile(targetFile: NSData, key: String, iv:String) -> NSData {
        
        let keyData: NSData! = (key as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let keyBytes         = UnsafePointer<UInt8>(keyData.bytes)
        let keyLength        = size_t(kCCKeySizeAES256)
        
        let plainData = targetFile
        let dataLength    = UInt(plainData.length)
        let dataBytes     = UnsafePointer<UInt8>(plainData.bytes)
        
        var bufferData : NSMutableData = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)!
        var bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        let bufferLength  = size_t(bufferData.length)
        
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options = UInt32(kCCOptionPKCS7Padding)
        
        let ivData: NSData! = (iv as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let ivPointer = UnsafePointer<UInt8>(ivData.bytes)
        
        var numBytesEncrypted: UInt = 0
        
        var cryptStatus = CCCrypt(operation, algoritm, options, keyBytes, keyLength, ivPointer, dataBytes, dataLength, bufferPointer, bufferLength, &numBytesEncrypted)
        
        bufferData.length = Int(numBytesEncrypted)
        let base64cryptString = bufferData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        println(base64cryptString)
        
        let encryptedData = bufferData
        
        return encryptedData
    }
    
        
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
        NSLog ("\(fileID)")
        return fileID
    }
    
    
    
}
