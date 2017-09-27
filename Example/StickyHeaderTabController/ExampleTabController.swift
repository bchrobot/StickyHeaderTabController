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
}

extension ExampleTabController: StickyHeaderTabControllerDelegate {
    func stickyHeaderTabControllerDidScrollVertically(_ controller: StickyHeaderTabController) {
        updateAvatarSize()
    }
}
