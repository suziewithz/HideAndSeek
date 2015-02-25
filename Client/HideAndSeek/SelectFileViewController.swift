//
//  SelectFileViewController.swift
//  HideAndSeek
//
//  Created by suz on 2/9/15.
//  Copyright (c) 2015 suz. All rights reserved.
//

import UIKit
import MessageUI

class SelectFileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, DBRestClientDelegate{

    var fileList : [String]!
    var hideOrSeek : String!
    var xCoordinate : Double!
    var yCoordinate : Double!
    var selectedFile : String!
    var dbRestClient: DBRestClient?
    

    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {

        dbRestClient = DBRestClient(session: DBSession.sharedSession())
        dbRestClient!.delegate = self
        
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
    
    override func viewWillAppear(animated: Bool) {
        fileList = listFilesFromDocumentsFolder()
        tableView.reloadData()
    }
    
    // put filenames of files in app directory in fileList array.
    func listFilesFromDocumentsFolder() -> [String] {
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
    
    // when cell is selcted, push.
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
                tableView.reloadData()
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
    
    // actions on swift left
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var dropboxRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Dropbox", handler:{action, indexpath in
            let filenameToUpload = self.fileList[indexPath.row]
            var dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            var path = dir.stringByAppendingPathComponent(filenameToUpload)
            self.dbRestClient?.uploadFile(filenameToUpload, toPath: "/", withParentRev: nil, fromPath: path)
            tableView.reloadData()
            
        })
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            let filenameToDelete = self.fileList[indexPath.row]
            self.deleteFileData(filenameToDelete)
            self.fileList.removeAtIndex(indexPath.row)
            tableView.reloadData()
        })
        
        return [dropboxRowAction, deleteRowAction];
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
        // when file is not long enough
        if (fileData.length < 27) {
            return false
        }
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
        if selectedData == nil {
            return NSData()
        }
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

            if !DBSession.sharedSession().isLinked() {
                // should let use know why ayou are asking for dropbox permissions
                
                // now ask for permission
                DBSession.sharedSession().linkFromController(self)
            }
            if dbRestClient == nil {
                dbRestClient = DBRestClient(session: DBSession.sharedSession())
                dbRestClient!.delegate = self
            }
            if (dbRestClient != nil && DBSession.sharedSession().isLinked()) {
                NSLog("let's import file")
                let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DropboxTableViewController") as DropboxTableViewController

                self.navigationController?.pushViewController(secondViewController, animated: true)
            }
            
        case 2:
            NSLog("Google Drive")
        default:
            NSLog("Default")
            break
            //Some code here..
        }
    }
    
    // upload to Dropbox..
    func restClient(client: DBRestClient!, uploadedFile destPath: NSString!, from srcPath: NSString!, metadata: DBMetadata!) {
        var refreshAlert = UIAlertController(title: metadata.filename, message: "stored", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: { (action: UIAlertAction!) in
            println("File uploaded successfully to path: \(metadata.path)")
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func restClient(client: DBRestClient!, movePathFailedWithError error: NSError!) {
        var refreshAlert = UIAlertController(title: "failed", message: "fail to store file", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: { (action: UIAlertAction!) in
            
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
        println("File upload failed with error: \(error)")
    }
    
    
    func restClient(client: DBRestClient!, loadedMetadata: DBMetadata!) {
        if (loadedMetadata.isDirectory){
            for file in loadedMetadata.contents {
                NSLog("\(file.filename)")
            }
        }
    }

}
