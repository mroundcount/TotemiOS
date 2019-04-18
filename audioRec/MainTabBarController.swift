//
//  MainTabBarController.swift
//  audioRec
//
//  Created by Lucas Rydberg on 4/17/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit
import AWSS3
import AVFoundation

class MainTabBarController: UITabBarController, UITabBarControllerDelegate, AVAudioPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    
    let s3Transfer = S3TransferUtility()
    //var delegate : DonePlayingDelegate!
    var audioPlayer: AVAudioPlayer!
    
    

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item")
    }
    
    /*
    func donePlayingAudio() {
        self.delegate.donePlayingAudio()
    }
 */
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        print("Selected view controller")
        
        let index = tabBarController.selectedIndex
        
        switch index {
        case 0:
            // feed
            if audioPlayer != nil {
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                    //donePlayingAudio()
                }
            }
            print("feed selected")
            s3Transfer.stopAudio()
        case 1:
            // record
            if audioPlayer != nil {
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                    //donePlayingAudio()
                }
            }
            print("record selected")
            s3Transfer.stopAudio()
        case 2:
            // private
            if audioPlayer != nil {
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                    //donePlayingAudio()
                }
            }
            print("private selected")
            s3Transfer.stopAudio()
        default:
            print("default")
        }
        
    }

}
