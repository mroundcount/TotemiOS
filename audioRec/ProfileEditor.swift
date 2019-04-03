//
//  ProfileEditor.swift
//  audioRec
//
//  Created by Michael Roundcount on 2/17/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileEditor: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

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
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        profilePicture.clipsToBounds = true
        
        //dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
        //Roundcount added 2/18
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
//        Roundcount edit stop
        let s3Transfer = S3TransferUtility()
        let image = s3Transfer.downloadProfilePicture(picID: username)
        profilePicture.image = image

    }
    @IBAction func backProfile(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
   
    /*
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = aboutMeTxt.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 5
    }
 */
    
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
            let success = self.saveImage(image: image)
            print("success?: \(success)")
            
        } else {
            print("upload failed")
        }
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func saveBtn(_ sender: UIButton) {
   
//        Roundcount added 2/18
//        let data = JSON([
//            ])
//
//        let array : [JSON] = [data]
//        let variable = JSON(["Post" : array])
//        let dbManager = DatabaseManager()
//
////         TODO: update the dbManager thing with a post that uses a token
//        let picID = dbManager.createNewPost(token: self.token, data: variable.rawString()!)
//        print("ID of the post just returned \(picID)")
     
//         This is just a test to upload to s3
        let dataURL = getDirectory().appendingPathComponent("myprofilepicture.jpg")
        let s3Transfer = S3TransferUtility()
        do {
            let imageData = try Data(contentsOf: dataURL as URL)
            s3Transfer.uploadProfilePic(data: imageData, picID: username)
        } catch {
            print("Unable to load data: \(error)")
        }
        self.performSegue(withIdentifier: "backProfile", sender: nil)
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

    func saveImage(image: UIImage) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("myprofilepicture.jpg")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
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
