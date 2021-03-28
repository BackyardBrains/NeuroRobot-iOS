//
//  BrainNetworkView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 19/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

final class BrainNetworkView: UIView {
    
    // UI
    private let backgroundImageView = UIImageView()
    private var neuronViews = [NeuronView]()
    private var lineLayers = [CALayer]()
    private var contactViews = [ContactView]()
    
    // Layers
    private var linesLayer = CALayer()
    private var contactsLayer = CALayer()
    
    // Data
    private weak var brain: Brain?
    private var didSetup = false
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
        square()
        
        addSubview(backgroundImageView)
        backgroundImageView.fillSuperView()
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.image = #imageLiteral(resourceName: "workspace_background_white")
        
        layer.addSublayer(linesLayer)
        layer.addSublayer(contactsLayer)
    }
    
    override func draw(_ rect: CGRect) {
        guard !didSetup, brain != nil else { return }
        didSetup = true
        
        drawConnections()
    }
    
    private func clearUI() {
        for view in neuronViews {
            view.removeFromSuperview()
        }
        neuronViews.removeAll()
        
        for layer in linesLayer.sublayers ?? [] {
            layer.removeFromSuperlayer()
        }
        linesLayer.removeFromSuperlayer()
        linesLayer = CALayer()
        layer.addSublayer(linesLayer)
        
        for layer in contactsLayer.sublayers ?? [] {
            layer.removeFromSuperlayer()
        }
        contactsLayer.removeFromSuperlayer()
        contactsLayer = CALayer()
        layer.addSublayer(contactsLayer)
    }
    
    private func drawLine(from: CGPoint, to: CGPoint, lineWidth: CGFloat = 0.5, color: UIColor = .white, isDiamond: Bool = false, numberType: NumberType) {
        
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
        
        let lineLayer = CAShapeLayer()
        lineLayer.frame = bounds
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = UIColor.black.cgColor
        lineLayer.path = aPath.cgPath
        
        var contactSize = lineWidth * 3
        contactSize.limit(lower: 4, upper: 15)
        
        var contactView: NeuronContactView!
        
        if isDiamond {
            contactView = NeuronContactView(frame: CGRect(origin: .zero, size: CGSize(contactSize * 3.5)), type: .diamond, backColor: color)
        } else {
            contactView = NeuronContactView(frame: CGRect(origin: .zero, size: CGSize(contactSize)), type: .square, backColor: color)
        }
        
        contactView.center = to
        
        linesLayer.addSublayer(lineLayer)
        contactsLayer.addSublayer(contactView.layer)
        
        // Add label for according number type
        if let numLabel = numberType.label(center: to, lineWidth: lineWidth) {
            numLabel.layer.displayIfNeeded()
            contactsLayer.addSublayer(numLabel.layer)
        }
    }
    
    private func drawConnections() {
        guard let brain = brain else { return }
        
        if let connections = brain.getInnerConnections() {
            let daConnectToMe = brain.getDaConnectToMe()
            
            for i in 0..<connections.count {
                for j in 0..<connections[i].count where connections[i][j] > 0 {
                    var lineWidth = CGFloat(connections[i][j]) / 12
                    lineWidth.limit(lower: 1, upper: 10)
                    
                    var color = UIColor.white
                    if let daConnectToMe = daConnectToMe {
                        if daConnectToMe[i][j][0] == 1 {
                            color = UIColor(red: 1, green: 0.7, blue: 0.4, alpha: 1)
                        } else if daConnectToMe[i][j][0] == 2 {
                            color = UIColor(red: 0.6, green: 0.7, blue: 1, alpha: 1)
                        }
                    }
                    
                    drawLine(from: neuronViews[i].center, to: neuronViews[j].center, lineWidth: lineWidth, color: color, numberType: .lineWidth)
                }
            }
        }
        
        if let contacts = brain.getOuterConnections() {
            let visPrefs = brain.getVisPrefs()
            let audioPrefs = brain.getAudioPrefs()
            let distPrefs = brain.getDistPrefs()
            
            for i in 0..<contacts.count {
                for j in 0..<contacts[i].count where contacts[i][j] > 0 {
                    
                    var isDiamond = false
                    var startPoint = neuronViews[i].center
                    var endPoint = contactViews[j].center
                    var color: UIColor = .white
                    var numberType = NumberType.none
                    if [1, 2, 3, 5].contains(j + 1) {
                        // 1, 2, 3, 5 are inputs, switch the places of start and end points.
                        startPoint = contactViews[j].center
                        endPoint = neuronViews[i].center
                        isDiamond = true
                    }
                    
                    // Indicate synapse filter (add rich neuron symbols here)
                    if [1, 2].contains(j + 1), let visPrefs = visPrefs {
                        // Eyes
                        
                        for z in 0..<visPrefs.first!.count where visPrefs[i][z][j] {
                            if [0, 1].contains(z) {
                                // red diamond
                                color = .red
                            } else if [2, 3].contains(z) {
                                // green diamond
                                color = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
                            } else if [4, 5].contains(z) {
                                // blue diamond
                                color = .blue
                            }
                        }
                        numberType = .lineWidth
                    } else if j + 1 == 3 {
                        // Microphone
                        color = UIColor(220)
                        numberType = .microphoneInput(audioPrefs[i])
                    } else if j + 1 == 5 {
                        // Speaker
                        color = UIColor(220)
                        numberType = .distanceInput(distPrefs[i])
                    }
                    
                    drawLine(from: startPoint, to: endPoint, color: color, isDiamond: isDiamond, numberType: numberType)
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
        
        if let colors = brain.getColors(), colors.count == neuronViews.count {
            for i in 0..<colors.count {
                neuronViews[i].backgroundColor = colors[i]
            }
        }
        
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

private enum NumberType {
    case lineWidth
    case microphoneInput(Double)
    case distanceInput(Double)
    case none
    
    func label(center: CGPoint, lineWidth: CGFloat) -> UILabel? {
        
        let numLabel = UILabel()
        numLabel.textAlignment = .center
        
        switch self {
        case .lineWidth:
            numLabel.text = "\(Int(lineWidth * 12))"
            numLabel.frame = CGRect(origin: .zero, size: CGSize(20))
            numLabel.center = center.applying(CGAffineTransform(translationX: 0, y: -10))
            numLabel.font = UIFont.systemFont(ofSize: 8)
            
        case .microphoneInput(let numberToPresent):
            numLabel.text = String(format: "%.0lf Hz", numberToPresent)
            numLabel.frame = CGRect(origin: .zero, size: CGSize(40))
            numLabel.center = center.applying(CGAffineTransform(translationX: -10, y: 0))
            numLabel.font = UIFont.systemFont(ofSize: 8, weight: .bold)
            
        case .distanceInput(let numberToPresent):
            numLabel.text = String(format: "%.0lf", numberToPresent)
            numLabel.frame = CGRect(origin: .zero, size: CGSize(40))
            numLabel.center = center
            numLabel.font = UIFont.systemFont(ofSize: 8, weight: .bold)
            
        default:
            return nil
        }
        
        return numLabel
    }
}
