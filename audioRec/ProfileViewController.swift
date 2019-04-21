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

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DonePlayingDelegate, CustomCellUpdater {
    
    func updateTableView() {
        getPosts()
        
        tableView.reloadData()
        
        print("updating tblviewcell")
    }
    
    @IBOutlet weak var profileHeader: UINavigationBar!
    @IBOutlet weak var usernameProfile: UINavigationItem!
    
    @IBOutlet weak var profilePicture: UIImageView!
        
    @IBOutlet weak var slider: UISlider!
    
    

    let dbManager = DatabaseManager()
    var postCell: PostTableViewCell!
    let s3Transfer = S3TransferUtility()
    var indexOfSelectedCell = -1
    
    var token = ""
    var usernameString = ""
    let preferences = UserDefaults.standard
    var userID : Int = 0
    let profile = ""
    var selectedIndexPath : IndexPath!
    
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
            //let username = post!["username"] as? String
            let postID = post!["post_i_d"] as? Int
            let likes = post!["likes"] as? Int
            //let likes = post.likes!
        
            let timeCreated = post!["time_created"] as? Int
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-dd-YYYY"
            let date = NSDate(timeIntervalSince1970: TimeInterval(timeCreated!))
            let finalDate = dateFormatter.string(from: date as Date)
            
            let duration = post!["duration"] as? Int
            let durationMin = (duration!/60)
            let durationSec = (duration!%60)
            
            print("DESCRIPTION:::   \(description!)")
            
            cell = tableView.dequeueReusableCell(withIdentifier: "profileTableViewCell") as! PostTableViewCell
            
            cell.postDescription.text = description!
            cell.datePostedLabel.text = finalDate
            cell.postID = postID
            //cell.likes = likes!
            cell.likes = likes! + 1
            cell.countLabel.text = "Likes: \(likes! + 1)"
            cell.durationLabel.text = "\(durationMin):\(durationSec)"

        }
        
        cell.sizeToFit()

        //Cell Styling
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.delegate = self
        cell.audioLengthDelegate = self.audioLengthDelegate
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexOfSelectedCell == indexPath.row)
        {
            return 200
        } else {
            return 150
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexOfSelectedCell == indexPath.row) {
            indexOfSelectedCell = -1
            selectedIndexPath = nil
        } else {
            indexOfSelectedCell = indexPath.row
            selectedIndexPath = indexPath
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
            //postCell.contentView.backgroundColor = UIColor.green
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
    
    var audioLengthDelegate : AudioLengthForCellDelegate!
    
    func gotAudioLength() {
        print("got audio in feed control")
        print("got length for index path : \(selectedIndexPath)")
        var newPostCell = tableView.cellForRow(at: selectedIndexPath) as! PostTableViewCell
        newPostCell.selectedThisCell(length: s3Transfer.getLengthOfAudio(), s3trans: s3Transfer)
        
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
    
        if let player = s3Transfer.audioPlayer {
        player.stop()
        player.currentTime = TimeInterval(slider.value)
        //after the time is changed we want it to start playing again
        player.prepareToPlay()
        player.play()
        }
    }

    @objc func updateSlider() {
        slider.value = Float(s3Transfer.getCurrentTime())
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
    
    @IBAction func profileMenuBtn(_ sender: UIBarButtonItem) {
        profileMenu.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = false
                self.view.layoutIfNeeded()
            })
        }
    }

    //@IBOutlet var sortOpt: [UIButton]!
    @IBOutlet var profileMenu: [UIButton]!
    

    @IBAction func OptTapped(_ sender: UIButton) {
        if(sender.tag == 0){
            print("tapped 1")
            self.performSegue(withIdentifier: "profileEditor", sender: nil)
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
  

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        s3Transfer.stopAudio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        profilePicture.clipsToBounds = true
        
        let profile = preferences.value(forKey: "username") as! String
        usernameProfile.title = "\(profile)'s Profile"
                
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
        let image = s3Transfer.downloadProfilePicture(picID: usernameString)
        profilePicture.image = image
        
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

}


