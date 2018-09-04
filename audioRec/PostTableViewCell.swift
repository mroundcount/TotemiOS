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

    @IBOutlet weak var usernameLabel: UILabel!
    
    
    @IBOutlet weak var datePostedLabel: UILabel!
    
    var postID: Int?

    override func awakeFromNib() {
        super.awakeFromNib()


    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
