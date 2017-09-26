//
//  StickyHeaderTabController.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//  Copyright © 2017 Treble Media, Inc. All rights reserved.
//

import UIKit

open class StickyHeaderTabController: UIViewController {

    // MARK: - Public Properties

    /// The sticky header view.
    public var stickyHeader: StickyHeaderView? {
        didSet {
            oldValue?.removeFromSuperview()

            if let newHeader = stickyHeader {
                view.addSubview(newHeader)
            }

            redrawWithOffsets()
        }
    }

    /// The optional "hero" view between the header and the tab bar.
    open var hero: StickyHeaderHeroView? {
        didSet {
            oldValue?.removeFromSuperview()

            if let newHero = hero {
                view.addSubview(newHero)
            }

            redrawWithOffsets()
        }
    }

    /// The content tabs.
    open var tabs: [StickyHeaderContentTabViewController] = [] {
        didSet {
            // Update titles for tab bar items
            tabBar.reloadData()

            // Update content view controllers
            replace(oldTabs: oldValue, with: tabs)
        }
    }

    // MARK: - Private Properties

    private let tabBarHeight: CGFloat = 60.0

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Views

    /// The ScrollView containing the content tabs.
    private let horizontalScrollView = UIScrollView()

    /// The content wrapper inside `horizontalScrollView`.
    private let contentView = UIView()

    /// The tab bar showing the titles of each content tab.
    private let tabBar = StickyHeaderTabBarView(frame: .zero)

    // MARK: - ViewController lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()

        setUpCommonElements()
    }

    // MARK: - Setup

    /// Set up common elements like the containing scrollview, the tab bar, etc.
    private func setUpCommonElements() {
        setUpScrollView()
        setUpTabBar()
    }

    private func setUpScrollView() {
        view.addSubview(horizontalScrollView)
        horizontalScrollView.showsHorizontalScrollIndicator = false
        horizontalScrollView.alwaysBounceHorizontal = false
        horizontalScrollView.isPagingEnabled = true
        horizontalScrollView.delegate = self
        horizontalScrollView.bounces = false

        horizontalScrollView.frame = view.bounds
        horizontalScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        horizontalScrollView.addSubview(contentView)
        // TODO: set frame correctly?

        // view.insertSubview(gradientBackground, at: 0)
    }

    private func setUpTabBar() {
        view.addSubview(tabBar)
        tabBar.tabDelegate = self
        tabBar.backgroundColor = UIColor(red: 100, green: 0, blue: 0, alpha: 1)
    }

    // MARK: - Private Methods

    private func redrawWithOffsets() {
        var currentYOffset:CGFloat = 0.0
        let width = view.bounds.width

        // Sticky Header
        if let header = stickyHeader {
            let headerHeight: CGFloat = 170.0
            let headerFrame = CGRect(x: 0.0,
                                     y: currentYOffset,
                                     width: width,
                                     height: headerHeight)
            header.frame = headerFrame
            currentYOffset += headerHeight
        }

        // Hero
        if let hero = self.hero {
            let heroHeight: CGFloat = 200.0
            let heroFrame = CGRect(x: 0.0,
                                   y: currentYOffset,
                                   width: width,
                                   height: heroHeight)
            hero.frame = heroFrame
            currentYOffset += heroHeight
        }

        // Update tabBar
        tabBar.frame = CGRect(x: 0.0,
                              y: currentYOffset,
                              width: width,
                              height: tabBarHeight)
        currentYOffset += tabBarHeight

        // TODO: Calculate new positions of each element based on current "content offset"
        // TODO: Update all frames
        // TODO: Pass updated offset to header and hero
        // TODO: Pass updated offset to all tabs
    }

    private func replace(oldTabs: [StickyHeaderContentTabViewController],
                         with newTabs: [StickyHeaderContentTabViewController]) {
        // Remove old tabs
        for oldTab in oldTabs {
            // TODO: compare old and new values to make this smarter
            oldTab.willMove(toParentViewController: nil)
            oldTab.view.removeFromSuperview()
            oldTab.removeFromParentViewController()
        }

        // Add new tabs
        for newTab in newTabs {
            // Notify VCs of changes
            addChildViewController(newTab)
            contentView.addSubview(newTab.view)
            newTab.didMove(toParentViewController: self)

            // Tab-specific configuration
            // profileTab.scrollViewDelegate = self
            // profileTab.scrollView.panGestureRecognizer.isEnabled = false
        }
    }

    // MARK: - Overrides

    open override func viewDidLayoutSubviews() {
        // Position tabs
        let tabSize = view.bounds
        horizontalScrollView.contentSize = CGSize(width: CGFloat(tabs.count) * tabSize.width,
                                                  height: tabSize.height)
        for (index, tab) in tabs.enumerated() {
            // Position newTab views
            let leftOffset = CGFloat(index) * tabSize.width
            tab.view.frame = CGRect(x: leftOffset,
                                    y: 0,
                                    width: tabSize.width,
                                    height: tabSize.height)
        }
    }
}

// MARK: - StickyHeaderTabBarViewDelegate

extension StickyHeaderTabController: StickyHeaderTabBarViewDelegate {
    public func stickyHeaderTabBarViewNumberOfTabs(_ stickyHeaderTabBarView: StickyHeaderTabBarView) -> Int {
        return tabs.count
    }

    public func stickyHeaderTabBarView(_ stickyHeaderTabBarView: StickyHeaderTabBarView,
                                       titleAtIndex index: Int) -> String? {
        return tabs[index].title
    }
}

// MARK: - StickyHeaderViewDelegate

extension StickyHeaderTabController: StickyHeaderViewDelegate {
    public func stickyHeaderView(_ stickyHeaderView: StickyHeaderView,
                                 didChangeHeight height: CGFloat) {
        // TODO: write this
    }
}

// MARK: - StickyHeaderHeroViewDelegate

extension StickyHeaderTabController: StickyHeaderHeroViewDelegate {
    public func stickyHeaderHeroView(_ stickyHeaderHeroView: StickyHeaderHeroView,
                                     didChangeHeight height: CGFloat) {
        // TODO: write this
    }
}

// MARK: - UIScrollViewDelegate

extension StickyHeaderTabController: UIScrollViewDelegate {

}
