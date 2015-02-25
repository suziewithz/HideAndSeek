//
//  DropboxTableViewController.swift
//  HideAndSeek
//
//  Created by suz on 2/25/15.
//  Copyright (c) 2015 suz. All rights reserved.
//

import UIKit

class DropboxTableViewController: UITableViewController, DBRestClientDelegate {

    var dropboxFileList = NSMutableArray()
    var dbRestClient: DBRestClient?
    var selectedFile : String!
    let selectedFilePath : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRestClient = DBRestClient(session: DBSession.sharedSession())
        dbRestClient!.delegate = self
        dbRestClient?.loadMetadata("/")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return dropboxFileList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        
        cell.textLabel?.text = "\(dropboxFileList[indexPath.row])"

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedFile = "\(dropboxFileList[indexPath.row])"
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToWrite = "\(paths)/\(selectedFile)"
        dbRestClient?.loadFile("/\(selectedFile)", intoPath: filePathToWrite)

    }

    func restClient(client: DBRestClient!, loadedMetadata: DBMetadata!) {
        if (loadedMetadata.isDirectory){
            for file in loadedMetadata.contents {
                NSLog("\(file.filename?)")
                dropboxFileList.addObject(file.filename!!)
                tableView.reloadData()
            }
        }

    }
    
    func restClient(client: DBRestClient!, loadedFile localPath: NSString!, contentType: String!, metadata: DBMetadata!) {
        NSLog("file loaded into path \(localPath)" )
        let selectedData = NSData(contentsOfFile: localPath, options: NSDataReadingOptions.UncachedRead, error: nil)
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToWrite = "\(paths)/\(selectedFile)"
        fileManager.createFileAtPath(filePathToWrite, contents: selectedData, attributes: nil)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveFile(filename: String) {
    
    }
}
