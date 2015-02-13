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
    
    @IBOutlet weak var selectedFileLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let iv = "zlkxA4yn0qxrlqKqPytyuYghUBDv0iZA"
        let fileID = "fileID"
        
        selectedFileLabel.text = "You selected \(selectedFile)"
        
        
        let password = "password"
        let encryptedPassword = password.md5()
        
        let selectedData = getDataFromFile(selectedFile)
        
        //let encryptedData = encryptFile(selectedData, key: encryptedPassword, iv: iv)
        let decryptedData = selectedData.AES256DecryptDataWithKey(encryptedPassword!, iv: iv)
        
        storeEncryptedData(decryptedData, fileID: fileID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func storeEncryptedData(file: NSData, fileID : String){
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToWrite = "\(paths)/decrypted_\(selectedFile)"
        println("\(filePathToWrite)")
        
        fileManager.createFileAtPath(filePathToWrite, contents: file, attributes: nil)
    }
    
    func getDataFromFile(filename: String) -> NSData {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var getDataPath = paths.stringByAppendingPathComponent(filename)
        let selectedData = NSData(contentsOfFile: getDataPath, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        return selectedData!
    }


}
