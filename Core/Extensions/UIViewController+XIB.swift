//
//  UIViewController+XIB.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/20/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit

extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
    
    static func loadFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        return vc as! Self
    }
}
