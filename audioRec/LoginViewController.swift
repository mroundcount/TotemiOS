//
//  LoginViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 7/19/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//


//Michael Code
import UIKit
import SystemConfiguration


class LoginViewController: UIViewController {

    @IBOutlet var _username: UITextField!
    @IBOutlet var _password: UITextField!
    @IBOutlet var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let username = _username.text!
        let password = _password.text!
        
        DoLogin(user: username, psw: password)
    }
    
    func DoLogin(user:String, psw:String){
        
        //test API link
        let url = URL(string: "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com/apiToken")
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        // format data to be posted
        let loginString = String(format: "%@:%@", user, psw)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // Set method to POST and add username & password value
        request.httpMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        // use DispatchGroup so you don't return token before it has a value
        let group = DispatchGroup()
        
        group.enter()
        
        // fireoff request
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {        // check for http errors
                
                // login failed
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                
               
                
                // avoid deadlocks by not using .main queue here
                DispatchQueue.global().async {
                    group.leave()
                }
                
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                // success case
                
                let responseString = String(data: data, encoding: .utf8)
                
                let res = String(describing: responseString)
                let index1 = res.index(res.endIndex, offsetBy: -5)
                let index0 = res.index(res.startIndex, offsetBy: 23)
                
                print(responseString)
                
                let sub1 = res[index0..<index1]
                
                print(sub1)
                // avoid deadlocks by not using .main queue here
                DispatchQueue.global().async {
                    group.leave()
                }
                
            }
            
        }
        task.resume()
        
        group.notify(queue: .main){
            print("complete")
        }
        
}

}
