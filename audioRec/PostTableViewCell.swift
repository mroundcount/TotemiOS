//
//  PostTableViewCell.swift
//  audioRec
//
//  Created by Michael Roundcount on 8/2/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var datePosted: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //let url = URL(string: "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com/apiToken")
        parseURL(theURL: "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com/api/getPostsForUser")
        
    }
    
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
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
