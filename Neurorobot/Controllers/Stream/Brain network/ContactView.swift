//
//  ContactView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 23/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

class ContactView: UIView {
    
    private var numberLabel: UILabel {
        let numberLabel = UILabel()
        addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.fillSuperView(space: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont.systemFont(ofSize: 8)
        return numberLabel
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor
        
        backgroundColor = .appYellow
    }
}

extension ContactView {
    func setNumber(number: Int) {
        numberLabel.text = String(number)
    }
}
