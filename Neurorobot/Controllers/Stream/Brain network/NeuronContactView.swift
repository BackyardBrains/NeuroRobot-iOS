//
//  NeuronContactView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 24/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

enum NeuronContactViewType {
    case square
    case diamond
}

class NeuronContactView: UIView {
    
    private var path: UIBezierPath?
    private var type: NeuronContactViewType = .square
    private var backColor: UIColor = .white
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupUI()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    init(frame: CGRect, type: NeuronContactViewType, backColor: UIColor) {
        super.init(frame: frame)
        self.type = type
        self.backColor = backColor
        setupUI()
    }
    
    private func setupUI() {
        
        switch type {
        case .square:
            
            backgroundColor = backColor
            layer.borderWidth = bounds.width > 5 ? 1.5 : 0.5
            layer.borderColor = UIColor.black.cgColor
        case .diamond:
            
            path = UIBezierPath()
            path?.move(to: CGPoint(x: 0, y: frame.size.height / 2))
            path?.addLine(to: CGPoint(x: frame.size.width / 2, y: frame.size.height))
            path?.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height / 2))
            path?.addLine(to: CGPoint(x: frame.size.width / 2, y: 0))
            path?.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path!.cgPath
            shapeLayer.fillColor = backColor.cgColor
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = 0.5
            
            transform = CGAffineTransform(scaleX: 0.7, y: 1)
            
            layer.addSublayer(shapeLayer)
        }
    }
}
