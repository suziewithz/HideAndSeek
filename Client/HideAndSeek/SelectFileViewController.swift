//
//  SelectFileViewController.swift
//  HideAndSeek
//
//  Created by suz on 2/9/15.
//  Copyright (c) 2015 suz. All rights reserved.
//

import UIKit

class SelectFileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate{

    var fileList : [String]!
    var hideOrSeek : String!
    var xCoordinate : Double!
    var yCoordinate : Double!
    var selectedFile : String!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "showActionSheet")
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        fileList = listFilesFromDocumentsFolder()

        let count = fileList.count
        var isDir:Bool = true;
        /*
        for var i:Int = 0; i < count; i++
        {
            if fileManager.fileExistsAtPath(fileList[i]) != true
            {
                println("\(fileList[i])")
            }
        }
        */
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func listFilesFromDocumentsFolder() -> [String]
    {
        var theError = NSErrorPointer()
        let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if dirs != nil {
            let dir = dirs![0]
            let fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(dir, error: theError)
            return fileList as [String]
        }else{
            let fileList = [""]
            return fileList
        }
    }
    


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fileList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        //we know that cell is not empty now so we use ! to force unwrapping
        
        cell!.textLabel?.text = self.fileList[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        selectedFile = fileList[indexPath.row]
        if self.hideOrSeek == "hide" {
            self.performSegueWithIdentifier("PushDataToHide", sender: self)
        }
        else {
            if checkEncrypted(selectedFile) == true {
                self.performSegueWithIdentifier("PushDataToSeek", sender: self)
            }
            else {
                var refreshAlert = UIAlertController(title: "It's not encrypted", message: "file was not encrypted", preferredStyle: UIAlertControllerStyle.Alert)
                
                refreshAlert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: { (action: UIAlertAction!) in
                    println("user chose unecrypted file.")
                }))
                presentViewController(refreshAlert, animated: true, completion: nil)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier :NSString! = segue.identifier
        if identifier.isEqualToString("PushDataToHide") {
            let viewController :HideViewController! = segue.destinationViewController as HideViewController
            viewController.xCoordinate = self.xCoordinate
            viewController.yCoordinate = self.yCoordinate
            viewController.selectedFile = self.selectedFile
        }
        if identifier.isEqualToString("PushDataToSeek") {
            let viewController :SeekViewController! = segue.destinationViewController as SeekViewController
            viewController.xCoordinate = self.xCoordinate
            viewController.yCoordinate = self.yCoordinate
            viewController.selectedFile = self.selectedFile
        }
    }
    
    func checkEncrypted(filename:String) -> Bool {
        let fileData = getDataFromFile(filename)
        let bufferData :NSMutableData = NSMutableData(length: 11)!
        var bufferPointer = UnsafeMutablePointer<UInt8>(bufferData.mutableBytes)
        fileData.getBytes(bufferPointer, range: NSMakeRange(fileData.length - 27, 11))
        NSLog("arr : \(bufferData)")
        let verification : NSString! = NSString(data: bufferData, encoding: NSUTF8StringEncoding)
        if (verification != nil) {
            if(verification.isEqualToString("hideandseek")){
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    func getDataFromFile(filename: String) -> NSData {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var getDataPath = paths.stringByAppendingPathComponent(filename)
        let selectedData = NSData(contentsOfFile: getDataPath, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        return selectedData!
    }
    
    func showActionSheet() {
        let actionSheet = UIActionSheet()
        actionSheet.title = "import from..."
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.addButtonWithTitle("Dropbox")
        actionSheet.addButtonWithTitle("Google Drive")
        actionSheet.cancelButtonIndex = 0
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int)
    {
        switch buttonIndex{
        case 0:
            NSLog("Canceled")
            break
        case 1:
            NSLog("Dropbox")
            let account = DBAccountManager.sharedManager().linkedAccount
            if ( account == nil ) {
                DBAccountManager.sharedManager().linkFromController(self)
            }
            else {
                NSLog("let's import file")
            }
        case 2:
            NSLog("Google Drive")
        default:
            NSLog("Default")
            break
            //Some code here..
        }
    }

}
