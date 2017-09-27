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

    let coverImageView = UIImageView()

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
    }

    private func setUpAvatar() {
        addSubview(coverImageView)
        coverImageView.image = UIImage(named: "cover")
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.frame = bounds
        coverImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
