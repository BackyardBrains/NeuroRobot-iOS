//
//  SerialData.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 02/04/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import Foundation

class SerialData {
    
    let leftEncoderValue: String
    let rightEncoderValue: String
    
    let distance: String
    
    let temperature: String
    
    let acx: String
    let acy: String
    let acz: String
    
    let gyx: String
    let gyy: String
    let gyz: String
    
    init?(message: String) {
        let messages = message.split(separator: ",").map({ return String($0) })
        guard messages.count >= 10 else { return nil }
        
        leftEncoderValue     = messages[0]
        rightEncoderValue    = messages[1]
        distance             = messages[2]
        acx                  = messages[3]
        acy                  = messages[4]
        acz                  = messages[5]
        temperature          = messages[6]
        gyx                  = messages[7]
        gyy                  = messages[8]
        gyz                  = messages[9]
    }
}
