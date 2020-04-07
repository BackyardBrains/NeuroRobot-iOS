//
//  UIView+Constraints.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 19/03/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

extension UIView {
    func fill(view: UIView, space: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: space.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: space.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -space.bottom),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -space.right),
        ])
    }
    
    func fillSuperView(space: UIEdgeInsets = .zero) {
        guard let view = superview else { return }
        fill(view: view, space: space)
    }
}
