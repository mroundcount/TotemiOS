//
//  RecorderViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 8/16/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//
import UIKit
import AVFoundation
import SwiftyJSON

class RecorderViewController: UIViewController, AVAudioRecorderDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Variables
    
    private let recorderRule = recorderCharLimit()
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var recordingImage: UIImageView!
    // MARK: - Buttons

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var finishedBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var publishPrivateBtn: UIButton!
    
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var defaultTxt: UILabel!
    
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var selectionNavigationBar: UINavigationBar!
    
    
    var duration = 0
    
    // user variables
    var userID : Int = 0
    var username : String = ""
    var token : String = ""
    let preferences = UserDefaults.standard
    var variable = JSON([])
    var timeCreated : String?
    var desc : String?
    var audioData : URL?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //phone cannot go into sleep mode while in this view
        UIApplication.shared.isIdleTimerDisabled = true
        
        //dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
        // get token from preferences
        if preferences.value(forKey: "tokenKey") == nil {
            //  Doesn't exist
        } else {
            self.token = preferences.value(forKey: "tokenKey") as! String
        }
        
        // get token from preferences
        if preferences.value(forKey: "username") == nil {
            //  Doesn't exist
        } else {
            self.username = preferences.value(forKey: "username") as! String
        }
        
        descriptionTxt.delegate = self
        
        buttonsOnLoad()
        
        // Note that SO highlighting makes the new selector syntax (#selector()) look
        // like a comment but it isn't one
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view did disappear")
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame!.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 154.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 154.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    /*
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
 */
    
    
    @IBAction func recordBtn(_ sender: UIButton) {
        beginRecording()
    }
    
    
    
    @IBAction func pauseBtn(_ sender: UIButton) {
        if (finishedBtn.titleLabel?.text == "Finished") {
        //if (finishedBtn.titleLabel?.text == "[ ]") {
            if (pauseBtn.titleLabel?.text == "Pause") {
            //if (pauseBtn.titleLabel?.text == "| |") {
                pauseRecorder ()
            } else {
                resumeRecorder ()
            }
        } else {
            if (pauseBtn.titleLabel?.text == "Pause") {
            //if (pauseBtn.titleLabel?.text == "| |") {
                audioPlayer.pause()
                pauseBtn.setTitle("Resume", for: .normal)
                //pauseBtn.setTitle("=.>", for: .normal)
                //pauseBtn.setImage( UIImage.init(named: "pauseIcon"), for: .normal)
            } else {
                pauseBtn.setTitle("Pause", for: .normal)
                //pauseBtn.setTitle("| |", for: .normal)
                audioPlayer.play()
                //yourBtn.setImage( UIImage.init(named: "imagename"), for: .normal)
            }
        }
    }
    
    
    
    @IBAction func finishedBtn(_ sender: UIButton) {
        finishedAction()
        
    }
    
    @IBAction func publishBtn(_ sender: UIButton) {
        print("publishing")
        prepToPublish()
        
        let dbManager = DatabaseManager()
        
        // TODO: update the dbManager thing with a post that uses a token
        let postID = dbManager.createNewPost(token: self.token, data: variable.rawString()!)
        print("ID of the post just returned \(postID)")
        
        
        // This is just a test to upload to s3
        let dataURL = getDirectory().appendingPathComponent("myrecorder.m4a")
        let s3Transfer = S3TransferUtility()
        do {
            let audioData = try Data(contentsOf: dataURL as URL)
            s3Transfer.uploadData(data: audioData, postID: postID)
            
            //perform segue
            self.performSegue(withIdentifier: "recorderToFeed", sender: nil)
            
        } catch {
            print("Unable to load data: \(error)")
        }
    }
    
    func prepToPublish() {
        let timeInterval = Int(NSDate().timeIntervalSince1970)
        let likes : Int = 0
        self.timeCreated = String(timeInterval)
        self.desc = descriptionTxt.text!
        let data = JSON([
            "username": self.username,
            "description": descriptionTxt.text!,
            "timeCreated": String(timeInterval),
            "likes": String(likes),
            "duration": elapsed
            ])
        
        let array : [JSON] = [data]
        variable = JSON(["Post" : array])
        
        print(variable)
    }
    
    @IBAction func publishPrivate(_ sender: UIButton) {
        
        prepToPublish()
        self.performSegue(withIdentifier: "recorderToSelection", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "recorderToSelection"){
            //let navVC = segue.destination as! PublishSelectionViewController
            let destinationVC = segue.destination as! PublishSelectionViewController
            destinationVC.token = self.token
            destinationVC.username = self.username
            //destinationVC.description = self.desc
            destinationVC.desc = self.desc
            destinationVC.timeCreated = self.timeCreated
            destinationVC.duration = self.elapsed
            destinationVC.variable = self.variable.rawString()
            destinationVC.audioData = self.audioData
            
        }
        
    }
    
    //MARK: - Functions
    func buttonsOnLoad () {
        //descriptionTxt.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
                
        timerLbl.isHidden = true
        publishBtn.isHidden = true
        publishPrivateBtn.isHidden = true
        pauseBtn.isHidden = true
        finishedBtn.isHidden = true
        descriptionTxt.isHidden = true
        
        defaultTxt.text = "Click the big red button and start talking"
        
        if audioRecorder == nil{
            let filename = getDirectory().appendingPathComponent("myrecorder.m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            //Start Audio Recodring
            do {
                //pass in the URL and the settings defined above
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
            }
            catch {
                displayALert(title: "Oh my.....", message: "Recording Failed")
            }
        }
        
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        do{
            try recordingSession!.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try recordingSession.setActive(true)
        } catch {
            
        }
        
        //recordNavBtn.isEnabled = false
        
        //asking the user for permission
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func beginRecording () {
        
        if audioPlayer != nil{
            audioPlayer.stop()
        }
        
        if audioRecorder == nil{
            let filename = getDirectory().appendingPathComponent("myrecorder.m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            //Start Audio Recodring
            do {
                //pass in the URL and the settings defined above
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
            }
            catch {
                displayALert(title: "Oh my.....", message: "Recording Failed")
            }
        }

        //pass in the URL and the settings defined above
        audioRecorder.delegate = self
        audioRecorder.record()
        
        timerLbl.isHidden = false
        publishBtn.isHidden = true
        publishPrivateBtn.isHidden = true
        pauseBtn.isHidden = false
        finishedBtn.isHidden = false
        recordBtn.isHidden = true
        defaultTxt.isHidden = true
        
        //rerecord settings
        pauseBtn.setTitle("Pause", for: .normal)
        //pauseBtn.setTitle("| |", for: .normal)
        finishedBtn.setTitle("Finished", for: .normal)
        //finishedBtn.setTitle("[ ]", for: .normal)
        recordingImage.isHidden = false
        
        recordingImage.loadGif(name: "recording")
        
        descriptionTxt.isHidden = true
        
        reset()
        start()
    }
    
    func pauseRecorder () {
        //When recording is paused
        recordingImage.isHidden = true
        let blueColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255/255.0, alpha: 1.0)
        view.backgroundColor = blueColor
        audioRecorder.pause()
        stop()
        pauseBtn.setTitle("Resume", for: .normal)
        //pauseBtn.setTitle("=.>", for: .normal)
    }
    
    func resumeRecorder () {
        //When recording is active
        pauseBtn.setTitle("Pause", for: .normal)
        //pauseBtn.setTitle("| |", for: .normal)
        recordingImage.loadGif(name: "recording")
        recordingImage.isHidden = false
        start()
        audioRecorder.record()
    }
    
    func finishedAction () {
        if (finishedBtn.titleLabel?.text == "Finished") {
        //if (finishedBtn.titleLabel?.text == "[ ]") {
            //When clicked
            pauseBtn.setTitle("Pause", for: .normal)
            //pauseBtn.setTitle("| |", for: .normal)
            //yourBtn.setImage( UIImage.init(named: "imagename"), for: .normal)
            
            stop()
            
            publishBtn.isHidden = false
            publishPrivateBtn.isHidden = false
            recordingImage.isHidden = true
            descriptionTxt.isHidden = false
            defaultTxt.isHidden = false
            defaultTxt.text = "Play it back, if you don't like it the big red button to rerecord"
            
            //view.backgroundColor = UIColor.darkGray
            let greenColor = UIColor(red: 10/255.0, green: 156/255.0, blue: 54/255.0, alpha: 1.0)
            view.backgroundColor = greenColor
            
            recordBtn.isHidden = false
            
            //stop the audio recording
            audioRecorder.stop()
            audioRecorder = nil
            
            pauseBtn.isHidden = true
            
            finishedBtn.setTitle("Playback", for: .normal)
            //finishedBtn.setTitle("= >", for: .normal)
        }
        if (finishedBtn.titleLabel?.text == "Playback") {
        //if (finishedBtn.titleLabel?.text == "= >") {
                playBack()
        }
    }
    
    func playBack() {
        pauseBtn.isHidden = false
        let filename = getDirectory().appendingPathComponent("myrecorder.m4a")
        do{
            //initialize the audio player
            
            audioPlayer = try AVAudioPlayer(contentsOf: filename)
            audioPlayer.play()
        }
        catch{
            displayALert(title: "Oh no.....", message: "Playback Failed")
        }
        pauseBtn.setTitle("Pause", for: .normal)
    }
    
    //Recording functions
    var audioRecorder:AVAudioRecorder!
    var recordingSession:AVAudioSession!
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
    
    //Publishing
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = descriptionTxt.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        if(text == "\n") {
            descriptionTxt.resignFirstResponder()
            return false
        }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 80
    }

    
    @objc func editingChanged(_ textField: UITextField) {
        if recorderRule.validation(description: descriptionTxt.text) == true {
            defaultTxt.text = " Play it back, if you don't like it click anywhere to rerecord "
            publishBtn.isHidden = true
            publishPrivateBtn.isHidden = true
        } else {
            defaultTxt.text = " Play it back, if you don't like it click anywhere to rerecord"
            publishBtn.isHidden = false
            publishPrivateBtn.isHidden = false
        }
    }
    
    //Timers
    //Timer variables
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var elapsed: Double = 0
    var status: Bool = false
    
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
    
    func reset() {
        time = 0
        elapsed = 0
    }
    
    @objc func updateCounter() {
        // Calculate total time since timer started in seconds
        time = Date().timeIntervalSinceReferenceDate - startTime
        print("time: \(time)")
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
        
        timerLbl.text = "\(strMinutes):\(strSeconds)"
        
        func eventTimer() {
            if minutes == 2 {
                finishedAction ()
                stop()
            }
        }
        //why must you have this?
        return(eventTimer())
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // Dismissing the keyboard using the tap jester
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}



