//
//  FingerView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 6/24/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit

final class Vector {
    public var x            : CGFloat = 0
    public var y            : CGFloat = 0
    public var dX           : CGFloat = 0
    public var dY           : CGFloat = 0
    public var intensity    : CGFloat = 0
    public var angle        : CGFloat = 0
    
    var point: CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
        self.intensity = sqrt(pow(x, 2) + pow(y, 2))
        self.dX = x / intensity
        self.dY = y / intensity
        self.angle = atan(y / x)
    }
    
    init(point: CGPoint) {
        load(point: point)
    }
    
    func load(point: CGPoint) {
        var xLocal: CGFloat = point.x
        var yLocal: CGFloat = point.y
        
        if xLocal > -5 && xLocal < 5 {
            xLocal = 0
        }
        if yLocal > -5 && yLocal < 5 {
            yLocal = 0
        }
        
        self.x = xLocal
        self.y = yLocal
        self.intensity = sqrt(pow(point.x, 2) + pow(point.y, 2))
        self.dX = x / intensity
        self.dY = y / intensity
        self.angle = atan(y / x)
    }
    
    func reset() {
        x = 0
        y = 0
        dX = 0
        dY = 0
        intensity = 0
        angle = 0
    }
    
    func adjustForMaxRadius(_ maxRadius: CGFloat) {
        var multiplier: CGFloat = 1
        if x < 0 {
            multiplier = -1
        }
        x = cos(angle) * maxRadius * multiplier
        y = sin(angle) * maxRadius * multiplier
        intensity = maxRadius
        dX = x / intensity
        dY = y / intensity
    }
}

final class FingerView: UIView {
    
    private var neutralLocation = CGPoint(x: 0, y: 0)
    private var vector = Vector(x: 0, y: 0)
    private var impactOccured = false
    private var touchesEnded = false
    
    
    typealias intensityAndDirectionBlock = (Vector, CGFloat) -> Void
    var intensityCallback: intensityAndDirectionBlock?
    func intensityChanged(callback: @escaping intensityAndDirectionBlock) {
        intensityCallback = callback
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
        center = CGPoint(x: superview!.bounds.width / 2, y: superview!.bounds.height / 2)
        neutralLocation = center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first, let superView = superview {
            let location = touch.location(in: superView)
            center = location
            touchesEnded = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let touch = touches.first, let superView = self.superview, !self.touchesEnded {
                let location = touch.location(in: superView)
                
                let additionalDistance = self.bounds.width / 2 + superView.layer.borderWidth
                let radius = superView.bounds.width / 2 - additionalDistance
                self.vector.load(point: location - self.neutralLocation)
                
                if Int(self.vector.x) != 0, Int(self.vector.y) != 0 {
                    self.impactOccured = false
                }
                if !self.impactOccured, Int(self.vector.x) == 0 || Int(self.vector.y) == 0 {
                    self.impactOccured = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                
                if self.vector.intensity > radius {
                    self.vector.adjustForMaxRadius(radius)
                }
                self.center = self.neutralLocation + self.vector.point
                
                self.callCallback()
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEnded = true
        center = neutralLocation
        vector.reset()
        callCallback()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEnded = true
        center = neutralLocation
        vector.reset()
        callCallback()
    }
    
    func callCallback() {
        var radius: CGFloat = 0
        if let superView = superview {
            radius = superView.bounds.width / 2 - bounds.width / 2 - superView.layer.borderWidth
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.intensityCallback?(self!.vector, radius)
        }
    }
}
