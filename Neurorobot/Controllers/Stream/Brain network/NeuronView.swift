//
//  NeuronView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 19/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

class NeuronView: UIView {
    
    private let numberLabel = UILabel()
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = bounds.width / 2
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        
        addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.fillSuperView(space: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont.systemFont(ofSize: 10)
        
        backgroundColor = .appBeige
    }
}

extension NeuronView {
    func setNumber(number: Int) {
        numberLabel.text = String(number)
    }
    
    func firing(isFiring: Bool = false) {
        backgroundColor = isFiring ? .appGreen : .appBeige
    }
}
