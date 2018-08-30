//
//  FeedViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 7/31/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var token = ""
    var usernameString = ""
    
    
    @IBOutlet weak var privateFeedBtn: UIButton!
    @IBOutlet weak var recorderBtn: UIButton!
    @IBOutlet weak var feedBtn: UIButton!
    
    
    
    @IBAction func privateFeedBtn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "tempProfileFeed", sender: nil)   
    }
    
    @IBAction func recorderBtn(_ sender: UIButton) {
    self.performSegue(withIdentifier: "toRecorder", sender: nil)
    }

    

    
    let preferences = UserDefaults.standard
    
    
    
    
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
        
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
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
        
        
        //big
        
        self.posts = dbManager.getPostsForFeed(token: self.token, data: dataString) as NSArray
        
        print(self.posts!)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
