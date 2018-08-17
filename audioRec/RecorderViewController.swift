//
//  RecorderViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 8/16/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController, AVAudioRecorderDelegate {
    
    let reference = recorder()
    //let timeReference = timer()
    
    @IBOutlet weak var recordingImage: UIImageView!
    
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var pause: UIButton!
    @IBOutlet weak var finished: UIButton!
    @IBOutlet weak var publishBtn: UIButton!
    
    @IBOutlet weak var defaultTxt: UILabel!
    @IBOutlet weak var timerMessage: UILabel!
    @IBOutlet weak var descriptionTxt: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pause.isHidden = true
        finished.isHidden = true
        descriptionTxt.isHidden = true
        publishBtn.isHidden = true
        
        //Timer message debate
        timerMessage.isHidden = true
        
        defaultTxt.text = reference.openingTxt()
        
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
        //asking the user for permission
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
    }
    
    @IBAction func recordBtn(_ sender: UIButton) {
    
        if audioRecorder == nil{
            
            let filename = getDirectory().appendingPathComponent("myrecorder.m4a")
            
            //Defining the format, sample rate, number of channels, and the quality
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start Audio Recodring
            do {
                //pass in the URL and the settings defined above
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                pause.isHidden = false
                finished.isHidden = false
                recordBtn.isHidden = true
                defaultTxt.isHidden = true
                publishBtn.isHidden = true
                
                //rerecord settings
                pause.setTitle("Pause", for: .normal)
                finished.setTitle("Finished", for: .normal)
                recordingImage.isHidden = false
                descriptionTxt.isHidden = true
                
                //timeReference.start()
                                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RecorderViewController.action), userInfo: nil, repeats: true)
                
                recordingImage.loadGif(name: "recording")
            }
            catch {
                displayALert(title: "Oh my.....", message: "Recording Failed")
            }
        }
    }
    
    
    @IBAction func pause(_ sender: UIButton) {
    if (finished.titleLabel?.text == "Finished") {
            if (pause.titleLabel?.text == "Pause") {
                //When recording is paused
                recordingImage.isHidden = true
                
                let blueColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255/255.0, alpha: 1.0)
                view.backgroundColor = blueColor
                
                audioRecorder.pause()
                
                pause.setTitle("Resume", for: .normal)
            } else {
                //When recording is active
                pause.setTitle("Pause", for: .normal)
                recordingImage.loadGif(name: "recording")
                recordingImage.isHidden = false
                
                audioRecorder.record()
            }
        } else {
            if (pause.titleLabel?.text == "Pause") {
                audioPlayer.pause()
                pause.setTitle("Resume", for: .normal)
            } else {
                pause.setTitle("Pause", for: .normal)
                audioPlayer.play()
            }
        }
    }
    
    
    @IBAction func finished(_ sender: UIButton) {
    if (finished.titleLabel?.text == "Finished") {
            //When clicked
            pause.setTitle("Pause", for: .normal)
            recordingImage.isHidden = true
            descriptionTxt.isHidden = false
            publishBtn.isHidden = false
            defaultTxt.isHidden = false
            defaultTxt.text = "Play it back, hey if ya fucked up click anywhere to record again"
            
            //view.backgroundColor = UIColor.darkGray
            let greenColor = UIColor(red: 10/255.0, green: 156/255.0, blue: 54/255.0, alpha: 1.0)
            view.backgroundColor = greenColor
            
            recordBtn.isHidden = false
            
            //stop the audio recording
            audioRecorder.stop()
            audioRecorder = nil
            
            finished.setTitle("Playback", for: .normal)
        } else {
            
            let filename = getDirectory().appendingPathComponent("myrecorder.m4a")
            do{
                //initialize the audio player
                audioPlayer = try AVAudioPlayer(contentsOf: filename)
                audioPlayer.play()
            }
            catch{
                displayALert(title: "Oh no.....", message: "Playback Failed")
            }
        }
    }
    
    @IBAction func publishBtn(_ sender: UIButton) {
        
    }
    
    
    
    
    
    
    
    
    var time = 0
    var timer = Timer()
    
    @objc func action()
    {
        time += 1
        if time >= 0 && time <= 3 {
            timerMessage.text = "Go ahead and begin"
        } else if time >= 6 && time <= 8 {
            timerMessage.text = "You'll do great"
        } else if time >= 15 && time <= 18 {
            timerMessage.text = "Seriously cowboy, wrap it the fuck up"
        } else {
            timerMessage.text = " "
        }
    }
    
    
    
    //Recording functions
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    //Function that get's path to direcotry
    func getDirectory() -> URL{
        //Searching for all the URLS in the documents directory and taking the first one and returning the URL to the document directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //defining our constant.
        //We will use the first URL path
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //Function that displays an alert
    func displayALert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
