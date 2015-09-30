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
        let dataLength    = Int(self.length)
        let dataBytes     = UnsafePointer<UInt8>(self.bytes)
        self.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let bufferData :NSMutableData   = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)!
        let bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        let bufferLength  = size_t(bufferData.length)
        let operation: CCOperation = UInt32(kCCDecrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
        var numBytesDecrypted: Int = 0
        let cryptStatus = CCCrypt(operation,
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
        if (passwordTextField.text!.isEmpty){
            let refreshAlert = UIAlertController(title: "wrong password", message: "please type password", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: { (action: UIAlertAction) in
                print("no password")
            }))
            activityIndicator.stopAnimating()
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        else {
            let password = passwordTextField.text
            let encryptedPassword = password!.md5
            
            var selectedData = getDataFromFile(selectedFile)
            let fileID = getFileIDFromData(selectedData)
            selectedData = extractFileIDFromData(selectedData)
            
            let iv = sendToServerFunction(fileID, xCoordinate: xCoordinate, yCoordinate: yCoordinate)
            
            let decryptedData = selectedData.AES256DecryptDataWithKey(encryptedPassword!, iv: iv)
            
            storeDecryptedData(decryptedData, fileID: fileID)
            
            activityIndicator.stopAnimating()
            
            let refreshAlert = UIAlertController(title: "decrypted successfully", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "go back to main", style: .Default, handler: { (action: UIAlertAction) in
                print("successfully decrepyted. go back to main.")
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
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePathToWrite = "\(paths)/decrypted_\(selectedFile)"
        print("\(filePathToWrite)")
        
        fileManager.createFileAtPath(filePathToWrite, contents: file, attributes: nil)
    }
    
    // read nsdata from file
    func getDataFromFile(filename: String) -> NSData {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let getDataPath = paths.stringByAppendingString("/" + filename)
        var selectedData = NSData()
        do {
            selectedData = try NSData(contentsOfFile: getDataPath, options: NSDataReadingOptions.DataReadingUncached)
        } catch {
            
        }
        return selectedData
    }

    // send locations and fileId to server and get iv if it matches.
    func sendToServerFunction(fileID : String, xCoordinate : Double, yCoordinate:Double) -> String {
        /*
        let url: NSURL = NSURL(string: "http://54.200.204.64:5000/seek")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        let requestDictionary = [
            "xCoordinate" : "\(xCoordinate)",
            "yCoordinate" : "\(yCoordinate)",
            "fileID" : "\(fileID)"
        ]
        
        print("\(requestDictionary)")

        let bodyData: NSData?
        do {
            bodyData = try NSJSONSerialization.dataWithJSONObject(requestDictionary, options: [])
        } catch {
            bodyData = nil
        }
        
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData
        
        var response: NSURLResponse?
        let urlData: NSData?
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        } catch {
            urlData = nil
        }
        
        let iv :NSString! = NSString(data: urlData!, encoding: NSUTF8StringEncoding)
        NSLog ("\(iv)")*/
        let iv = "abcdefghijklmnop"
        return iv as String
    }
    
    // read fileID in file. (last 16 chars)
    func getFileIDFromData (targetData : NSData) -> String {
        let fileIdRange = NSMakeRange(targetData.length - 16, 16)
        NSLog("\(fileIdRange)")
        let bufferData :NSMutableData = NSMutableData(length: 16)!
        let bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        targetData.getBytes(bufferPointer, range: fileIdRange)
        NSLog("arr : \(bufferData)")
        let fileID : NSString! = NSString(data: bufferData, encoding: NSUTF8StringEncoding)
        NSLog("fileID: \(fileID)")
        return fileID! as String
    }
    
    // remove fileID and "hideandseek" from data.
    func extractFileIDFromData (targetData : NSData) -> NSData {
        let bufferData :NSMutableData = NSMutableData(length: targetData.length - 27)!
        let bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        targetData.getBytes(bufferPointer, range: NSMakeRange(0, targetData.length - 27))
        return bufferData
    }
    
    func DismissKeyboard(){
        passwordTextField.endEditing(true)
    }
    
    
    
    

}
