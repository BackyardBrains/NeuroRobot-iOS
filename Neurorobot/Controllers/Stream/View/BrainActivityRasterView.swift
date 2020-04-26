//
//  BrainActivityRasterView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 10/3/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

import UIKit
import AsyncTimer

final class BrainActivityRasterView: UIView {

    // UI
    private var titleLabel      = UILabel()
    private let titlesStackView = UIStackView()
    private var scrollView      = UIScrollView()
    private var timelineView    = UIView()
    private var backLineViews   = [UIView]()
    private var firingLines     = [UIView]()
    
    // Constraints
    private var firingLineLeadingConstraints = [NSLayoutConstraint]()
    private var firingLineTrailingConstraints = [NSLayoutConstraint]()

    // Data
    private var didSetup = false
    private var canSetup = false
    private var isRunning = false
    private var didConfigured = false
    private var scrollOffset: CGFloat = 0
    private var maxSeconds = 0
    private var relativeTimelimeOriginX: CGFloat = 0
    private var offsetForOneInterval: CGFloat!
    private var offsetForOneSecond: CGFloat!

    // Timer
    private var timer: AsyncTimer?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }
    
    deinit {
        print("deinit: " + String(describing: self))
    }

    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.text = "Brain raster activity"

        addSubview(titlesStackView)
        titlesStackView.translatesAutoresizingMaskIntoConstraints = false
        titlesStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        titlesStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titlesStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6).isActive = true
        titlesStackView.axis = .vertical
        titlesStackView.distribution = .fillEqually
        titlesStackView.alignment = .fill

        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: titlesStackView.trailingAnchor, constant: 5).isActive = true
        scrollView.topAnchor.constraint(equalTo: titlesStackView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: titlesStackView.bottomAnchor, constant: 10).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        scrollView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        scrollView.isScrollEnabled = false

        addSubview(timelineView)
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        timelineView.centerXAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -50).isActive = true
        timelineView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        timelineView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1.1).isActive = true
        timelineView.backgroundColor = .gray
        timelineView.isHidden = true
    }

    func configureUI(brain: Brain) {
        
        timelineView.isHidden = false
        didConfigured = false
        didSetup = false
        canSetup = false
        maxSeconds = 0
        
        let brainValues = brain.getFiringNeurons()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.removeGraphInternal()
            
            for i in 0..<brainValues.count {
                
                let neuronNumberLabel = UILabel()
                self.titlesStackView.addArrangedSubview(neuronNumberLabel)
                neuronNumberLabel.textAlignment = .center
                neuronNumberLabel.font = neuronNumberLabel.font.withSize(6)
                neuronNumberLabel.text = String(i + 1)
                
                let backLineView = UIView()
                self.addSubview(backLineView)
                backLineView.translatesAutoresizingMaskIntoConstraints = false
                backLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                backLineView.leadingAnchor.constraint(equalTo: self.titlesStackView.trailingAnchor, constant: 2).isActive = true
                backLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
                backLineView.centerYAnchor.constraint(equalTo: neuronNumberLabel.centerYAnchor).isActive = true
                backLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
                
                self.backLineViews.append(backLineView)
                
                let firingLineView = UIView()
                self.scrollView.addSubview(firingLineView)
                firingLineView.translatesAutoresizingMaskIntoConstraints = false
                firingLineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
                firingLineView.centerYAnchor.constraint(equalTo: self.backLineViews[i].centerYAnchor).isActive = true
                let trailingAnchorConstraint = firingLineView.trailingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 1000)
                trailingAnchorConstraint.isActive = true
                let leadingAnchorConstraint = firingLineView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor)
                leadingAnchorConstraint.isActive = true
                firingLineView.backgroundColor = .red
                firingLineView.isHidden = true
                
                self.firingLines.append(firingLineView)
                self.firingLineLeadingConstraints.append(leadingAnchorConstraint)
                self.firingLineTrailingConstraints.append(trailingAnchorConstraint)
            }
            
            self.canSetup = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if canSetup {
            canSetup = false
            if !didSetup {
                didSetup = true

                relativeTimelimeOriginX = scrollView.frame.width - 50
                scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
                offsetForOneInterval = scrollView.frame.width / 1000
                offsetForOneSecond = scrollView.frame.width / 10
                spreadGraph()

                didConfigured = true
            }
        }
    }

    private func spreadGraph() {
        let minSeconds = maxSeconds
        maxSeconds = maxSeconds + 10

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            for i in minSeconds..<self.maxSeconds {
                let timeLabel = UILabel()
                self.scrollView.addSubview(timeLabel)
                timeLabel.translatesAutoresizingMaskIntoConstraints = false
                timeLabel.centerYAnchor.constraint(equalTo: self.backLineViews.last!.centerYAnchor, constant: 10).isActive = true
                timeLabel.centerXAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: self.relativeTimelimeOriginX + CGFloat(i) * self.offsetForOneSecond).isActive = true
                timeLabel.text = String(i)
                timeLabel.font = timeLabel.font.withSize(9)
            }
        }
    }

    private func playTimeline() {

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.timer = AsyncTimer(queue: DispatchQueue.main, interval: .milliseconds(10), repeats: true) { [weak self] in
                guard let self = self else { return }
                guard self.didConfigured else { return }
                guard self.isRunning else { return }
                
                self.scrollOffset = self.scrollView.contentOffset.x + self.offsetForOneInterval
                
                self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width + self.scrollOffset, height: self.scrollView.frame.height)
                
                var point = self.scrollView.contentOffset
                point.x = self.scrollOffset
                self.scrollView.contentOffset = point
                
                if self.scrollOffset > CGFloat(self.maxSeconds - 6) * self.offsetForOneSecond {
                    self.spreadGraph()
                }
                
                for i in 0..<self.firingLineTrailingConstraints.count {
                    if !self.firingLines[i].isHidden {
                        let trailingConstraint = self.firingLineTrailingConstraints[i]
                        trailingConstraint.constant = point.x + self.relativeTimelimeOriginX
                    }
                }
            }
            self.timer!.start()
        }
    }

    private func removeGraphInternal() {

        firingLineLeadingConstraints.removeAll()
        firingLineTrailingConstraints.removeAll()

        for view in firingLines {
            view.removeFromSuperview()
        }
        for view in backLineViews {
            view.removeFromSuperview()
        }
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        for view in titlesStackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        firingLines.removeAll()
        backLineViews.removeAll()
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollOffset = 0
    }

    func play() {
        guard !isRunning else { return }
        isRunning = true
        
        scrollView.isScrollEnabled = false
        playTimeline()
    }

    func pause() {
        defer { isRunning = false }
        
        scrollView.isScrollEnabled = true
        guard let timer = timer else { return }
        timer.stop()
    }
    
    func stop() {
        pause()
        DispatchQueue.main.async { [weak self] in
            self?.removeGraphInternal()
        }
    }

    func updateActivityValues(brain: Brain) {
        let firingNeurons = brain.getFiringNeurons()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.didConfigured else { return }
            
            guard firingNeurons.count == self.titlesStackView.arrangedSubviews.count else { return }
            
            for i in 0..<firingNeurons.count {

                if firingNeurons[i] {
                    if self.firingLines[i].isHidden {
                        let timelimeOriginX = self.scrollOffset + self.relativeTimelimeOriginX
                        self.firingLineLeadingConstraints[i].constant = timelimeOriginX
                        self.firingLineTrailingConstraints[i].constant = timelimeOriginX
                        self.firingLines[i].isHidden = false
                    }
                } else if !self.firingLines[i].isHidden {

                    let timelimeOriginX = self.scrollOffset + self.relativeTimelimeOriginX
                    let view = UIView()
                    self.scrollView.addSubview(view)
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.heightAnchor.constraint(equalToConstant: self.firingLines[i].frame.height).isActive = true
                    view.centerYAnchor.constraint(equalTo: self.backLineViews[i].centerYAnchor).isActive = true
                    view.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: self.firingLines[i].frame.origin.x).isActive = true
                    view.trailingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: timelimeOriginX).isActive = true
                    view.backgroundColor = .red

                    self.firingLines[i].isHidden = true
                }
            }
        }
    }
}
