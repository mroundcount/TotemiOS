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
    
    //Timer labels
    @IBOutlet weak var labelMinute: UILabel!
    @IBOutlet weak var labelSecond: UILabel!
    @IBOutlet weak var labelMillisecond: UILabel!
    
    //Timer variables
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var elapsed: Double = 0
    var status: Bool = false
    
    @IBOutlet weak var myTableView: UITableView!
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords: Int = 0
    
    @IBOutlet weak var quote: UILabel!
    @IBOutlet weak var descriptionTxt: UITextView!
    
    
    @IBOutlet weak var ButtonLabel: UIButton!
    
    @IBOutlet weak var pause: UIButton!
    @IBAction func pause(_ sender: Any) {
        //Check if we have an active recorder
        if (pause.titleLabel?.text == "Pause") {
            //Pause the recording
            audioRecorder.pause()
            //stop timer
            stop()
            //change the button label
            pause.setTitle("Resume", for: .normal)
        } else {
            //resume the recording
            audioRecorder.record()
            //restart timer
            start()
            //myTableView.reloadData()
            pause.setTitle("Pause", for: .normal)
        }
    }
    
    
    @IBAction func record(_ sender: Any) {
        //setting the timer
        // Invalidate timer
        timer?.invalidate()
        
        // Reset timer variables
        startTime = 0
        time = 0
        elapsed = 0
        status = false
        
        // Reset all three labels to 00
        let strReset = String("00")
        labelMinute.text = strReset
        labelSecond.text = strReset
        labelMillisecond.text = strReset
        
        
        
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
                
                //start the timer
                start()
                
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
            
            //stop the timer
            stop()
            
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
    
    //Reconnect this button
    @IBOutlet weak var publish: UIButton!
    @IBAction func publish(_ sender: Any) {
        //scrap this and move it back to the record button        
        myTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        descriptionTxt.layer.borderWidth = 1
        descriptionTxt.layer.borderColor = borderColor.cgColor
        descriptionTxt.layer.cornerRadius = 5.0
        
        
        // quote.text = audioRecModel.randomQuote(self: number)
        
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
    
    
    
    
    
    //Timer functions
    func start() {
        startTime = Date().timeIntervalSinceReferenceDate - elapsed
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        // Set Start/Stop button to true
        status = true
    }
    
    func stop() {
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        timer?.invalidate()
        // Set Start/Stop button to false
        status = false
    }
    
    @objc func updateCounter() {
        // Calculate total time since timer started in seconds
        time = Date().timeIntervalSinceReferenceDate - startTime
        
        // Calculate minutes
        let minutes = UInt8(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        
        // Calculate seconds
        let seconds = UInt8(time)
        time -= TimeInterval(seconds)
        
        // Calculate milliseconds
        let milliseconds = UInt8(time * 100)
        
        // Format time vars with leading zero
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strMilliseconds = String(format: "%02d", milliseconds)
        
        // Add time vars to relevant labels
        labelMinute.text = strMinutes
        labelSecond.text = strSeconds
        labelMillisecond.text = strMilliseconds
    }
    
}

