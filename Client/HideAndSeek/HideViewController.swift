//
//  HideViewController.swift
//  HideAndSeek
//
//  Created by suz on 2015. 2. 6..
//  Copyright (c) 2015년 suz. All rights reserved.
//

import UIKit
import Security

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

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypeTextField: UITextField!
    @IBOutlet weak var selectedFileLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func tapRecognized(sender: AnyObject) {
        DismissKeyboard()
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        activityIndicator.startAnimating()
        if (passwordTextField.text.isEmpty){
            var refreshAlert = UIAlertController(title: "wrong password", message: "please type password", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: { (action: UIAlertAction!) in
                println("no password")
            }))
            activityIndicator.stopAnimating()
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        else if (passwordTextField.text == retypeTextField.text) {
            let iv = randomIVGenerator()
            let selectedData = getDataFromFile(selectedFile)

            let encryptedPassword = passwordTextField.text.md5
            
            let encryptedData :NSData = selectedData.AES256EncryptDataWithKey(encryptedPassword!, iv: iv)
            
            let fileID : String! = postToServerFunction(randomIVGenerator() , xCoordinate: xCoordinate , yCoordinate: yCoordinate)
            
            storeEncryptedData(encryptedData, fileID: fileID)
            
            self.performSegueWithIdentifier("PushToHideResult", sender: self)
        }
            
        else {
            var refreshAlert = UIAlertController(title: "wrong password", message: "password and retype password are not the same", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: { (action: UIAlertAction!) in
                println("wrong password")
            }))
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        activityIndicator.stopAnimating()
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        selectedFileLabel.text = "You selected \(selectedFile)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func storeEncryptedData(file: NSData, fileID : String){
        var resultFile : NSData = file
        resultFile = appendStringToFile(resultFile, targetString: "hideandseek")
        resultFile = appendStringToFile(resultFile, targetString: fileID)
        
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToWrite = "\(paths)/encrypted_\(selectedFile)"
        
        fileManager.createFileAtPath(filePathToWrite, contents: resultFile, attributes: nil)
    }
    
    func getDataFromFile(filename: String) -> NSData {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var getDataPath = paths.stringByAppendingPathComponent(filename)
        let selectedData = NSData(contentsOfFile: getDataPath, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        return selectedData!
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
        NSLog ("fileID: \(fileID)")
        return fileID
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier :NSString! = segue.identifier
        if identifier.isEqualToString("PushToHideResult") {
            let viewController :HideResultViewController! = segue.destinationViewController as HideResultViewController
            viewController.selectedFile = self.selectedFile
        }
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        passwordTextField.endEditing(true)
        retypeTextField.endEditing(true)
    }
    
    func appendStringToFile (targetData: NSData, targetString: String) -> NSData {
        var resultData = targetData as NSMutableData
        resultData.appendData(targetString.dataUsingEncoding(NSUTF8StringEncoding)!)
        return resultData as NSData
    }
}
