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

class PostTableViewCell: UITableViewCell, DonePlayingDelegate {
    
    func donePlayingAudio() {
        print("done")
    }
    
    
    var player: AVAudioPlayer?
    weak var delegate: CustomCellUpdater?
    
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var datePostedLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
   
    @IBOutlet weak var slider: UISlider!
    
    
    var postID: Int?
    var likes: Int?
    var token: String?
    
    let s3Transfer = S3TransferUtility()
    //s3Transfer.delegate = self
    
    
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
    
    
    func gotAudioLength() {
        
        //The value of the slider needs to be set to the duration of the audio to
        //divy up the sliding motion
        slider.maximumValue = Float(s3Transfer.getLengthOfAudio())
        print("duration!")
        print(s3Transfer.getLengthOfAudio())
        //creating the timer for the slider... it updates every 0.1 seconds
        var sliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateSlider() {
        
        slider.value = Float(s3Transfer.getCurrentTime())
        
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
        
        if let player = s3Transfer.audioPlayer {
            player.stop()
            player.currentTime = TimeInterval(slider.value)
            //after the time is changed we want it to start playing again
            player.prepareToPlay()
            player.play()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        s3Transfer.delegate = self
    }

}
