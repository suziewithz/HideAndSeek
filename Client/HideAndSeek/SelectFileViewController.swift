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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func viewDidLoad() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "showActionSheet")
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        fileList = listFilesFromDocumentsFolder()

        let count = fileList.count
        var isDir:Bool = true;
        
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
        cell!.editing = true
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
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            let filenameToDelete = self.fileList[indexPath.row]
            self.deleteFileData(filenameToDelete)
            self.fileList.removeAtIndex(indexPath.row)
            tableView.reloadData()
        });
        
        return [deleteRowAction];
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
    
    func deleteFileData(filename : String) {
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToDelete = "\(paths)/\(filename)"
        var error : NSError?
        fileManager.removeItemAtPath(filePathToDelete, error: &error)
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
