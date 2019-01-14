//
//  PostTableViewCell.swift
//  audioRec
//
//  Created by Michael Roundcount on 8/2/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit
import AVFoundation

class PostTableViewCell: UITableViewCell {
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var datePostedLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    
    @IBAction func likeBtn(_ sender: Any) {
        likeBtn.setTitle("click", for: .normal)

    }
    
    var postID: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
