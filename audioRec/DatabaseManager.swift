//
//  DatabaseManager.swift
//  audioRec
//
//  Created by Lucas Rydberg on 7/31/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import Foundation
import SystemConfiguration

class DatabaseManager {
    
    // MARK: Variables
    var webURL = "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com/"
    var endpoint : String?
    var token : String?
    var posts : NSArray? = []
    
    init() {
        // empty constructor
    }
    
    // MARK: Methods for posting data
    // -------------------------------------------
    
    // Requires valid JSON Web token, web endpoint and data as string
    //
    //
    // Returns response code as Int
    func dataPost(endpoint: String, data: String) -> Int {
        
        if(isInternetAvailable()){
            
            var responseCode : Int?
            
            // get patient
            let webUrl1 = self.webURL + endpoint
            var request1 = URLRequest(url: URL(string: webUrl1)!)
            
            // Set method to GET and add token
            request1.httpMethod = "POST"
            request1.setValue("data", forHTTPHeaderField: "Content")
            
            let json: NSData = data.data(using: String.Encoding.utf8)! as NSData
            
            request1.httpBody = json as Data
            
            let group = DispatchGroup()
            
            group.enter()
            
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
                
                
                // fireoff request
                let task1 = URLSession.shared.dataTask(with: request1) { data, response, error in
                    guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                        print("error=\(String(describing: error))")
                        responseCode = 404
                        group.leave()
                        return
                    }
                    
                    let responseString = String(data: data!, encoding: String.Encoding.utf8) as String!
                    // responseString format {"status":201,"type":305}
                    
                    // typeID = whatever in the data
                    
                    let httpStatus = response as? HTTPURLResponse
                    
                    if httpStatus?.statusCode != 201 {
                        // check for http errors
                        print("statusCode should be 201, but is \(String(describing: httpStatus?.statusCode))")
                        
                        print("response = \(String(describing: response))")
                        
                    } else {
                        
                            do{
                                // convert String to NSData
                                let data: NSData = responseString!.data(using: String.Encoding.utf8)! as NSData
                                let parsedData = try JSONSerialization.jsonObject(with: data as Data) as! [String:AnyObject]
                                print("[][][][][][][][][ parsed data ][][][][][")
                                print(parsedData)
                            } catch{
                                print("Could not make object")
                            }
                        
                        
                        // avoid deadlocks by not using .main queue here
                        DispatchQueue.global().async {
                            responseCode = httpStatus?.statusCode
                            group.leave()
                        }
                        
                        
                    }
                    
                }
                task1.resume()
            }
            
            // wait ...
            group.wait()
            // ... and return as soon as "responseCode" has a value
            //        group.notify(queue: .main) {
            //            print(responseCode!)
            //        }
            
            return responseCode!
            
        }
        else{
            return -1
        }
    }
    
    // Requires valid JSON Web token
    //
    // Returns Posts as NSArray
    func getPostsForUser(token: String, data: String) -> NSArray {
        
        if(isInternetAvailable()){
            
            print("GETTING POSTS")
            // get patient
            let webUrl1 = "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com/api/getPostsForUser"
            var request1 = URLRequest(url: URL(string: webUrl1)!)
            
            // Set method to GET and add token
            request1.httpMethod = "POST"
            request1.setValue("data", forHTTPHeaderField: "Content")
            request1.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            
            let json: NSData = data.data(using: String.Encoding.utf8)! as NSData
            
            request1.httpBody = json as Data
            
            // use DispatchGroup so you don't return token before it has a value
            let group = DispatchGroup()
            
            group.enter()
            
            // fireoff request
            let task1 = URLSession.shared.dataTask(with: request1) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    self.posts = []
                    group.leave()
                    return
                }
                
                let httpStatus = response as? HTTPURLResponse
                
                if httpStatus?.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(String(describing: httpStatus?.statusCode))")
                    
                    // avoid deadlocks by not using .main queue here
                    DispatchQueue.global().async {
                        group.leave()
                    }
                    
                } else {
                    
                    // avoid deadlocks by not using .main queue here
                    DispatchQueue.global().async {
                        do{
                            self.posts = try JSONSerialization.jsonObject(with: data as Data) as? NSArray
                            
                        } catch{
                            print("Could not make obj")
                        }
                        group.leave()
                    }
                    
                }
                
                
            }
            task1.resume()
            
            // wait ...
            group.wait()
            // ... and return as soon as "posts" has a value
            return self.posts!
        }
        else {
            return []
        }
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    
    func getPostsForFeed(token: String, data: String) -> NSArray {
        
        if(isInternetAvailable()){
            
            print("GETTING POSTS")
            // get patient
            let webUrl1 = "http://totem-env.qqkpcqqjfi.us-east-1.elasticbeanstalk.com/api/getPostsForUser"
            var request1 = URLRequest(url: URL(string: webUrl1)!)
            
            // Set method to GET and add token
            request1.httpMethod = "POST"
            request1.setValue("data", forHTTPHeaderField: "Content")
            request1.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            
            let json: NSData = data.data(using: String.Encoding.utf8)! as NSData
            
            request1.httpBody = json as Data
            
            // use DispatchGroup so you don't return token before it has a value
            let group = DispatchGroup()
            
            group.enter()
            
            // fireoff request
            let task1 = URLSession.shared.dataTask(with: request1) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    self.posts = []
                    group.leave()
                    return
                }
                
                let httpStatus = response as? HTTPURLResponse
                
                if httpStatus?.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(String(describing: httpStatus?.statusCode))")
                    
                    // avoid deadlocks by not using .main queue here
                    DispatchQueue.global().async {
                        group.leave()
                    }
                    
                } else {
                    
                    // avoid deadlocks by not using .main queue here
                    DispatchQueue.global().async {
                        do{
                            self.posts = try JSONSerialization.jsonObject(with: data as Data) as? NSArray
                            
                        } catch{
                            print("Could not make obj")
                        }
                        group.leave()
                    }
                    
                }
                
                
            }
            task1.resume()
            
            // wait ...
            group.wait()
            // ... and return as soon as "posts" has a value
            return self.posts!
        }
        else {
            return []
        }
    }
}
