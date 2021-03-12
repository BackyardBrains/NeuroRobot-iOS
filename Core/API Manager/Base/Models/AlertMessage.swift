//
//  AlertMessage.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 03/12/2019.
//  Copyright © 2019 Go Go Encode. All rights reserved.
//

import Foundation

class AlertMessage {
    
    var title = APIConstants.defaultAlertTitle
    var body = APIConstants.defaultAlertMessage
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}
