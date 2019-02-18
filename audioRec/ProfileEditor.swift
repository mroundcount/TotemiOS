//
//  ProfileEditor.swift
//  audioRec
//
//  Created by Michael Roundcount on 2/17/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileEditor: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Roundcount added 2/18
    var username : String = ""
    var token : String = ""
    let preferences = UserDefaults.standard
    //Roundcount edit stop
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var uploadPhoto: UIButton!
    @IBOutlet weak var backProfile: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Roundcount added 2/18
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
        //Roundcount edit stop
        
    }
    @IBAction func backProfile(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "backProfile", sender: nil)
    }
    

    @IBAction func uploadPhoto(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true) {
            //After it is complete
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.image = image
        } else {
            print("you suck")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveBtn(_ sender: UIButton) {
        //Roundcount added 2/18
        
        let data = JSON([
           
            ])
        
        let array : [JSON] = [data]
        let variable = JSON(["Post" : array])
        
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
        //end Roundcount add
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
    
    
    
    // Dismissing the keyboard using the tap jester
    //for later use
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    

}
