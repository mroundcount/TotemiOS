//
//  ProfileEditor.swift
//  
//
//  Created by Michael Roundcount on 2/13/19.

import UIKit

class ProfileEditor: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
    @IBOutlet weak var profilePicture: UIImageView!
     @IBOutlet weak var uploadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
     
     
    @IBAction func uploadBtnTapped(_ sender: UIButton) {
  
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
    }
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        profilePicture.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        profilePicture.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
        //uploadImage()
    }
    */
}
