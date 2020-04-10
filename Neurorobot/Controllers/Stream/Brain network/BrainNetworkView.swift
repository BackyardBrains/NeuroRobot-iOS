//
//  BrainNetworkView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 19/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

class BrainNetworkView: UIView {
    
    // UI
    private let backgroundImageView = UIImageView()
    private var neuronViews = [NeuronView]()
    private var lineLayers = [CALayer]()
    private var contactViews = [ContactView]()
    
    //
    private var brain: Brain?
    private var didSetup = false
    
    // Data
    private let contactCoordinates = [
        Coordinate(x: -1.2, y: 2.05),
        Coordinate(x: 1.2, y: 2.1),
        Coordinate(x: -2.08, y: -0.38),
        Coordinate(x: 2.14, y: -0.38),
        Coordinate(x: -0.05, y: 2.45),
        Coordinate(x: -1.9, y: 1.45),
        Coordinate(x: -1.9, y: 0.95),
        Coordinate(x: -1.9, y: -1.78),
        Coordinate(x: -1.9, y: -2.28),
        Coordinate(x: 1.92, y: 1.49),
        Coordinate(x: 1.92, y: 0.95),
        Coordinate(x: 1.92, y: -1.82),
        Coordinate(x: 1.92, y: -2.29)
    ]
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundImageView)
        backgroundImageView.fillSuperView()
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.image = #imageLiteral(resourceName: "workspace_background_white")
    }
    
    override func draw(_ rect: CGRect) {
        guard !didSetup, brain != nil else { return }
        didSetup = true
        
        
        let backLayer = CAShapeLayer()
        backLayer.frame = self.bounds
//        backLayer.fillColor = clear.CGColor
//        backLayer.path = UIBezierPath(ovalInRect: rect).CGPath
        layer.addSublayer(backLayer)

        
        drawConnections()
    }
    
    private func clearUI() {
        for view in neuronViews {
            view.removeFromSuperview()
        }
        neuronViews.removeAll()
        
        for layer in lineLayers {
            layer.removeFromSuperlayer()
        }
        lineLayers.removeAll()
    }
    
    func drawLine(from: CGPoint, to: CGPoint, lineWidth: CGFloat = 0.5) -> CALayer {
        print("lineWidth: \(lineWidth)")
        var to = to
        var padding: CGFloat = 20
        let distance = from.distance(to: to)
        if distance < padding {
            padding = distance * 0.25
        }
        
        let dx = abs(from.x - to.x);
        let dy = abs(from.y - to.y);
        var rx = dx / (dx + dy);
        var ry = dy / (dx + dy);
        
        if dx == 0 {
            rx = 0
        }
        if dy == 0 {
            ry = 0
        }
        
        if from.x < to.x {
            to.x = to.x - padding * rx
        } else {
            to.x = to.x + padding * rx
        }
        
        if from.y < to.y {
            to.y = to.y - padding * ry
        } else {
            to.y = to.y + padding * ry
        }
        
        let aPath = UIBezierPath()
        aPath.move(to: from)
        aPath.addLine(to: to)
        aPath.close()
        
        let containerLayer = CALayer()
        
        let backLayer = CAShapeLayer()
        backLayer.frame = self.bounds
        backLayer.lineWidth = lineWidth
        backLayer.strokeColor = UIColor.black.cgColor
        backLayer.path = aPath.cgPath
        containerLayer.addSublayer(backLayer)
        
        var contactSize = lineWidth * 3
        contactSize.limit(lower: 4, upper: 15)
        
        let contactView = NeuronContactView(frame: CGRect(x: 0, y: 0, width: contactSize, height: contactSize))
        contactView.center = to
        contactView.backgroundColor = .white
        containerLayer.addSublayer(contactView.layer)
        
        layer.insertSublayer(containerLayer, above: backgroundImageView.layer)
        return containerLayer
    }
    
    private func drawConnections() {
        guard let brain = brain else { return }
        
        if let connections = brain.getInnerConnections() {
            for i in 0..<connections.count {
                for j in 0..<connections[i].count where connections[i][j] > 0 {
                    var lineWidth = CGFloat(connections[i][j]) / 12
                    lineWidth.limit(lower: 1, upper: 10)
                    
                    let layer = drawLine(from: neuronViews[i].center, to: neuronViews[j].center, lineWidth: lineWidth)
                    lineLayers.append(layer)
                }
            }
        }
        
        if let contacts = brain.getOuterConnections() {
            for i in 0..<contacts.count {
                for j in 0..<contacts[i].count where contacts[i][j] > 0 {
                    var startPoint = neuronViews[i].center
                    var endPoint = contactViews[j].center
                    if [1, 2, 3, 5].contains(j + 1) {
                        /// Sensors, switch the places of start and end points.
                        startPoint = contactViews[j].center
                        endPoint = neuronViews[i].center
                    }
                    
                    let layer = drawLine(from: startPoint, to: endPoint)
                    lineLayers.append(layer)
                }
            }
        }
    }
    
    private func initialSetupInternal(brain: Brain) {
        self.brain = brain
        clearUI()
        didSetup = false
        
        for coordinate in contactCoordinates {
            let contactView = ContactView()
            addSubview(contactView)
            contactView.setNumber(number: contactCoordinates.firstIndex(where: {$0 == coordinate})! + 1)
            
            var x = (coordinate.x + 3) / 3
            var y = (-coordinate.y + 3) / 3
            
            x = x < 0.001 ? 0.001 : x
            y = y < 0.001 ? 0.001 : y
            
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: contactView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: x, constant: 0),
                NSLayoutConstraint(item: contactView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: y, constant: 0)
            ])
            contactViews.append(contactView)
        }
        
        if let positions = brain.getPosition() {
            for coordinate in positions {
                let neuronView = NeuronView()
                addSubview(neuronView)
                neuronView.setNumber(number: positions.firstIndex(where: {$0 == coordinate})! + 1)
                
                var x = (coordinate.x + 3) / 3
                var y = (-coordinate.y + 3) / 3
                
                x = x < 0.001 ? 0.001 : x
                y = y < 0.001 ? 0.001 : y
                
                NSLayoutConstraint.activate([
                    NSLayoutConstraint(item: neuronView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: x, constant: 0),
                    NSLayoutConstraint(item: neuronView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: y, constant: 0)
                ])
                neuronViews.append(neuronView)
            }
        }
        
//        if let positions = brain.getPosition() {
//            for coordinate in positions {
//                let neuronView = NeuronView()
//                addSubview(neuronView)
//                neuronView.setNumber(number: positions.firstIndex(where: {$0 == coordinate})! + 1)
//
//                var x = (coordinate.x + 3) / 3
//                var y = (-coordinate.y + 3) / 3
//
//                x = x < 0.001 ? 0.001 : x
//                y = y < 0.001 ? 0.001 : y
//
//                NSLayoutConstraint.activate([
//                    NSLayoutConstraint(item: neuronView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: x, constant: 0),
//                    NSLayoutConstraint(item: neuronView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: y, constant: 0)
//                ])
//                neuronViews.append(neuronView)
//            }
//        }
        
        setNeedsDisplay()
    }
    
    func updateInternal(brain: Brain) {
        let firinig = brain.getFiringNeurons()
        for i in 0..<firinig.count {
            neuronViews[i].firing(isFiring: firinig[i])
        }
    }
}

extension BrainNetworkView {
    func initialSetup(brain: Brain) {
        DispatchQueue.main.async { [weak self] in
            self?.initialSetupInternal(brain: brain)
        }
    }
    
    func update(brain: Brain) {
        DispatchQueue.main.async { [weak self] in
            self?.updateInternal(brain: brain)
        }
    }
}
