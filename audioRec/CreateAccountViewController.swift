//
//  CreateAccountViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 7/21/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

//testing kit
//import Alamofire
import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    //Defined a constant that holds the URL for our web service
    //This is a test account
    let URL_USER_REGISTER = "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com"
    var token : String = ""
    let preferences = UserDefaults.standard
    
    private let createAccountModel = CreateAccountModel()
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var registrationButton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func registerButton(_ sender: Any) {
      
        if(password.text!.isEqual(repeatPassword.text!)){
            let dbManager = DatabaseManager()
            
            let variable = "{\"User\":[{\"username\":\" " + username.text! + "\",\"password\":\" " + password.text! + "\",\"email\":\" " + emailAddress.text! + "\"}]}"
            
            print("-----------------response from dataPost-----------------------")
            print(dbManager.dataPost(endpoint: "api/user", data: variable))

            
            let alert = UIAlertController(title: "Did you bring your towel?", message: "Success! Return to login", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Congrats", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } else{
            
            let alert = UIAlertController(title: "Did you bring your towel?", message: "Passwords don't match", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
            self.present(alert, animated: true)

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        username.delegate = self
        password.delegate = self
        repeatPassword.delegate = self
        emailAddress.delegate = self

        registrationButton.isEnabled = false
        
        username.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        password.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        repeatPassword.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        emailAddress.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        // get token from preferences
        if preferences.value(forKey: "tokenKey") == nil {
            //  Doesn't exist
        } else {
            self.token = preferences.value(forKey: "tokenKey") as! String
        }
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
    
    @objc func editingChanged(_ textField: UITextField) {
        if createAccountModel.validation(username: username.text, emailAddress: emailAddress.text, password: password.text) == true {
            self.registrationButton.isEnabled = true
        } else {
            self.registrationButton.isEnabled = false
        }
    }
    
    
    override open var shouldAutorotate: Bool {
        return false
    }
}

