//
//  StickyHeaderTabController.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//

import UIKit

public protocol StickyHeaderTabControllerDelegate: class {
    func stickyHeaderTabControllerDidScrollVertically(_ controller: StickyHeaderTabController)
}

open class StickyHeaderTabController: UIViewController {

    // MARK: - Public Properties

    public weak var delegate: StickyHeaderTabControllerDelegate?

    /// The sticky header view.
    public var stickyHeader: StickyHeaderView = StickyHeaderView() {
        didSet {
            didSetStickyHeader(stickyHeader, oldHeader: oldValue)
        }
    }

    /// The optional "hero" view between the header and the tab bar.
    public var hero: UIView = UIView() {
        didSet {
            didSetHero(hero, oldHero: oldValue)
        }
    }

    /// The tab bar showing the titles of each content tab.
    public var tabBar: StickyHeaderTabBarView = StickyHeaderTabBarView(frame: .zero) {
        didSet {
            didSetTabBar(tabBar, oldTabBar: oldValue)
        }
    }

    /// The content tabs.
    public var tabs: [StickyHeaderContentTabViewController] = [] {
        didSet {
            didSetTabs(tabs, oldValue: oldValue)
        }
    }

    /// The index of the selected tab
    public var selectedIndex = NSNotFound

    public var selectedTab: StickyHeaderContentTabViewController? {
        get {
            // Safely access by index
            return tabs.indices.contains(selectedIndex) ? tabs[selectedIndex] : nil
        }
        set {
            if let newSelectedTab = newValue,
                let newSelectedIndex = tabs.index(of: newSelectedTab) {
                selectedIndex = newSelectedIndex
            }
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
    private var lastHeaderHeight: CGFloat = 0.0
    private var lastHeroHeight: CGFloat = 0.0
    private var lastTabBarHeight: CGFloat = 0.0

    /// This represents what the offset would be if it were measured from the bottom of the tab bar.
    /// It does not take into account the sticky header, hero, or tab bar height.
    fileprivate var trueScrollOffset: CGFloat = 0.0

    /// If there is an active vertical pan gesture, this points to the scrollview where that
    /// gesture began.
    fileprivate weak var activeVerticalTab: StickyHeaderContentTabViewController?

    private let verticalPanRecognizer = UIPanGestureRecognizer()

    // MARK: AutoLayout magic

    /// Layout guide for positioning sticky elements
    private let stickyLayoutGuide = UILayoutGuide()

    /// Top offset for `stickyLayoutGuide`. Used in conjunction with scrolling of tab content.
    private var stickyGuideTopConstraint: NSLayoutConstraint!

    /// Height of `stickyLayoutGuide`. Updated from `viewDidLayoutSubviews()` if any sticky view
    /// has changed it's height.
    private var stickyGuideHeightConstraint: NSLayoutConstraint!

    /// Offset between the top of `stickyLayoutGuide` and the top of `hero` view.
    private var heroTopOffsetConstraint: NSLayoutConstraint!

    // MARK: Views

    /// The ScrollView containing the content tabs.
    fileprivate let horizontalScrollView = UIScrollView()

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
        setUpLayoutGuide()

        [stickyHeader, hero, tabBar].forEach { stickyView in
            view.addSubview(stickyView)
        }

        didSetStickyHeader(stickyHeader, oldHeader: stickyHeader)
        didSetHero(hero, oldHero: hero)
        didSetTabBar(tabBar, oldTabBar: tabBar)

        // Must be called first to sync scrollViews
        updateCompoundHeaderHeight()

        // Correct layering of header and hero
        updateStickyViewLayering()
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

        // view.insertSubview(gradientBackground, at: 0)
    }

    private func setUpVerticalPanRecognizer() {
        view.addGestureRecognizer(verticalPanRecognizer)
        verticalPanRecognizer.delegate = self
        verticalPanRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }

    private func setUpLayoutGuide() {
        view.addLayoutGuide(stickyLayoutGuide)
        stickyLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stickyLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        // Top offset
        stickyGuideTopConstraint = stickyLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor)
        stickyGuideTopConstraint.isActive = true

        // Height
        stickyGuideHeightConstraint = stickyLayoutGuide.heightAnchor.constraint(equalToConstant: 0)
        stickyGuideHeightConstraint.isActive = true
    }

    // MARK: - Private Methods

    private func didSetStickyHeader(_ newHeader: StickyHeaderView, oldHeader: StickyHeaderView) {
        oldHeader.removeFromSuperview()
        view.addSubview(newHeader)

        newHeader.translatesAutoresizingMaskIntoConstraints = false
        newHeader.leadingAnchor.constraint(equalTo: stickyLayoutGuide.leadingAnchor).isActive = true
        newHeader.trailingAnchor.constraint(equalTo: stickyLayoutGuide.trailingAnchor).isActive = true

        let topStretchConstraint = newHeader.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor)
        topStretchConstraint.isActive = true

        let pinnedConstraint = newHeader.bottomAnchor.constraint(greaterThanOrEqualTo: view.topAnchor)
        pinnedConstraint.constant = newHeader.pinnedHeight
        pinnedConstraint.isActive = true

        setBottomStretchConstraints()
        setTabBarConstraints()

        updateCompoundHeaderHeight()
    }

    private func didSetHero(_ newHero: UIView, oldHero: UIView) {
        oldHero.removeFromSuperview()
        view.addSubview(newHero)

        newHero.translatesAutoresizingMaskIntoConstraints = false
        newHero.leadingAnchor.constraint(equalTo: stickyLayoutGuide.leadingAnchor).isActive = true
        newHero.trailingAnchor.constraint(equalTo: stickyLayoutGuide.trailingAnchor).isActive = true

        heroTopOffsetConstraint = newHero.topAnchor.constraint(equalTo: stickyLayoutGuide.topAnchor)
        heroTopOffsetConstraint.constant = stickyHeader.bounds.height
        heroTopOffsetConstraint.isActive = true

        setBottomStretchConstraints()
        setTabBarConstraints()

        updateCompoundHeaderHeight()
    }

    private func didSetTabBar(_ newTabBar: StickyHeaderTabBarView,
                              oldTabBar: StickyHeaderTabBarView) {
        oldTabBar.removeFromSuperview()
        view.addSubview(tabBar)

        tabBar.tabDelegate = self
        tabBar.tabDataSource = self

        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.leadingAnchor.constraint(equalTo: stickyLayoutGuide.leadingAnchor).isActive = true
        tabBar.trailingAnchor.constraint(equalTo: stickyLayoutGuide.trailingAnchor).isActive = true

        setTabBarConstraints()

        updateCompoundHeaderHeight()
    }

    private func setBottomStretchConstraints() {
        let bottomStretchConstraint = stickyHeader.bottomAnchor.constraint(equalTo: hero.topAnchor)
        bottomStretchConstraint.priority = 750
        bottomStretchConstraint.isActive = true
    }

    private func setTabBarConstraints() {
        let tabBarTopConstraint = tabBar.topAnchor.constraint(equalTo: hero.bottomAnchor)
        tabBarTopConstraint.priority = 250.0
        tabBarTopConstraint.isActive = true

        let tabBarPinnedConstraint =
            tabBar.topAnchor.constraint(greaterThanOrEqualTo: stickyHeader.bottomAnchor)
        tabBarPinnedConstraint.priority = UILayoutPriorityDefaultHigh
        tabBarPinnedConstraint.isActive = true
    }

    private func didSetTabs(_ tabs: [StickyHeaderContentTabViewController],
                            oldValue: [StickyHeaderContentTabViewController]) {
        // Cancel current verticalPanRecognizer (if any)
        verticalPanRecognizer.cancelCurrentGesture()

        // Update content view controllers
        replace(oldTabs: oldValue, with: tabs)

        // Update titles for tab bar items
        tabBar.reloadData()

        selectedIndex = tabs.count > 0 ? 0 : NSNotFound
        if selectedIndex != NSNotFound {
            let selectedIndexPath = IndexPath(item: selectedIndex, section: 0)
            tabBar.selectItem(at: selectedIndexPath,
                              animated: false,
                              scrollPosition: .centeredHorizontally)
        }
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
            newTab.scrollView.isScrollEnabled = false
            newTab.scrollViewDelegate = self
        }
        updateInsetForCompoundHeaderHeight(compoundHeaderHeight)
    }

    fileprivate func updateCompoundHeaderHeight() {
        var newHeaderHeight: CGFloat = 0.0

        newHeaderHeight += stickyHeader.bounds.height
        newHeaderHeight += hero.bounds.height
        newHeaderHeight += tabBar.bounds.height

        compoundHeaderHeight = newHeaderHeight
    }

    private func updateStickyViewLayering() {
        let currentYOffset: CGFloat = -trueScrollOffset

        // Pin header to top
        var headerTop = min(0.0, currentYOffset)
        let minTop = stickyHeader.pinnedHeight - stickyHeader.bounds.height
        let isPinned = minTop > headerTop
        headerTop = max(headerTop, minTop)

        let headerIndex = view.subviews.index(of: stickyHeader)!
        let heroIndex = view.subviews.index(of: hero)!

        if isPinned && headerIndex < heroIndex {
            // Ensure header is on top
            view.exchangeSubview(at: headerIndex, withSubviewAt: heroIndex)
        } else if !isPinned && headerIndex > heroIndex {
            // Ensure hero is on top
            view.exchangeSubview(at: headerIndex, withSubviewAt: heroIndex)
        }
    }

    /// Update the content inset + offset of all tabs for a change in compound header height.
    private func updateInsetForCompoundHeaderHeight(_ height: CGFloat) {
        for tab in tabs {
            tab.contentInset.top = height
        }
    }

    /// Very much a WIP menthod.
    fileprivate func handleVerticalScroll() {
        updateStickyViewLayering()

        stickyGuideTopConstraint?.constant = -trueScrollOffset

        let offsetY = trueScrollOffset - compoundHeaderHeight
        for tab in tabs {
            if tab != activeVerticalTab {
                // TODO: Refine this to account for differences in `contentSize`
                tab.contentOffset = CGPoint(x: 0, y: offsetY)
            }
        }

        delegate?.stickyHeaderTabControllerDidScrollVertically(self)
    }

    fileprivate func scrollToTabIndex(_ tabIndex: Int, animated: Bool = true) {
        if tabIndex < 0 || tabs.count <= tabIndex {
            return
        }

        let xOffset = CGFloat(tabIndex) * horizontalScrollView.bounds.width
        let targetOffset = CGPoint(x: xOffset, y: 0)
        horizontalScrollView.setContentOffset(targetOffset, animated: animated)

        selectedIndex = tabIndex
    }

    // MARK: - Overrides

    open override func viewDidLayoutSubviews() {
        // `view` bounds have been set, so we need to position and size our tabs
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

        var doesNeedUpdate = false
        let isBouncing = trueScrollOffset < 0
        if stickyHeader.bounds.height != lastHeaderHeight && !isBouncing {
            doesNeedUpdate = true

            heroTopOffsetConstraint.constant = stickyHeader.bounds.height
        }
        lastHeaderHeight = stickyHeader.bounds.height

        if hero.bounds.height != lastHeroHeight {
            doesNeedUpdate = true
        }
        lastHeroHeight = hero.bounds.height

        if tabBar.bounds.height != lastTabBarHeight {
            doesNeedUpdate = true
        }
        lastTabBarHeight = tabBar.bounds.height

        if doesNeedUpdate {
            var newHeaderHeight: CGFloat = 0.0

            newHeaderHeight += stickyHeader.bounds.height
            newHeaderHeight += hero.bounds.height
            newHeaderHeight += tabBar.bounds.height

            compoundHeaderHeight = newHeaderHeight

            stickyGuideHeightConstraint.constant = compoundHeaderHeight
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
    public func stickyHeaderTabBarView(_ stickyHeaderTabBarView: StickyHeaderTabBarView,
                                tabSelectedAtIndex index: Int) {
        scrollToTabIndex(index, animated: true)
    }
}

extension StickyHeaderTabController: StickyHeaderTabBarViewDataSource {
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

// MARK: - UIScrollViewDelegate

extension StickyHeaderTabController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.horizontalScrollView {
            // Updating tab bar for horizontal swiping happens in scrollViewDidEndDecelerating(_:)
        } else if let activeVerticalTab = self.activeVerticalTab,
            scrollView == activeVerticalTab.scrollView {
            trueScrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
            handleVerticalScroll()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.horizontalScrollView {
            let tabWidth = scrollView.bounds.width
            let newTabIndex = Int(floor((scrollView.contentOffset.x - tabWidth / 2.0) / tabWidth) + 1)

            if  newTabIndex != selectedIndex {
                selectedIndex = newTabIndex
            }

            tabBar.setTabIndex(newTabIndex, animated: true)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension StickyHeaderTabController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false //true
    }
}
