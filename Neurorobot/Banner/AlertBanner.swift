//
//  AlertBanner.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 9/29/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import Foundation
import BRYXBanner

final class AlertBanner {
    static let shared = AlertBanner()
    
    private init() {}
    
    func showError(message: String) {
        let banner = Banner(title: "Error", subtitle: message, image: nil, backgroundColor: .red)
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }
}
