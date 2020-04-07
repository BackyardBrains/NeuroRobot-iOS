//
//  BrainPickerView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 9/25/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit

final class BrainPickerView: UIView {
    
    // UI
    private let titleLabel = UILabel()
    private let brainPickerView = UIPickerView()
    private let doneButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    // Data
    private var selectedRow: Int = 0
    private var didSetup = false
    
    // Constraints
    private var pickerUpConstraint  : NSLayoutConstraint!
    private var pickerDownConstraint: NSLayoutConstraint!
    
    typealias ChoosenBrainWithPathCallback = ((String?, String?) -> ())

    var choosenBrainWithPath: ChoosenBrainWithPathCallback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let view = superview else { return }
        guard !didSetup else { return }
        didSetup = true
        
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        pickerUpConstraint = bottomAnchor.constraint(equalTo: view.bottomAnchor)
        pickerDownConstraint = topAnchor.constraint(equalTo: view.bottomAnchor)
        pickerDownConstraint.isActive = true
    }
    
    func setupUI() {
        backgroundColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -20).isActive = true
        doneButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
        cancelButton.topAnchor.constraint(equalTo: doneButton.topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: doneButton.bottomAnchor).isActive = true
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.setTitleColor(.black, for: .normal)
        
        let separatorView = UIView()
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor).isActive = true
        separatorView.backgroundColor = .gray
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.topAnchor.constraint(equalTo: doneButton.bottomAnchor).isActive = true
        titleLabel.font = titleLabel.font.withSize(20)
        titleLabel.text = "Select brain:"
        
        addSubview(brainPickerView)
        brainPickerView.translatesAutoresizingMaskIntoConstraints = false
        brainPickerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        brainPickerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        brainPickerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        brainPickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        brainPickerView.delegate = self
        brainPickerView.dataSource = self
        brainPickerView.showsSelectionIndicator = true
    }
    
    func toggle() {
        if pickerUpConstraint.isActive {
            pickerUpConstraint.isActive = false
            pickerDownConstraint.isActive = true
        } else {
            pickerDownConstraint.isActive = false
            pickerUpConstraint.isActive = true
        }
    }
}

// MARK:- Actions
private extension BrainPickerView {
    @objc func doneButtonTapped() {
        choosenBrainWithPath?(Brain.availableBrainPaths()[selectedRow], Brain.availableBrains()[selectedRow])
    }
    
    @objc func cancelButtonTapped() {
        choosenBrainWithPath?(nil, nil)
    }
}

extension BrainPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Brain.availableBrains().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Brain.availableBrains()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}
