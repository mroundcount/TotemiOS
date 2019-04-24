//
//  PublishSelectionViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 3/10/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit
import AWSS3
import SwiftyJSON

//PublishTableViewCell

class PublishSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var activeTags : NSMutableArray = []
    var postCell: PublishTableViewCell!
    let s3Transfer = S3TransferUtility()
    var token : String?
    var usernameString = ""
    let preferences = UserDefaults.standard
    var selectedIndex : NSInteger! = -1
    var selectedIndexPath : IndexPath!
    var posts : [Post] = []
    var variable : String?
    var username: String?
    var desc: String?
    var timeCreated: String?
    var duration: Double?
    var audioData: URL?
    
    var usernames : NSArray?
    let dbManager = DatabaseManager()
    var usersToSendArray : [String] = []
    
    //need to change post type
    var selectionArray: [Any] = []
    
    //var searchArray = [String]()
    var searchArray : [String] = []
    var isSearching = false
    
    @IBAction func Back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    func getUsernames(){
        usernames = dbManager.getUsernames(token: self.token!)
        print(usernames)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return (searchArray.count)
        } else {
            return (usernames!.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : PublishTableViewCell!

        cell = tableView.dequeueReusableCell(withIdentifier: "PublishTableViewCell") as! PublishTableViewCell

        if isSearching  {
            cell.usernameLabel.text = searchArray[indexPath.row]
        } else {
            cell.usernameLabel.text = usernames![indexPath.row] as? String
        }
        cell.sizeToFit()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            usersToSendArray = usersToSendArray.filter{$0 != usernames![indexPath.row] as! String}
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            print(tableView.indexPathForSelectedRow)
            usersToSendArray.append(usernames![indexPath.row] as! String)
        }
    }
    
    


    @IBAction func publishBtn(_ sender: UIButton) {
    
        print("Sent!")
        publish()

        self.performSegue(withIdentifier: "selectorToFeed", sender: nil)
    }
    
    
    func publish() {
        print("publishing")
        print(usersToSendArray)
        let timeInterval = Int(NSDate().timeIntervalSince1970)
        let likes : Int = 0
        self.timeCreated = String(timeInterval)
        let data = JSON([
            "username": self.username,
            "description": desc,
            "timeCreated": String(timeInterval),
            "likes": String(likes),
            "duration": duration,
            "toUser": usersToSendArray
            ])
        
        let array : [JSON] = [data]
        let variableJson = JSON(["Post" : array])
        
        print(variableJson)
        let dbManager = DatabaseManager()
        
        // TODO: update the dbManager thing with a post that uses a token
        let postID = dbManager.createNewPrivatePost(token: self.token!, data: variableJson.rawString()!)
        print("ID of the post just returned \(postID)")
        
        // This is just a test to upload to s3
        let dataURL = getDirectory().appendingPathComponent("myrecorder.m4a")
        let s3Transfer = S3TransferUtility()
        do {
            let audioData = try Data(contentsOf: dataURL as URL)
            s3Transfer.uploadData(data: audioData, postID: postID)
        } catch {
            print("Unable to load data: \(error)")
        }
    }
    
    func getDirectory() -> URL{
        //Searching for all the URLS in the documents directory and taking the first one and returning the URL to the document directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //defining our constant.
        //We will use the first URL path
        let documentDirectory = paths[0]
        return documentDirectory
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            let sText = searchBar.text
            searchArray = usernames!.filter({($0 as! String).localizedCaseInsensitiveContains(sText!)}) as! [String]
            tableView.reloadData()
        }
    }

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        searchBar.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsernames()
        searchBar.delegate = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
}

