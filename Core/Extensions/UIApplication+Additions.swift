//
//  UIApplication+Additions.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 14/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIWindow.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
}
