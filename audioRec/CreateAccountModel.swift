//
//  CreateAccountModel.swift
//  audioRec
//
//  Created by Michael Roundcount on 7/31/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import Foundation

class CreateAccountModel {
    
    init() {}

    func validation(username: String?, emailAddress: String?, password: String?) -> Bool {
        if ((username?.count)! >= 3) && validateEmail(emailAddress: emailAddress!) && ((password?.count)! >= 7) {
            return true
        }else{
            return false
        }
    }
    
    //function for name validation
    func validateUsername(username:String) -> Bool {
        if (username.count) >= 3 {
            return true
        } else { return false }
    }
    
    //function for Password validation
    func validatePassword(password:String) -> Bool {
        if (password.count) >= 3 {
            return true
        } else { return false }
    }
    
    
    //RegEx Email
    func validateEmail(emailAddress:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{3,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailAddress)
    }
}

extension Array {
    // extension of Array that returns nil if the element does
    // not contain an element
    func element(atIndex index: Int) -> Element? {
        if index < 0 || index >= self.count { return nil }
        return self[index]
    }
}
    

