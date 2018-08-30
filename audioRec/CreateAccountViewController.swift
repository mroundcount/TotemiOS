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

class CreateAccountViewController: UIViewController {
    
    private let CreateAccount = CreateAccountModel()
    
    //Defined a constant that holds the URL for our web service
    //This is a test account
    let URL_USER_REGISTER = "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com"
    var token : String = ""
    let preferences = UserDefaults.standard
    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var labelMessage: UILabel!
    
    
    @IBOutlet weak var registrationButton: UIButton!
    
    
    @IBAction func registerButton(_ sender: Any) {
      
        if(password.text!.isEqual(repeatPassword.text!)){
            let dbManager = DatabaseManager()
            
            /*
             * Expected Data Input:
             *  variable = {"User":[{"username":"Username","password":"hi","email":"Email Address"}]}
             */
            
            let variable = "{\"User\":[{\"username\":\" " + username.text! + "\",\"password\":\" " + password.text! + "\",\"email\":\" " + emailAddress.text! + "\"}]}"
            
            print("-----------------response from dataPost-----------------------")
            print(dbManager.dataPost(endpoint: "api/user", data: variable))
            
            labelMessage.text = "Success! Return to login"

        } else{
            labelMessage.text = "Passwords don't match"
        }
        
    }
    
    
    
    
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // get token from preferences
        if preferences.value(forKey: "tokenKey") == nil {
            //  Doesn't exist
        } else {
            self.token = preferences.value(forKey: "tokenKey") as! String
        }
        
        registrationButton.isEnabled = false
        
        username.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        password.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        emailAddress.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    //enabling and disabling the sign up button based on whether or not the fields are valid
    @objc func editingChanged(_ textField: UITextField) {
        if CreateAccount.validation(username: username.text, emailAddress: emailAddress.text, password: password.text) == true {
            self.registrationButton.isEnabled = true
        } else {
            self.registrationButton.isEnabled = false
        }
        
        if CreateAccount.validateUsername(username: username.text!) == true {
            username.layer.backgroundColor = UIColor.green.cgColor }
        else {
            print ("Bam")
        }
        
        if CreateAccount.validatePassword(password: password.text!) == true {
            password.layer.backgroundColor = UIColor.green.cgColor }
        else {
            print ("Bam")
        }
        
        if password.text == repeatPassword.text {
            repeatPassword.layer.backgroundColor = UIColor.green.cgColor }
        else {
            print ("Peanut")
        }
        
        if CreateAccount.validateEmail(emailAddress: emailAddress.text!) == true {
            emailAddress.layer.backgroundColor = UIColor.green.cgColor }
        else {
            print ("Bam")
        }
    }
}
