//
//  MainTabBarController.swift
//  audioRec
//
//  Created by Lucas Rydberg on 4/17/19.
//  Copyright © 2019 Michael Roundcount. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item")
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        print("Selected view controller")
        
        let index = tabBarController.selectedIndex
        
        switch index {
        case 0:
            // feed
            print("feed selected")
        case 1:
            // record
            print("record selected")
        case 2:
            // private
            print("private selected")
        default:
            print("default")
        }
        
    }

}
