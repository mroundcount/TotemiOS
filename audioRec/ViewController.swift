//
//  ViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 7/16/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords: Int = 0
    
    @IBOutlet weak var ButtonLabel: UIButton!
    
    @IBOutlet weak var pause: UIButton!
    @IBAction func pause(_ sender: Any) {
        //Check if we have an active recorder
        if (pause.titleLabel?.text == "Pause") {
            //Pause the recording
            audioRecorder.pause()
            //change the button label
            pause.setTitle("Resume", for: .normal)
        } else {
            //resume the recording
            audioRecorder.record()
            //myTableView.reloadData()
            pause.setTitle("Pause", for: .normal)
        }
    }
    
    
    @IBAction func record(_ sender: Any) {
        //Check if we have an active recorder
        if audioRecorder == nil{
            
            //this is giving the name to the file. We will need to manipulate this
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            //Defining the format, sample rate, number of channels, and the quality
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start Audio Recodring
            do {
                //pass in the URL and the settings defined above
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                //change the button label
                ButtonLabel.setTitle("Stop Recording", for: .normal)
                pause.isHidden = false
                playBack.isHidden = true
            }
            //if this does not work
            catch {
                displayALert(title: "Oh my.....", message: "Recording Failed")
            }
        }
        else {
            //stop the audio recording
            audioRecorder.stop()
            //refresh the table after ever recording
            myTableView.reloadData()
            audioRecorder = nil
            
            //change the button label
            ButtonLabel.setTitle("Start Recording", for: .normal)
            pause.isHidden = true
            playBack.isHidden = false
            
            //Saving the record number
            UserDefaults.standard.set(numberOfRecords, forKey: "MyNumber")
        }
    }
    
    //playback button
    @IBOutlet weak var playBack: UIButton!
    @IBAction func playBack(_ sender: Any) {
        let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
        do{
            //initialize the audio player
            audioPlayer = try AVAudioPlayer(contentsOf: filename)
            audioPlayer.play()
        }
        catch{
            displayALert(title: "Oh no.....", message: "Playback Failed")
        }
    }
    
    
    @IBOutlet weak var publish: UIButton!
    @IBAction func publish(_ sender: Any) {
        //scrap this and move it back to the record button        
        myTableView.reloadData()
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the buttons
        pause.isHidden = true
        playBack.isHidden = true
        
        // Load records from all previous session (should remove)
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int{
            numberOfRecords = number
        }
        
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
        //asking the user for permission
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
    }
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
    //Setting up table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    //The content of the cell is going to be the number of each recording
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    //Playback recording
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
   
        //actually playing it back
        do{
            //initialize the audio player
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        }
        catch{
            displayALert(title: "Oh no.....", message: "Playback Failed")
        }
    }
}

