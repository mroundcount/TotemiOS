//
//  S3TransferUtilityPhoto.swift
//  audioRec
//
//  Created by Michael Roundcount on 3/31/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3

class S3TransferUtilityPhoto: NSObject {
    
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
            print("completed download of image")
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
