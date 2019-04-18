//
//  UserFeedViewController.swift
//  
//
//  Created by Michael Roundcount on 4/7/19.
//

import UIKit
import AWSS3
import AVFoundation

class UserFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DonePlayingDelegate, CustomCellUpdater {

    let dbManager = DatabaseManager()
    var activeTags : NSMutableArray = []
    var audioLengthDelegate : AudioLengthForCellDelegate!
    var postCell: PostTableViewCell!
    let s3Transfer = S3TransferUtility()
    let s3TransferPhoto = S3TransferUtilityPhoto()
    var token = ""
    var usernameString = ""
    let preferences = UserDefaults.standard
    var audioPlayer: AVAudioPlayer!
    var selectedIndex : NSInteger! = -1
    var selectedIndexPath : IndexPath!
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    var likedPosts : NSMutableArray = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var slider: UISlider!
    
    var posts : [Post] = []

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        getPrivatePosts()
    }
    @IBAction func MenuBtn(_ sender: Any) {
        
        menuOpt.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = false
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBOutlet var menuOpt: [UIButton]!
    
    @IBAction func OptTapped(_ sender: UIButton) {
        
        if(sender.tag == 0){
            print("profile")
            self.performSegue(withIdentifier: "privateToProfile", sender: nil)
            menuOpt.forEach { (button) in
                UIView.animate(withDuration: 0.3, animations: {
                    button.isHidden = true
                    self.view.layoutIfNeeded()
                })
            }
      
        }  else if (sender.tag == 1) {
            print("cancel")
            menuOpt.forEach { (button) in
                UIView.animate(withDuration: 0.3, animations: {
                    button.isHidden = true
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    //look into remvoing this
    func updateTableView() {
        getPrivatePosts()
        tableView.reloadData()
        print("updating tblviewcell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (posts.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : PostTableViewCell!
        
        if((posts.count) > 0){
            let post = posts[indexPath.row]
            let description = post.description!
            let postID = post.postID!
            let likes = post.likes!
            let username = post.username!
            let timeCreated = post.timeCreated!
            let duration = post.duration!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-dd-YYYY"
            let date = NSDate(timeIntervalSince1970: TimeInterval(timeCreated))
            let finalDate = dateFormatter.string(from: date as Date)
            //let image = s3TransferPhoto.downloadProfilePicture(picID: username)
            
            cell = tableView.dequeueReusableCell(withIdentifier: "PrivateFeedTableViewCell") as? PostTableViewCell
            cell.postDescription?.text = description
            cell.usernameLabel.text = username
            cell.datePostedLabel.text = finalDate
            cell.postID = postID
            //+1 on both of these
            cell.likes = likes
            cell.countLabel.text = "\(likes)"
            cell.token = self.token
            let durationMin = (duration/60)
            let durationSec = (duration%60)
            cell.durationLabel.text = "\(durationMin):\(durationSec)"

            //cell.profilePicture!.image = image
            
            if((likedPosts.contains(postID))){
                cell.likeBtn.isEnabled = false
                cell.likeBtn.setTitle("Liked", for: .normal)
                cell.likeBtn.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
            } else {
                cell.likeBtn.isEnabled = true
                cell.likeBtn.setTitle("Like", for: .normal)
                cell.likeBtn.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
            }
        }
        cell.sizeToFit()
        //Cell Styling
        
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.delegate = self
        cell.audioLengthDelegate = self.audioLengthDelegate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        postCell = tableView.cellForRow(at: indexPath) as! PostTableViewCell
        
        if indexPath.row == selectedIndex{
            selectedIndex = -1
            selectedIndexPath = nil
        }else{
            selectedIndex = indexPath.row
            selectedIndexPath = indexPath
        }
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedIndex
        {
            return 200
        }else{
            return 125
        }
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
            self.getPrivatePosts()
            tableView.reloadData()
            
        }
        delete.backgroundColor = .red
        
        return [delete]
    }
    
    func downloadAudioFromS3(postID: Int) {
        s3Transfer.downloadData(postID: postID)
    }
    
    func donePlayingAudio(){
        postCell.contentView.backgroundColor = UIColor.clear
        tableView.reloadData()
    }
    
    func gotAudioLength() {
        print("got audio in feed control")
        print("got length for index path : \(selectedIndexPath)")
        var newPostCell = tableView.cellForRow(at: selectedIndexPath) as! PostTableViewCell
        newPostCell.selectedThisCell(length: s3Transfer.getLengthOfAudio(), s3trans: s3Transfer)
        
    }
    
    func getPrivatePosts(){
        posts = []
        let dbManager = DatabaseManager()
        let dataString = "{\"Username\":[{\"username\":\"" + self.usernameString + "\"}]}"
        
        var postsArray = dbManager.getPrivatePostsForUser(token: self.token, data: dataString) as NSArray
        
        if((postsArray.count) > 0){
            for (index, element) in postsArray.enumerated() {
                let newPost = Post()
                let post = postsArray[index] as? [String: Any]
                let description = post!["description"] as? String
                newPost.description = description!
                let postID = post!["post_i_d"] as? Int
                newPost.postID = postID!
                let likes = post!["likes"] as? Int
                newPost.likes = likes!
                let username = post!["username"] as? String
                newPost.username = username!
                let timeCreated = post!["time_created"] as? Int
                newPost.timeCreated = timeCreated!
                var duration = post!["duration"] as? Int
                newPost.duration = duration!
                
                posts.append(newPost)
            }
        }
        
        self.posts = self.posts.reversed()
        
        print("Posts: \(posts)")
        let array = dbManager.getLikedPosts(token: self.token) as NSArray
        
        for (index, element) in array.enumerated() {
            let post = array[index] as? [String: Any]
            let postID = post!["post_i_d"] as? Int
            likedPosts.add(postID)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

