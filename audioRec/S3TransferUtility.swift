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


class S3TransferUtility {
    
    var audioPlayer: AVAudioPlayer!
    
    init () {
        
    }
    
    func uploadData(data : Data) {
        
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
                                   key: "testing.m4a",
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
    
    func downloadData() {
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            // Do something e.g. Update a progress bar.
        })
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (task, URL, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed downloads, `error` contains the error object.
                
                print("completed download of file")
                
                do{
                    //initialize the audio player
                    self.audioPlayer = try AVAudioPlayer(data: data!)
                    self.audioPlayer.play()
                }
                catch{
                    print("bummer")
                }

            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(
            fromBucket: "roundcountaudiotest",
            key: "testing.m4a",
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
}
