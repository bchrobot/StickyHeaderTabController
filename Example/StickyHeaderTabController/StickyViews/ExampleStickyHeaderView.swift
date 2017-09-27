//
//  ExampleStickyHeaderView.swift
//  StickyHeaderTabController_Example
//
//  Created by Benjamin Chrobot on 9/25/17.
//  Copyright (c) 2017 Benjamin Chrobot. All rights reserved.
//

import UIKit
import StickyHeaderTabController

class ExampleStickyHeaderView: StickyHeaderView {

    // MARK: - Properties

    var percentVisibleName: CGFloat = 0.0 {
        didSet {
            if percentVisibleName != oldValue {
                updateNameFrame()
            }
        }
    }

    var percentVisibleBlur: CGFloat = 0.0 {
        didSet {
            blurEffectView.alpha = percentVisibleBlur
        }
    }

    let coverImageView = UIImageView()
    let nameLabel = UILabel()
    let blurEffectView = UIVisualEffectView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func commonSetup() {
        setUpAvatar()
        setUpBlur()
        setUpNameLabel()
    }

    private func setUpAvatar() {
        addSubview(coverImageView)
        coverImageView.image = UIImage(named: "cover")
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.frame = bounds
        coverImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    // Blur effect on top of coverImageView
    private func setUpBlur() {
        let blurEffect = UIBlurEffect(style: .dark)
        addSubview(blurEffectView)
        blurEffectView.effect = blurEffect

        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        percentVisibleBlur = 0.0
    }

    private func setUpNameLabel() {
        addSubview(nameLabel)
        nameLabel.text = "Mr. McNamey Name"
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.sizeToFit()
        updateNameFrame()
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        updateNameFrame()
    }

    // MARK: - Private Methods

    private func updateNameFrame() {
        let statusBarHeight: CGFloat = 10.0
        let baseline = bounds.height - pinnedHeight + statusBarHeight
        let minYValue = ((pinnedHeight - nameLabel.bounds.height) / 2.0) + baseline
        let maxYValue = bounds.height

        let yValue = minYValue + ((maxYValue - minYValue) * (1.0 - percentVisibleName))
        nameLabel.frame = CGRect(x: 0,
                                 y: yValue,
                                 width: bounds.width,
                                 height: nameLabel.bounds.height)
    }
}
