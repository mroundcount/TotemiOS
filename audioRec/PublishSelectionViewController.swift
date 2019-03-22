//
//  PublishSelectionViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 3/10/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit
import AWSS3
import SwiftyJSON
//PublishTableViewCell

class PublishSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var activeTags : NSMutableArray = []
    var postCell: PublishTableViewCell!
    let s3Transfer = S3TransferUtility()
    var token : String?
    var usernameString = ""
    let preferences = UserDefaults.standard
    var selectedIndex : NSInteger! = -1
    var selectedIndexPath : IndexPath!
    var posts : [Post] = []
    var variable : String?
    var username: String?
    var desc: String?
    var timeCreated: String?
    var duration: Double?
    var audioData: URL?
    
    var usernames : NSArray?
    let dbManager = DatabaseManager()
    
    //need to change post type
    var selectionArray: [Any] = []
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "selectorToRecorder", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (posts.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : PublishTableViewCell!

        cell.sizeToFit()
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            //selectionArray.remove(usernameString, at: selectionArray.endIndex)
            //selectionArray.remove(at: index)
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            print(tableView.indexPathForSelectedRow)
            // Add your username detail to the array
            //selectionArray.insert(posts.username, at: selectionArray.endIndex)
        }
    }
    
    


    @IBAction func publishBtn(_ sender: UIButton) {
        
        print("variable: \(variable)")
        print("token: \(token)")
        print("username: \(username)")
        print("desc \(desc)")
        print("tc: \(timeCreated)")
        print("duration: \(duration)")
        publish()

        self.performSegue(withIdentifier: "selectorToFeed", sender: nil)
    }
    
    
    func publish() {
        print("publishing")
        
        let timeInterval = Int(NSDate().timeIntervalSince1970)
        let likes : Int = 0
        self.timeCreated = String(timeInterval)
        let data = JSON([
            "username": self.username,
            "description": desc,
            "timeCreated": String(timeInterval),
            "likes": String(likes),
            "duration": duration
            ])
        
        let array : [JSON] = [data]
        let variableJson = JSON(["Post" : array])
        
        
        let dbManager = DatabaseManager()
        
        // TODO: update the dbManager thing with a post that uses a token
        let postID = dbManager.createNewPost(token: self.token!, data: variableJson.rawString()!)
        print("ID of the post just returned \(postID)")
        
        
        // This is just a test to upload to s3
        let dataURL = getDirectory().appendingPathComponent("myrecorder.m4a")
        let s3Transfer = S3TransferUtility()
        do {
            let audioData = try Data(contentsOf: dataURL as URL)
            s3Transfer.uploadData(data: audioData, postID: postID)
            
            
        } catch {
            print("Unable to load data: \(error)")
        }
        
    }
    
    func getDirectory() -> URL{
        //Searching for all the URLS in the documents directory and taking the first one and returning the URL to the document directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //defining our constant.
        //We will use the first URL path
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    
    
    
    
    func getUsernames(){
        let dataString = "{\"Username\":[{\"username\":\"" + self.usernameString + "\"}]}"
        
        self.usernames = []
        print("-------------- getting usernames --------------")
        self.usernames = dbManager.getUsernames(token: self.token!) as NSArray
        
        self.usernames = self.usernames!.reversed() as NSArray
        
        print(self.usernames!)
    }

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsernames()
        
        // Do any additional setup after loading the view.
    }
}

