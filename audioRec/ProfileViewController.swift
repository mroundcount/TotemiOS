//
//  ProfileViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 7/30/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AVFoundation

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DonePlayingDelegate {
    
    
    @IBOutlet weak var feedNavBtn: UIToolbar!
    @IBOutlet weak var recorderNavBtn: UIBarButtonItem!
    @IBOutlet weak var profileNavBtn: UIBarButtonItem!
    
    @IBOutlet weak var profileHeader: UINavigationBar!
    @IBOutlet weak var usernameProfile: UINavigationItem!
    @IBOutlet weak var profileMenuBtn: UIBarButtonItem!
    

    let dbManager = DatabaseManager()
    var postCell: PostTableViewCell!
    let s3Transfer = S3TransferUtility()
    var indexOfSelectedCell = -1
    
    @IBAction func feedNavBtn(_ sender: UIBarButtonItem) {
        s3Transfer.stopAudio()
        self.performSegue(withIdentifier: "profileToFeed", sender: nil)
    }
    
    @IBAction func recorderNavBtn(_ sender: Any) {
        s3Transfer.stopAudio()
        self.performSegue(withIdentifier: "profileToRecorder", sender: nil)
    }
    
    @IBAction func profileMenuBtn(_ sender: UIBarButtonItem) {
        profileMenu.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = false
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    var token = ""
    var usernameString = ""
    let preferences = UserDefaults.standard
    var userID : Int = 0
    let profile = ""
    
    var audioPlayer: AVAudioPlayer!
    
    var activeTags : NSMutableArray = []
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts : NSArray?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (posts?.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : PostTableViewCell!
    
        if((posts?.count)! > 0){
            
            let post = posts?[indexPath.row] as? [String: Any]
            
            let description = post!["description"] as? String
            
            let username = post!["username"] as? String

            let postID = post!["post_i_d"] as? Int
            let likes = post!["likes"] as? Int

            let timeCreated = post!["time_created"] as? Int
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-dd-YYYY"
            let date = NSDate(timeIntervalSince1970: TimeInterval(timeCreated!))
            let finalDate = dateFormatter.string(from: date as Date)

            print("DESCRIPTION:::   \(description!)")
            
            cell = tableView.dequeueReusableCell(withIdentifier: "profileTableViewCell") as! PostTableViewCell
            
            cell.postDescription.text = description!
            cell.usernameLabel.text = "By: \(username!)"
            cell.datePostedLabel.text = finalDate
            cell.postID = postID
            cell.likes = likes!
        }
        
        cell.sizeToFit()
        
        if(indexOfSelectedCell == indexPath.row){
            cell.contentView.backgroundColor = UIColor.green
        } else {
            //Cell Styling
            cell.contentView.backgroundColor = UIColor.clear
            
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: self.view.frame.size.height))
            
            whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.layer.cornerRadius = 2.0
            //whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
            //whiteRoundedView.layer.shadowOpacity = 0.2
            
            cell.contentView.addSubview(whiteRoundedView)
            cell.contentView.sendSubview(toBack: whiteRoundedView)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexOfSelectedCell == indexPath.row)
        {
            return 250
        } else {
            return 153
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexOfSelectedCell == indexPath.row) {
            indexOfSelectedCell = -1
        } else {
            indexOfSelectedCell = indexPath.row
        }
        
        postCell = tableView.cellForRow(at: indexPath) as! PostTableViewCell
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
        
        if(activeTags.contains(indexPath.row)){
            print("is active cell, stopping audio")
            s3Transfer.stopAudio()
            activeTags.remove(indexPath.row)
        }
        else{
            let postID = postCell.postID!
            
            if audioPlayer != nil {
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                }
            }
            
            downloadAudioFromS3(postID: postID)
            postCell.contentView.backgroundColor = UIColor.green
            activeTags.add(indexPath.row)
        }
        
        tableView.reloadData()
    }

    
    func getPosts(){
        
        let dataString = "{\"Username\":[{\"username\":\"" + self.usernameString + "\"}]}"
        
        self.posts = []
        print("-------------- getting posts --------------")
        self.posts = dbManager.getPostsForUser(token: self.token, data: dataString) as NSArray
        self.posts = self.posts!.reversed() as NSArray
        
        print(self.posts!)
    }


    
    func downloadAudioFromS3(postID: Int) {
        s3Transfer.downloadData(postID: postID)
    }
  
    //Deleting the Post
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished playing from feed view controller")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        //copy this and add the variables in the return with "delete
        let delete = UITableViewRowAction(style: .normal, title: "      Delete     ") { action, index in
            // execute the delete
            
            let cell = tableView.cellForRow(at: editActionsForRowAt) as? PostTableViewCell
            let postID = cell?.postID!
            print("delete button tapped. going to delete post with id: \(postID)")
            let postData = "{\"postID\":\(postID!)}"
            print(postData)
            self.dbManager.deletePost(token: self.token, data: postData)
            self.getPosts()
            tableView.reloadData()
        }
        delete.backgroundColor = .red
        
        return [delete]
    }
    

    
   //@IBOutlet var sortOpt: [UIButton]!
    @IBAction func profileMenuBtn(_ sender: UIButton) {
    }
    
    @IBAction func OptTapped(_ sender: UIButton) {
        
        if(sender.tag == 0){
            print("tapped 1")
        }
            
        else if (sender.tag == 1) {
            s3Transfer.stopAudio()
            self.preferences.removeObject(forKey:"tokenKey")
            self.performSegue(withIdentifier: "logout", sender: nil)
            
        } else if (sender.tag == 2) {
            print("cancel")
            profileMenu.forEach { (button) in
                UIView.animate(withDuration: 0.3, animations: {
                    button.isHidden = true
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
  

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profile = preferences.value(forKey: "username") as! String
        usernameProfile.title = "\(profile)'s Profile"
        
        profileNavBtn.isEnabled = false
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        s3Transfer.delegate = self
        
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
        print(usernameString)
        
        preferences.setValue(self.userID, forKey: "userid")
        preferences.synchronize()
        
        getPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func donePlayingAudio(){
        print("Done")
        postCell.contentView.backgroundColor = UIColor.clear
    }
    
    func gotAudioLength() {
        print("got audio len")
    }
}


