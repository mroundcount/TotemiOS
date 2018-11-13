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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DonePlayingDelegate {
    
    @IBOutlet weak var feedNavBtn: UIBarButtonItem!
    @IBOutlet weak var recorderNavBtn: UIBarButtonItem!
    @IBOutlet weak var profileNavBtn: UIBarButtonItem!
    
    var postCell: PostTableViewCell!
    
    let s3Transfer = S3TransferUtility()
    
    @IBAction func recorderNavBtn(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "feedToRecorder", sender: nil)
    }
    @IBAction func profileNavBtn(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "feedToProfile", sender: nil)
    }
    
    var token = ""
    var usernameString = ""
    
    let preferences = UserDefaults.standard
    
    var audioPlayer: AVAudioPlayer!
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts : NSArray?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (posts?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("print1")
        
        var cell : PostTableViewCell!
        
        
        if((posts?.count)! > 0){
            
            let post = posts?[indexPath.row] as? [String: Any]
            
            let description = post!["description"] as? String
            
            let postID = post!["post_i_d"] as? Int
            
            print(postID)
            
            let username = post!["username"] as? String
            
            let timeCreated = post!["time_created"] as? Int
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-dd-YYYY"
            let date = NSDate(timeIntervalSince1970: TimeInterval(timeCreated!))
            let finalDate = dateFormatter.string(from: date as Date)
            
            print("DESCRIPTION:::   \(description!)")
            
            cell = tableView.dequeueReusableCell(withIdentifier: "feedTableViewCell") as! PostTableViewCell
            
            cell.postDescription.text = description!
            cell.usernameLabel.text = "By: \(username!)"
            cell.datePostedLabel.text = finalDate
            cell.postID = postID!
            
            print("print2")
            
        }

        cell.sizeToFit()
        
        
        //Cell Styling
        cell.contentView.backgroundColor = UIColor.clear
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: self.view.frame.size.height))
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)
        
        print("print3")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        postCell = tableView.cellForRow(at: indexPath) as! PostTableViewCell
        let postID = postCell.postID!
        downloadAudioFromS3(postID: postID)
        
        // Do something e.g. Alert a user for transfer completion.
        // On failed downloads, `error` contains the error object.

        //Roundcount testing
        postCell.contentView.backgroundColor = UIColor.green

    }


    func downloadAudioFromS3(postID: Int) {
        s3Transfer.downloadData(postID: postID)
        print("print5")
    }
    

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished playing from feed view controller")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedNavBtn.isEnabled = false
        
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
        let dbManager = DatabaseManager()
        let dataString = "{\"Username\":[{\"username\":\"" + self.usernameString + "\"}]}"
        
        print(dataString)
        
        print("----------------------------")

        self.posts = dbManager.getPostsForFeed(token: self.token, data: dataString) as NSArray
        self.posts = self.posts!.reversed() as NSArray
        
        print(self.posts!)
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
