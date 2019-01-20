//
//  PostTableViewCell.swift
//  audioRec
//
//  Created by Michael Roundcount on 8/2/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit
import AVFoundation

protocol CustomCellUpdater : class {
    
    func updateTableView()
    
}

class PostTableViewCell: UITableViewCell {
    
    var player: AVAudioPlayer?
    weak var delegate: CustomCellUpdater?
    
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var datePostedLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    var postID: Int?
    var likes: Int?
    var token: String?
    
    @IBAction func likeBtn(_ sender: Any) {
        
        likeBtn.isEnabled = false
        likeBtn.setTitle("Liked", for: .normal)
        likeBtn.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        
        // post new likes
        let variable = "{\"postID\": \(postID!)}"
        
        print(variable)
        
        let dbManager = DatabaseManager()
        
        // TODO: update the dbManager thing with a post that uses a token
        dbManager.likePost(token: token!, data: variable)
    
        delegate?.updateTableView()

        likes = likes! + 1
        countLabel.text = "\(likes!)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        

    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            // Update the cell
            if let label = countLabel {
                label.text = "\(likes!)"
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
