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
                    self.audioPlayer = try AVAudioPlayer(data: data!)
                    self.audioPlayer.delegate = self
                    self.audioPlayer.play()
                    print("playing")
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        donePlayingAudio()
    }
}
