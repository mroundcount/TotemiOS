//
//  OtherProfileViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 4/23/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AVFoundation

class OtherProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DonePlayingDelegate {
    
    //removed for testing, but add back the update cell delegate

    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var followBtn: UIButton!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        profilePicture.clipsToBounds = true
        
        let profile = preferences.value(forKey: "username") as! String
        //change to name of the person who's profile this is
        //usernameProfile.title = "\(profile)'s Profile"
        
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
    
    @IBAction func followBtn(_ sender: UIButton) {
        print("Follow")
    }
    
    
    func updateTableView() {
        getPosts()
        
        tableView.reloadData()
        
        print("updating tblviewcell")
    }
    
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
        
        //cell.delegate = self
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
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        s3Transfer.stopAudio()
    }
    
    func donePlayingAudio(){
        print("Done")
        postCell.contentView.backgroundColor = UIColor.clear
    }

}
