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
    
    /*
    
    //Defined a constant that holds the URL for our web service
    //This is a test account
    let URL_USER_REGISTER = "http://192.168.1.105/SimplifiediOS/v1/register.php"

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var labelMessage: UILabel!    
    
    @IBAction func registerButton(_ sender: Any) {
        
        //creating parameters for the post request
        let parameters: Parameters=[
            "username":username.text!,
            "password":password.text!,
            "email":emailAddress.text!,
        ]
        
        //Sending http post request
        Alamofire.request(URL_USER_REGISTER, method: .post, parameters: parameters).responseJSON
            {
                //I wasnn't sure if you had something in mind for a sucess message for testing. We can skip this once you test
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    
                    //converting it as NSDictionary
                    let jsonData = result as! NSDictionary
                    
                    //displaying the message in label
                    //Again.... we probaby would just go strait to the feed or profile
                    self.labelMessage.text = jsonData.value(forKey: "message") as! String?
                }
        }
    }

    
   
    override func viewDidLoad() {
        super.viewDidLoad()

    }
*/
 
}
