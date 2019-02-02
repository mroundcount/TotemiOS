//
//  FeedViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 7/31/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit
import AWSS3
import AVFoundation

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DonePlayingDelegate, CustomCellUpdater {
    
    @IBOutlet weak var feedNavBtn: UIBarButtonItem!
    @IBOutlet weak var recorderNavBtn: UIBarButtonItem!
    @IBOutlet weak var profileNavBtn: UIBarButtonItem!

    @IBOutlet weak var sortBtn: UIBarButtonItem!
    
    
    @IBOutlet weak var slider: UISlider!
    
    var activeTags : NSMutableArray = []
    
    @IBAction func sortBtn(_ sender: Any) {

        sortOpt.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = false
                self.view.layoutIfNeeded()
            })
        } 
    }
    
    @IBOutlet var sortOpt: [UIButton]!
    
    @IBAction func OptTapped(_ sender: UIButton) {
        
        if(sender.tag == 0){
            // most popular button
            print("most pop")   
          
            sortOpt.forEach { (button) in
                UIView.animate(withDuration: 0.3, animations: {
                    button.isHidden = true
                    self.view.layoutIfNeeded()
                })
            }
            updateTableView()
            let sortedPosts = posts.sorted(by: {$0.likes! > $1.likes!})

            self.posts = []
            for (index, post) in sortedPosts.enumerated() {
                print(sortedPosts[index].description)
                print(sortedPosts[index].likes)
                self.posts.append(sortedPosts[index])
            }
            for post in posts {
                print(post.description)
            }
            print(likedPosts)
            tableView.reloadData()
        } else if (sender.tag == 1) {
            // newest button
            print("newest")
            self.posts = []
            updateTableView()
          sortOpt.forEach { (button) in
                UIView.animate(withDuration: 0.3, animations: {
                    button.isHidden = true
                    self.view.layoutIfNeeded()
                })
            }
        } else if (sender.tag == 2) {
            print("cancel")
            sortOpt.forEach { (button) in
                UIView.animate(withDuration: 0.3, animations: {
                    button.isHidden = true
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    

    @IBAction func recorderNavBtn(_ sender: UIBarButtonItem) {
        print("recordd")
        s3Transfer.stopAudio()
        self.performSegue(withIdentifier: "feedToRecorder", sender: nil)
        
    }
    @IBAction func profileNavBtn(_ sender: UIBarButtonItem) {
        print("profile")
        s3Transfer.stopAudio()
        self.performSegue(withIdentifier: "feedToProfile", sender: nil)
    }
    
    var postCell: PostTableViewCell!
    let s3Transfer = S3TransferUtility()
    var token = ""
    var usernameString = ""
    let preferences = UserDefaults.standard
    var audioPlayer: AVAudioPlayer!
    var selectedIndex : NSInteger! = -1
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    var likedPosts : NSMutableArray = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts : [Post] = []
    
    
    //Look Luke
    //this function will allow you to scroll through the audio using the slider
    @IBAction func changeAudioTime(_ sender: Any) {
        
        if let player = s3Transfer.audioPlayer {
            player.stop()
            player.currentTime = TimeInterval(slider.value)
            //after the time is changed we want it to start playing again
            player.prepareToPlay()
            player.play()
        }
    }
    
    //Look Luke
    //changing the value of the slider as you are going though the audio
    @objc func updateSlider() {
        
        slider.value = Float(s3Transfer.getCurrentTime())
        
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-dd-YYYY"
            let date = NSDate(timeIntervalSince1970: TimeInterval(timeCreated))
            let finalDate = dateFormatter.string(from: date as Date)

            cell = tableView.dequeueReusableCell(withIdentifier: "feedTableViewCell") as? PostTableViewCell
            cell.postDescription.text = description
            cell.usernameLabel.text = username
            cell.datePostedLabel.text = finalDate
            cell.postID = postID
            cell.likes = likes + 1
            print("likefdasfsddds: \(likes + 1)")
            cell.countLabel.text = "\(likes + 1)"
            cell.token = self.token
            
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
        
        return cell
    }
    
    
    func updateTableView() {
        getPosts()
        
        tableView.reloadData()
        
        print("updating tblviewcell")
    }

    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        postCell = tableView.cellForRow(at: indexPath) as! PostTableViewCell
        
        if indexPath.row == selectedIndex{
            selectedIndex = -1
        }else{
            selectedIndex = indexPath.row
        }
        //may move
        tableView.reloadData()

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
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedIndex
        {
            return 300
        }else{
            return 125
        }
    }



   


    func downloadAudioFromS3(postID: Int) {
        s3Transfer.downloadData(postID: postID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedNavBtn.isEnabled = false
        sortBtn.title = "Sort"
        
        let fontSize:CGFloat = 25;
        let font:UIFont = UIFont.boldSystemFont(ofSize: fontSize);
        let attributes:[NSAttributedStringKey : Any] = [NSAttributedStringKey.font: font];
        sortBtn.setTitleTextAttributes(attributes, for: UIControlState.normal);

        
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
        
        getPosts()
        
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
    
    func donePlayingAudio(){
        postCell.contentView.backgroundColor = UIColor.clear
    }
    
    func gotAudioLength() {
        
        //The value of the slider needs to be set to the duration of the audio to
        //divy up the sliding motion
        slider.maximumValue = Float(s3Transfer.getLengthOfAudio())
        print("duration!")
        print(s3Transfer.getLengthOfAudio())
        //creating the timer for the slider... it updates every 0.1 seconds
        var sliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
    }
}



