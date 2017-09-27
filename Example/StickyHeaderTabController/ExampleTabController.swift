//
//  ExampleTabController.swift
//  StickyHeaderTabController
//
//  Created by Benjamin Chrobot on 09/21/2017.
//  Copyright (c) 2017 Benjamin Chrobot. All rights reserved.
//

import UIKit
import StickyHeaderTabController

class ExampleTabController: StickyHeaderTabController {

    // MARK: - Properties
    
    private let exampleHeader = ExampleStickyHeaderView()
    private let exampleHero = ExampleStickyHeroView()
    private let exampleTabBar = ExampleTabBar(frame: .zero)

    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
    }

    // MARK: - Setup

    private func commonInit() {
        delegate = self

        stickyHeader = exampleHeader
        hero = exampleHero
        tabBar = exampleTabBar
        tabs = [StatesTabViewController(), ColorsTabViewController()]
    }

    // Private Methods

    fileprivate func updateAvatarSize() {
        let maxValue = exampleHeader.headerHeight
        let minValue = exampleHeader.pinnedHeight
        let currentValue = exampleHero.frame.origin.y

        let percentage = min(max(0, ((currentValue - minValue) / (maxValue - minValue))), 1)
        exampleHero.avatarSizePercentage = percentage
    }

    fileprivate func updateNameLabel() {
        let headerBottom = exampleHeader.frame.origin.y + exampleHeader.frame.size.height

        let heroTop = exampleHero.frame.origin.y
        let heroNameOffset = exampleHero.nameLabel.frame.origin.y
        let nameTop = heroTop + heroNameOffset

        let overlapPx = max(0, headerBottom - nameTop)
        let percentage = min(max(0, (overlapPx / exampleHero.nameLabel.bounds.height)), 1)
        exampleHeader.percentVisibleName = percentage
    }

    fileprivate func updateBlur() {
        let headerBottom = exampleHeader.frame.origin.y + exampleHeader.frame.size.height
        let heroTop = exampleHero.frame.origin.y
        let overlapPx = max(0, headerBottom - heroTop)
        let percentage = min(max(0, (overlapPx / exampleHero.bounds.height)), 1)
        exampleHeader.percentVisibleBlur = percentage
    }
}

extension ExampleTabController: StickyHeaderTabControllerDelegate {
    func stickyHeaderTabControllerDidScrollVertically(_ controller: StickyHeaderTabController) {
        updateAvatarSize()
        updateNameLabel()
        updateBlur()
    }
}
