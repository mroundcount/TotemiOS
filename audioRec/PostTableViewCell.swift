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
    @IBOutlet weak var testLabel: UILabel!
    
    
    var postID: Int?
    var likes: Int?
    var token: String?
    
    @IBAction func likeBtn(_ sender: Any) {
        
        DispatchQueue.main.async
        {
            self.likeBtn.isEnabled = false
            self.likeBtn.setTitle("Liked", for: .normal)
            self.likeBtn.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
            self.likes = self.likes! + 1
            self.countLabel.text = "\(self.likes!)"
        }
        
        
        // post new likes
        let variable = "{\"postID\": \(postID!)}"
        
        print(variable)
        
        let dbManager = DatabaseManager()
        
        // TODO: update the dbManager thing with a post that uses a token
        dbManager.likePost(token: token!, data: variable)
    
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        

    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            // Update the cell
//            if let label = countLabel {
//                label.text = "\(likes!)"
//            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
