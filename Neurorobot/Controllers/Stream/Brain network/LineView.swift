//
//  LineView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 19/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

class LineView: UIView {
    
    private let imageView = UIImageView()
    
    private let sidePadding: CGFloat = 10
    
    var lineWidth: CGFloat = 1
    
    private var didSetup = false
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        let aPath = UIBezierPath()
        aPath.move(to: CGPoint(x: 0, y: 0))
        aPath.addLine(to: CGPoint(x: rect.width - sidePadding, y: rect.height - sidePadding))
        aPath.close()

        UIColor.black.setStroke()
        aPath.lineWidth = lineWidth
        aPath.stroke()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard frame.width != 0, frame.height != 0 else { return }
        guard !didSetup else { return }
        didSetup = true
        
//        setNeedsDisplay()


//        let renderer1 = UIGraphicsImageRenderer(size: CGSize(width: frame.width, height: frame.height))
//        let img1 = renderer1.image { ctx in
//            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
//            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
//            ctx.cgContext.setLineWidth(lineWidth)
//
//            ctx.cgContext.move(to: CGPoint(x: 0, y: 0))
//            ctx.cgContext.addLine(to: CGPoint(x: frame.width - sidePadding, y: frame.height - sidePadding))
//
//            ctx.cgContext.drawPath(using: .fillStroke)
//        }
//
//        imageView.image = img1
    }
    
    func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
//        addSubview(imageView)
//        imageView.fillSuperView()
    }
}
