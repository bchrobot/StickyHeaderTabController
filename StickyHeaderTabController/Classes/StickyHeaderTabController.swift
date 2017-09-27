//
//  StickyHeaderTabController.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//  Copyright © 2017 Treble Media, Inc. All rights reserved.
//

import UIKit

public protocol StickyHeaderTabControllerDelegate: class {
    func stickyHeaderTabControllerDidScrollVertically(_ controller: StickyHeaderTabController)
}

open class StickyHeaderTabController: UIViewController {

    // MARK: - Public Properties

    public weak var delegate: StickyHeaderTabControllerDelegate?

    /// The sticky header view.
    public var stickyHeader: StickyHeaderView? {
        didSet {
            oldValue?.removeFromSuperview()

            if let newHeader = stickyHeader {
                view.addSubview(newHeader)
            }

            updateCompoundHeaderHeight()
        }
    }

    /// The optional "hero" view between the header and the tab bar.
    open var hero: StickyHeaderHeroView? {
        didSet {
            oldValue?.removeFromSuperview()

            if let newHero = hero {
                view.addSubview(newHero)
            }

            updateCompoundHeaderHeight()
        }
    }

    /// The content tabs.
    open var tabs: [StickyHeaderContentTabViewController] = [] {
        didSet {
            // Cancel current verticalPanRecognizer (if any)
            verticalPanRecognizer.cancelCurrentGesture()

            // Update titles for tab bar items
            tabBar.reloadData()

            // Update content view controllers
            replace(oldTabs: oldValue, with: tabs)
        }
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Private Properties

    /// The combined height of sticky header, hero, and tab bar.
    /// Could instead be a calculated variable, but then we lose the `didSet` functionality.
    fileprivate var compoundHeaderHeight: CGFloat = 0.0 {
        didSet {
            updateInsetForCompoundHeaderHeight(compoundHeaderHeight)
        }
    }

    /// This represents what the offset would be if it were measured from the bottom of the tab bar.
    /// It does not take into account the sticky header, hero, or tab bar height.
    fileprivate var trueScrollOffset: CGFloat = 0.0

    /// The index of the selected tab
    fileprivate var selectedTabIndex = 0
    fileprivate var selectedTab: StickyHeaderContentTabViewController {
        return tabs[selectedTabIndex]
    }


    /// If there is an active vertical pan gesture, this points to the scrollview where that
    /// gesture began.
    fileprivate weak var activeVerticalTab: StickyHeaderContentTabViewController?

    private let verticalPanRecognizer = UIPanGestureRecognizer()

    // MARK: Views

    /// The ScrollView containing the content tabs.
    fileprivate let horizontalScrollView = UIScrollView()

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
        setUpVerticalPanRecognizer()
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

        // Must be called first to sync scrollViews
        updateCompoundHeaderHeight()

        // view.insertSubview(gradientBackground, at: 0)
    }

    private func setUpVerticalPanRecognizer() {
        view.addGestureRecognizer(verticalPanRecognizer)
        verticalPanRecognizer.delegate = self
        verticalPanRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }

    private func setUpTabBar() {
        view.addSubview(tabBar)
        tabBar.tabDelegate = self
        tabBar.backgroundColor = UIColor(red: 100, green: 0, blue: 0, alpha: 1)
    }

    // MARK: - Private Methods

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
            newTab.scrollView.isScrollEnabled = false
            newTab.scrollViewDelegate = self
        }
        updateInsetForCompoundHeaderHeight(compoundHeaderHeight)

        let selectedItem = IndexPath(item: 0, section: 0)
        tabBar.selectItem(at: selectedItem, animated: false, scrollPosition: .centeredHorizontally)

        // FIXME: vv necessary?
        // view.setNeedsLayout()
    }

    fileprivate func updateCompoundHeaderHeight() {
        var newHeaderHeight: CGFloat = 0.0

        if let header = stickyHeader {
            newHeaderHeight += header.headerHeight
        }

        if let hero = self.hero {
            newHeaderHeight += hero.heroHeight
        }

        newHeaderHeight += tabBar.tabBarHeight

        let isHeaderHeightDifferent = compoundHeaderHeight != newHeaderHeight

        compoundHeaderHeight = newHeaderHeight

        if isHeaderHeightDifferent {
            updateStickyFrames()
        }
    }

    private func updateStickyFrames() {
        // Tactic:
        // 1. Update frame size for everything (move to separate method?)
        // 2. TODO: Calculate new positions of each element based on current "content offset"
        //          This is to ensure the sticky header and tab bar are pinned
        // 3. TODO: Update all frame positions
        // 4. TODO: Pass updated offset to header and hero (for animations -- should be in "scrolled" method)
        // 5. TODO: Pass updated offset to all tabs (should really be in "scrolled" method)

        var currentYOffset: CGFloat = -trueScrollOffset
        let width = view.bounds.width

        // Sticky Header
        if let header = stickyHeader {
            // Stretch instead of scrolling downward
            var headerTop = min(0.0, currentYOffset)
            let stretchHeight = max(0.0, currentYOffset)

            // Pin header to top
            let minTop = header.pinnedHeight - header.headerHeight
            let isPinned = minTop > headerTop
            headerTop = max(headerTop, minTop)

            if let hero = self.hero {
                let headerIndex = view.subviews.index(of: header)!
                let heroIndex = view.subviews.index(of: hero)!

                if isPinned && headerIndex < heroIndex {
                    // Ensure header is on top
                    view.exchangeSubview(at: headerIndex, withSubviewAt: heroIndex)
                } else if !isPinned && headerIndex > heroIndex {
                    // Ensure hero is on top
                    view.exchangeSubview(at: headerIndex, withSubviewAt: heroIndex)
                }
            }

            let headerFrame = CGRect(x: 0.0,
                                     y: headerTop,
                                     width: width,
                                     height: header.headerHeight + stretchHeight)
            header.frame = headerFrame
            currentYOffset += header.headerHeight
        }

        // Hero
        if let hero = self.hero {
            let heroFrame = CGRect(x: 0.0,
                                   y: currentYOffset,
                                   width: width,
                                   height: hero.heroHeight)
            hero.frame = heroFrame
            currentYOffset += hero.heroHeight
        }

        // Update tabBar
        var tabBarTop = currentYOffset
        if let header = self.stickyHeader {
            let headerBottom = header.frame.origin.y + header.frame.size.height
            tabBarTop = max(tabBarTop, headerBottom)
        }
        tabBar.frame = CGRect(x: 0.0,
                              y: tabBarTop,
                              width: width,
                              height: tabBar.tabBarHeight)
    }

    /// Update the content inset + offset of all tabs for a change in compound header height.
    private func updateInsetForCompoundHeaderHeight(_ height: CGFloat) {
        for tab in tabs {
            tab.contentInset.top = height
        }
    }

    /// Very much a WIP menthod.
    fileprivate func handleVerticalScroll() {
        updateStickyFrames()

        let offsetY = trueScrollOffset - compoundHeaderHeight
        for tab in tabs {
            if tab != activeVerticalTab {
                // TODO: Refine this to account for differences in `contentSize`
                tab.contentOffset = CGPoint(x: 0, y: offsetY)
            }
        }

        delegate?.stickyHeaderTabControllerDidScrollVertically(self)
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

    // MARK: - Actions

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            activeVerticalTab = selectedTab
        }

        activeVerticalTab?.scrollView.handlePanGesture(gestureRecognizer)
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
        updateCompoundHeaderHeight()
    }
}

// MARK: - StickyHeaderHeroViewDelegate

extension StickyHeaderTabController: StickyHeaderHeroViewDelegate {
    public func stickyHeaderHeroView(_ stickyHeaderHeroView: StickyHeaderHeroView,
                                     didChangeHeight height: CGFloat) {
        updateCompoundHeaderHeight()
    }
}

// MARK: - UIScrollViewDelegate

extension StickyHeaderTabController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let activeVerticalTab = self.activeVerticalTab,
            scrollView == activeVerticalTab.scrollView {
            trueScrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
            handleVerticalScroll()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension StickyHeaderTabController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
