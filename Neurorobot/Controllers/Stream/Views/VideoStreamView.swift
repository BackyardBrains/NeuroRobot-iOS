//
//  VideoStreamView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 29/01/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

import UIKit

class VideoStreamView: UIView {
    
    // UI
    private let leftEyeImageView = UIImageView()
    private let rightEyeImageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    private func setupUI() {
        addSubview(leftEyeImageView)
        leftEyeImageView.translatesAutoresizingMaskIntoConstraints = false
        leftEyeImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        leftEyeImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        leftEyeImageView.heightAnchor.constraint(equalTo: leftEyeImageView.widthAnchor).isActive = true
        leftEyeImageView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor).isActive = true
        let constr = NSLayoutConstraint(item: leftEyeImageView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .centerX, multiplier: 1, constant: -5)
        constr.isActive = true
        
        addSubview(rightEyeImageView)
        rightEyeImageView.translatesAutoresizingMaskIntoConstraints = false
        rightEyeImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        rightEyeImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        rightEyeImageView.heightAnchor.constraint(equalTo: rightEyeImageView.widthAnchor).isActive = true
        rightEyeImageView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor).isActive = true
        let constr2 = NSLayoutConstraint(item: rightEyeImageView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .centerX, multiplier: 1, constant: 5)
        constr2.isActive = true
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.hidesWhenStopped = true
    }
}

extension VideoStreamView {
    func setVideo(images: (UIImage, UIImage)) {
        if activityIndicator.isAnimating {
            leftEyeImageView.alpha = 1.0
            rightEyeImageView.alpha = 1.0
            activityIndicator.stopAnimating()
        }
        
        leftEyeImageView.image = images.0
        rightEyeImageView.image = images.1
    }
    
    func setProgress() {
        leftEyeImageView.alpha = 0.4
        rightEyeImageView.alpha = 0.4
        activityIndicator.startAnimating()
    }
}
