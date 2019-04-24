//
//  PublishTableViewCell.swift
//  audioRec
//
//  Created by Michael Roundcount on 3/10/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit

class PublishTableViewCell: UITableViewCell {
    
    
    var token: String?
    var s3Transfer = S3TransferUtility()
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        //        profilePicture.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
