//
//  MainTabBarController.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/20/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    init(ip: String, port: String) {
        super.init(nibName: nil, bundle: nil)
        
        let vcs = [VideoStreamViewController.loadFromNib(),
                   LedViewController()]
        
        vcs[0].tabBarItem = UITabBarItem(title: "Stream", image: #imageLiteral(resourceName: "camera"), selectedImage: nil)
        vcs[1].tabBarItem = UITabBarItem(title: "Leds", image: #imageLiteral(resourceName: "led"), selectedImage: nil)
        
        viewControllers = vcs
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
