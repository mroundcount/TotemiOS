//
//  S3TransferUtility.swift
//  audioRec
//
//  Created by Lucas Rydberg on 8/19/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3
import AVFoundation


class S3TransferUtility: NSObject, AVAudioPlayerDelegate {
    
    var delegate : DonePlayingDelegate!
    var audioPlayer: AVAudioPlayer!
    override init () {
        
    }
    
    func uploadData(data : Data, postID: Int) {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
            })
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed uploads, `error` contains the error object.
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(data,
                                   bucket: "roundcountaudiotest",
                                   key: "\(postID).m4a",
                                   contentType: "m4a",
                                   expression: expression,
                                   completionHandler: completionHandler).continueWith {
                                    (task) -> AnyObject! in
                                    if let error = task.error {
                                        print("Error: \(error.localizedDescription)")
                                    }
                                    
                                    if let _ = task.result {
                                        // Do something with uploadTask.
                                    }
                                    return nil;
        }
    }
    
    func downloadData(postID: Int) {
        
        print("pstid: \(postID)")
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            // Do something e.g. Update a progress bar.
        })
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (task, URL, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                print("completed download of file")
                
                do{
                    //initialize the audio player
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    }
                    catch {
                        // report for an error
                    }
                    self.audioPlayer = try AVAudioPlayer(data: data!)
                    self.audioPlayer.delegate = self
                    self.audioPlayer.play()
                    print("playing")
                    self.gotAudioLength()
                }
                catch{
                    print("bummer")
                }
                
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
            transferUtility.downloadData(
                fromBucket: "roundcountaudiotest",
                key: "\(postID).m4a",
                expression: expression,
                completionHandler: completionHandler
                ).continueWith {
                    (task) -> AnyObject! in if let error = task.error {
                        print("Error: \(error.localizedDescription)")
                        
                    }
                    
                    if let _ = task.result {
                        // Do something with downloadTask.
                    }
                    return nil;
            }
    }
    
    //changed self.delegate!.donePlayingAudio()
    func donePlayingAudio() {
        self.delegate.donePlayingAudio()
    }
    
    func gotAudioLength() {
        print("s3 transfer delegate got audio length")
        self.delegate.gotAudioLength()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        donePlayingAudio()
    }
    
    func stopAudio(){
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                donePlayingAudio()
            }
        }
    }
    
    func getLengthOfAudio() -> TimeInterval {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                return audioPlayer.duration
            }
        }
        return 0.0
    }
    
    func getCurrentTime() -> TimeInterval {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                return audioPlayer.currentTime
            }
        }
        return 0.0
    }
    
    
    func uploadProfilePic(data : Data, picID: String) {
        
        if let imageData = UIImage(data:data,scale:1.0)!.jpeg(.lowest) {
            print(imageData.count)
            print(data.count) 
            
            let expression = AWSS3TransferUtilityUploadExpression()
            expression.progressBlock = {(task, progress) in
                DispatchQueue.main.async(execute: {
                    // Do something e.g. Update a progress bar.
                })
            }
            
            var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
            completionHandler = { (task, error) -> Void in
                DispatchQueue.main.async(execute: {
                    // Do something e.g. Alert a user for transfer completion.
                    // On failed uploads, `error` contains the error object.
                })
            }
            
            let transferUtility = AWSS3TransferUtility.default()
            
            transferUtility.uploadData(data,
                                       bucket: "totemprofilepicture",
                                       key: "\(picID).jpg",
                contentType: "jpg",
                expression: expression,
                completionHandler: completionHandler).continueWith {
                    (task) -> AnyObject! in
                    if let error = task.error {
                        print("Error: \(error.localizedDescription)")
                    }
                    
                    if let _ = task.result {
                        // Do something with uploadTask.
                    }
                    return nil;
            }
        }
    }
    
    func downloadProfilePicture(picID: String) -> UIImage? {
        
        print("pstid: \(picID)")
        var image : UIImage?
        let group = DispatchGroup()
        group.enter()
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            // Do something e.g. Update a progress bar.
        })
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (task, URL, data, error) -> Void in
            print("completed download of file")
            image = UIImage(data: data!)
            group.leave()
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(
            fromBucket: "totemprofilepicture",
            key: "\(picID).jpg",
            expression: expression,
            completionHandler: completionHandler
            ).continueWith {
                (task) -> AnyObject! in if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                }

                if let _ = task.result {
                    // Do something with downloadTask.

                }
            return nil;
        }
        
        group.wait()
        print("downloading profile pic")
        return image
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
