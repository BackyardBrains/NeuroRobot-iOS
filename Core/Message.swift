//
//  Message.swift
//  toSales
//
//  Created by Djordje Jovic on 01/06/2020.
//  Copyright © 2020 Go Go Encode. All rights reserved.
//

import SwiftMessages

class Message {
    
    static func error(message: String) {
        let view = messageView()
        view.configureTheme(.error)

        let iconText = "🚫"
        view.configureContent(title: "Error", body: message, iconText: iconText)
        SwiftMessages.show(config: config(), view: view)
    }
    
    static func warning(message: String) {
        let view = messageView()
        view.configureTheme(.warning)
        
        let iconText = "⚠️"
        view.configureContent(title: "Warning", body: message, iconText: iconText)
        SwiftMessages.show(config: config(), view: view)
    }
    
    static func success(message: String) {
        let view = messageView()
        view.configureTheme(.success)
        
        let iconText = "✅"
        view.configureContent(title: "Success", body: message, iconText: iconText)
        SwiftMessages.show(config: config(), view: view)
    }
    
    private static func messageView() -> MessageView {
        let view = MessageView.viewFromNib(layout: .messageView)
        view.configureDropShadow()
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        view.button?.isHidden = true
        
        return view
    }
    
    private static func config() -> SwiftMessages.Config {
        var conf = SwiftMessages.Config()
        conf.presentationContext = .window(windowLevel: .alert) 
        return conf
    }
}
