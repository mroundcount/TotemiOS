//
//  ProfileViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 7/30/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
//    struct testPost: Decodable {
//        let description: String
//        let likes: Int
//        let post_i_d: Int
//        let time_created: String
//        let username: String
//    }
    
    
    @IBOutlet weak var username: UILabel!
    
    var token = ""
    var usernameString = ""
    let preferences = UserDefaults.standard
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts : [Any] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        cell.textLabel?.text = posts[indexPath.row] as? String
        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
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
        
        let dbManager = DatabaseManager()
        let dataString = "{\"Username\":[{\"username\":\"" + self.usernameString + "\"}]}"
        
        print("----------------------------")
        self.posts = dbManager.getPostsForUser(token: self.token, data: dataString) as! [Any]
        
        print(self.posts)
        

        
        
        //parseURL(theURL: "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com/api/getPostsForUser")

        
        //Take Two
        /*
        let jsonURLString = "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com/api/getPostsForUser"
        
        let url = URL(string: jsonURLString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            guard let data = data else {return}
        
            let dataAsString = String(data: data, encoding: .utf8)
            print(dataAsString)
            
            do {
                let testPosts = try
                    JSONDecoder().decode([testPost].self, from: data)
                print(testPosts)
            } catch let jsonError {
                print("Error serializing json:", jsonError)
            }
            
        }.resume()
        */
        
    }
    
    
    
    
    
    /*
     
     get the values of thr array first then turn them into a json object
     
     //Roundcount Attempt 1
    func parseURL(theURL:String){
        let url = URL(string: theURL)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print ("didn't work, \(String(describing: error))")
                
                DispatchQueue.main.asyncAfter(deadline: .now() ) {
                    
                }
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    
                    for (key, value) in parsedData {
                        
                        if (key == "description") {
                            print("descriptons is \(value)")
                        }
                        else if (key == "time_created") {
                            print("created on \(value)")
                        }
                        else if (key == "username") {
                            print("creator was \(value)")
                        }
                    }
                    
                    
                } catch let error as NSError {
                    print(error)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() ) {
                        
                    }
                }
            }
        }
    }
 */

    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
