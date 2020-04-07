//
//  NeuronContactView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 24/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

class NeuronContactView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        
        layer.borderWidth = bounds.width > 5 ? 1.5 : 0.5
        layer.borderColor = UIColor.black.cgColor
        
        backgroundColor = .white
    }
}
