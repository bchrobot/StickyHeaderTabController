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

    /// The combined height of sticky header, hero, and tab bar.
    /// Could instead be a calculated variable, but then we lose the `didSet` functionality.
    fileprivate var compoundHeaderHeight: CGFloat = 0.0 {
        didSet {
            updateOffsetForCompoundHeaderHeight(compoundHeaderHeight)
        }
    }

    /// This represents what the offset would be if it were measured from the bottom of the tab bar.
    /// It does not take into account the sticky header, hero, or tab bar height.
    fileprivate var trueScrollOffset: CGFloat = 0.0

    private let tabBarHeight: CGFloat = 60.0

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Views

    /// The ScrollView containing the content tabs.
    private let horizontalScrollView = UIScrollView()

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
        // Tactic:
        // 1. Update frame size for everything (move to separate method?)
        // 2. TODO: Calculate new positions of each element based on current "content offset"
        //          This is to ensure the sticky header and tab bar are pinned
        // 3. TODO: Update all frame positions
        // 4. TODO: Pass updated offset to header and hero (for animations -- should be in "scrolled" method)
        // 5. TODO: Pass updated offset to all tabs (should really be in "scrolled" method)

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

        compoundHeaderHeight = currentYOffset
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
            horizontalScrollView.addSubview(newTab.view)
            newTab.didMove(toParentViewController: self)

            // Tab-specific configuration
            // profileTab.scrollViewDelegate = self
            // profileTab.scrollView.panGestureRecognizer.isEnabled = false
        }
        updateOffsetForCompoundHeaderHeight(compoundHeaderHeight)

        let selectedItem = IndexPath(item: 0, section: 0)
        tabBar.selectItem(at: selectedItem, animated: false, scrollPosition: .centeredHorizontally)

        // FIXME: vv necessary?
        // view.setNeedsLayout()
    }

    /// Update the content inset + offset of all tabs for a change in compound header height.
    private func updateOffsetForCompoundHeaderHeight(_ height: CGFloat) {
        for tab in tabs {
            tab.contentInset.top = height
        }
    }

    /// Very much a WIP menthod.
    private func handleScroll() {

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
