//
//  ExampleStickyHeroView.swift
//  StickyHeaderTabController_Example
//
//  Created by Benjamin Chrobot on 9/25/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import StickyHeaderTabController

class ExampleStickyHeroView: StickyHeaderHeroView {

    // MARK: - Properties

    let avatarImageView = UIImageView()
    let nameLabel = UILabel()

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
        backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.4, alpha: 1.0)

        setUpAvatar()
        setUpNameLabel()
    }

    private func setUpAvatar() {
        addSubview(avatarImageView)
        avatarImageView.image = UIImage(named: "avatar")
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.backgroundColor = .white

        avatarImageView.layer.cornerRadius = 10.0
        avatarImageView.layer.masksToBounds = true
    }

    private func setUpNameLabel() {
        addSubview(nameLabel)
        nameLabel.text = "Mr. McNamey Name"
    }

    override func layoutSubviews() {
        // Constants
        let marginWidth: CGFloat = 10.0

        // Avatar frame
        let avatarSize: CGFloat = 120.0
        let avatarTopOffset: CGFloat = -35.0
        avatarImageView.frame = CGRect(x: marginWidth,
                                       y: avatarTopOffset,
                                       width: avatarSize,
                                       height: avatarSize)

        // Name label frame
        let nameHeight: CGFloat = 30.0
        let nameTopOffset: CGFloat = 10.0
        nameLabel.frame = CGRect(x: marginWidth,
                                 y: avatarTopOffset + avatarSize + nameTopOffset,
                                 width: bounds.width - (2.0 * marginWidth),
                                 height: nameHeight)
        nameLabel.autoresizingMask = [.flexibleWidth]
    }
}
