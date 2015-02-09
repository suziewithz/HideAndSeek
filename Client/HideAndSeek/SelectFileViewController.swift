//
//  SelectFileViewController.swift
//  HideAndSeek
//
//  Created by suz on 2/9/15.
//  Copyright (c) 2015 suz. All rights reserved.
//

import UIKit

class SelectFileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var fileList : [String]!
    var hideOrSeek : String!
    var xCoordinate : Double!
    var yCoordinate : Double!
    var selectedFile : String!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
                let fileManager:NSFileManager = NSFileManager.defaultManager()
        fileList = listFilesFromDocumentsFolder()

        let count = fileList.count
        var isDir:Bool = true;
        
        for var i:Int = 0; i < count; i++
        {
            if fileManager.fileExistsAtPath(fileList[i]) != true
            {
                println("\(fileList[i])")
            }
        }
        
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
            self.performSegueWithIdentifier("PushDataToSeek", sender: self)
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
}
