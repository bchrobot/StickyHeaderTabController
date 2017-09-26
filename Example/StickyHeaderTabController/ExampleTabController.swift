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

    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
    }

    // MARK: - Setup

    private func commonInit() {
        stickyHeader = exampleHeader
        hero = exampleHero
        tabs = [StatesTabViewController(), ColorsTabViewController()]
    }
}
