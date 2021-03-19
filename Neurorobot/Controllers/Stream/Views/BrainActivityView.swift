//
//  BrainActivityView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 10/2/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit


final class BrainActivityView: UIView {
    
    // UI
    private var titleLabel = UILabel()
    private var barStackView = UIStackView()
    private var titlesStackView = UIStackView()
    private var firingBarViews = [UIView]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    private func setupUI() {
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.text = "Brain activity"
        
        let verticalStackView = UIStackView()
        addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        verticalStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6).isActive = true
        verticalStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 5
        
        verticalStackView.addArrangedSubview(barStackView)
        barStackView.axis = .horizontal
        barStackView.distribution = .fillEqually
        barStackView.alignment = .fill
        barStackView.spacing = 5
        
        verticalStackView.addArrangedSubview(titlesStackView)
        titlesStackView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        titlesStackView.axis = .horizontal
        titlesStackView.distribution = .fillEqually
        titlesStackView.alignment = .fill
        titlesStackView.spacing = 5
    }
    
    func configureUI(brain: Brain) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.removeGraphInternal()
            
            let brainValues = brain.getFiringNeurons()
            
            for i in 0..<brainValues.count {
                let backView = UIView()
                self.barStackView.addArrangedSubview(backView)
                backView.backgroundColor = .lightGray
                
                
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                backView.addSubview(view)
                view.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
                view.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
                view.backgroundColor = .red
                view.isHidden = true
                
                let neuronNumberLabel = UILabel()
                self.titlesStackView.addArrangedSubview(neuronNumberLabel)
                neuronNumberLabel.textAlignment = .center
                neuronNumberLabel.font = neuronNumberLabel.font.withSize(7)
                neuronNumberLabel.text = String(i + 1)
                
                self.firingBarViews.append(view)
            }
        }
    }
    
    private func removeGraphInternal() {
        
        for arrangedView in self.barStackView.arrangedSubviews {
            arrangedView.removeFromSuperview()
            self.firingBarViews.removeAll()
        }
        
        for arrangedView in self.titlesStackView.arrangedSubviews {
            arrangedView.removeFromSuperview()
        }
    }
    
    func removeGraph() {
        DispatchQueue.main.async { [weak self] in
            self?.removeGraphInternal()
        }
    }
    
    func updateActivityValues(brain: Brain) {
        let firingNeurons = brain.getFiringNeurons()
        guard firingNeurons.count == firingBarViews.count else { return }
        
        for i in 0..<firingBarViews.count {
            firingBarViews[i].isHidden = !firingNeurons[i]
        }
    }
}
