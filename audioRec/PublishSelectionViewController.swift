//
//  PublishSelectionViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 3/10/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit
import AWSS3
//PublishTableViewCell

class PublishSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var activeTags : NSMutableArray = []
    var postCell: PublishTableViewCell!
    let s3Transfer = S3TransferUtility()
    var token = ""
    var usernameString = ""
    let preferences = UserDefaults.standard
    var selectedIndex : NSInteger! = -1
    var selectedIndexPath : IndexPath!
    var posts : [Post] = []
    
    //need to change post type
    var selectionArray: [Any] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (posts.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : PublishTableViewCell!
        
        if((posts.count) > 0){
            let post = posts[indexPath.row]
            let postID = post.postID!
            let username = post.username!
            
            cell = tableView.dequeueReusableCell(withIdentifier: "PublishTableViewCell") as? PublishTableViewCell
            cell.usernameLabel.text = username
            ///cell.token = self.token
        }
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
            // Add your food detail to the array
            selectionArray.insert(posts.username, at: selectionArray.endIndex)

        }
        
    }


    @IBAction func publishBtn(_ sender: UIButton) {
        print(selectionArray)
    }
    
    
    
    
    
    
    func getPosts(){
        posts = []
        let dbManager = DatabaseManager()
        let dataString = "{\"Username\":[{\"username\":\"" + self.usernameString + "\"}]}"
        
        var postsArray = dbManager.getPostsForFeed(token: self.token, data: dataString) as NSArray
        
         if((postsArray.count) > 0){
         for (index, element) in postsArray.enumerated() {
         let newPost = Post()
         let post = postsArray[index] as? [String: Any]
         //let description = post!["description"] as? String
         //newPost.description = description!
         let postID = post!["post_i_d"] as? Int
         newPost.postID = postID!
         //let likes = post!["likes"] as? Int
         //newPost.likes = likes!
         let username = post!["username"] as? String
         newPost.username = username!
         //let timeCreated = post!["time_created"] as? Int
         //newPost.timeCreated = timeCreated!
         //var duration = post!["duration"] as? Int
         //newPost.duration = duration!
         
         posts.append(newPost)
         }
         }
        
        self.posts = self.posts.reversed()
        
        print("Posts: \(posts)")
        let array = dbManager.getLikedPosts(token: self.token) as NSArray
        
        for (index, element) in array.enumerated() {
            let post = array[index] as? [String: Any]
            let postID = post!["post_i_d"] as? Int
            //likedPosts.add(postID)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.dataSource = self
        //self.tableView.delegate = self
        //s3Transfer.delegate = self
        
        // get token from preferences
        if preferences.value(forKey: "tokenKey") == nil {
            //  Doesn't exist
        } else {
            self.token = preferences.value(forKey: "tokenKey") as! String
        }
        
        // get token from preferences
        if preferences.value(forKey: "username") == nil {
            //  Doesn't exist
        } else {
            self.usernameString = preferences.value(forKey: "username") as! String
        }
        
        
        getPosts()
        // Do any additional setup after loading the view.
    }

}

