//
//  SeekViewController.swift
//  HideAndSeek
//
//  Created by suz on 2015. 2. 6..
//  Copyright (c) 2015년 suz. All rights reserved.
//

import UIKit
import Security


extension NSData {    
    func AES256DecryptDataWithKey(key: String, iv:String) -> NSData {
        let keyData: NSData! = (key as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let keyBytes         = UnsafePointer<UInt8>(keyData.bytes)
        let keyLength        = size_t(kCCKeySizeAES256)
        let ivData: NSData! = (iv as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        let ivPointer = UnsafePointer<UInt8>(ivData.bytes)
        let dataLength    = UInt(self.length)
        let dataBytes     = UnsafePointer<UInt8>(self.bytes)
        let string = self.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let bufferData :NSMutableData   = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)!
        var bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        let bufferLength  = size_t(bufferData.length)
        let operation: CCOperation = UInt32(kCCDecrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
        var numBytesDecrypted: UInt = 0
        var cryptStatus = CCCrypt(operation,
            algoritm,
            options,
            keyBytes, keyLength,
            ivPointer,
            dataBytes, dataLength,
            bufferPointer, bufferLength,
            &numBytesDecrypted)
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            bufferData.length = Int(numBytesDecrypted) // Requiered to adjust buffer size
            return bufferData as NSData
        } else {
            println("Error: \(cryptStatus)")
            return NSData()
        }
    }
}


class SeekViewController: UIViewController {

    var xCoordinate : Double!
    var yCoordinate : Double!
    var selectedFile : String!
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var selectedFileLabel: UILabel!
    
    @IBAction func tapRecognized(sender: AnyObject) {
        DismissKeyboard()
    }
    
    // decrtypt file
    @IBAction func seekPressed(sender: AnyObject) {
        activityIndicator.startAnimating()
        if (passwordTextField.text.isEmpty){
            var refreshAlert = UIAlertController(title: "wrong password", message: "please type password", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: { (action: UIAlertAction!) in
                println("no password")
            }))
            activityIndicator.stopAnimating()
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        else {
            let password = passwordTextField.text
            let encryptedPassword = password.md5
            
            let selectedData = getDataFromFile(selectedFile)
            let fileID = getFileIDFromData(selectedData)
            let targetData : NSData = extractFileIDFromData(selectedData)
            
            let iv = sendToServerFunction(fileID, xCoordinate: xCoordinate, yCoordinate: yCoordinate)
            
            let decryptedData = selectedData.AES256DecryptDataWithKey(encryptedPassword!, iv: iv)
            
            storeDecryptedData(decryptedData, fileID: fileID)
            
            activityIndicator.stopAnimating()
            
            var refreshAlert = UIAlertController(title: "decrypted successfully", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "go back to main", style: .Default, handler: { (action: UIAlertAction!) in
                println("successfully decrepyted. go back to main.")
                self.navigationController?.popToRootViewControllerAnimated(true)
            }))
            presentViewController(refreshAlert, animated: true, completion: nil)
            
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        selectedFileLabel.text = "You selected \(selectedFile)"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // save decrypted data in app directory.
    func storeDecryptedData(file: NSData, fileID : String){
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToWrite = "\(paths)/decrypted_\(selectedFile)"
        println("\(filePathToWrite)")
        
        fileManager.createFileAtPath(filePathToWrite, contents: file, attributes: nil)
    }
    
    // read nsdata from file
    func getDataFromFile(filename: String) -> NSData {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var getDataPath = paths.stringByAppendingPathComponent(filename)
        let selectedData = NSData(contentsOfFile: getDataPath, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        return selectedData!
    }

    // send locations and fileId to server and get iv if it matches.
    func sendToServerFunction(fileID : String, xCoordinate : Double, yCoordinate:Double) -> String {
        var url: NSURL = NSURL(string: "http://54.200.204.64:5000/seek")!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        var requestDictionary = [
            "xCoordinate" : "\(xCoordinate)",
            "yCoordinate" : "\(yCoordinate)",
            "fileID" : "\(fileID)"
        ]
        
        println("\(requestDictionary)")
        
        
        var error: NSError?
        let bodyData = NSJSONSerialization.dataWithJSONObject(requestDictionary, options: nil, error: &error)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData
        
        var response: NSURLResponse?
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        let iv :NSString! = NSString(data: urlData!, encoding: NSUTF8StringEncoding)
        NSLog ("\(iv)")
        return iv
    }
    
    // read fileID in file. (last 16 chars)
    func getFileIDFromData (targetData : NSData) -> String {
        let fileIdRange = NSMakeRange(targetData.length - 16, 16)
        NSLog("\(fileIdRange)")
        let bufferData :NSMutableData = NSMutableData(length: 16)!
        var bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        targetData.getBytes(bufferPointer, range: fileIdRange)
        NSLog("arr : \(bufferData)")
        let fileID : NSString! = NSString(data: bufferData, encoding: NSUTF8StringEncoding)
        NSLog("fileID: \(fileID)")
        return fileID!
    }
    
    // remove fileID and "hideandseek" from data.
    func extractFileIDFromData (targetData : NSData) -> NSData {
        let bufferData :NSMutableData = NSMutableData(length: targetData.length - 27)!
        var bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        targetData.getBytes(bufferPointer, range: NSMakeRange(0, targetData.length - 27))
        return bufferData
    }
    
    func DismissKeyboard(){
        passwordTextField.endEditing(true)
    }
    
    
    
    

}
