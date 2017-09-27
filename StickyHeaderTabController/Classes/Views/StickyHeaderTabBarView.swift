//
//  StickyHeaderTabBarView.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//  Copyright © 2017 Treble Media, Inc. All rights reserved.
//

import UIKit

public protocol StickyHeaderTabBarViewDelegate: class {
    func stickyHeaderTabBarViewNumberOfTabs(_ stickyHeaderTabBarView: StickyHeaderTabBarView) -> Int
    func stickyHeaderTabBarView(_ stickyHeaderTabBarView: StickyHeaderTabBarView,
                                titleAtIndex index: Int) -> String?
}

public class StickyHeaderTabBarView: UICollectionView {

    // MARK: - Public Properties

    public weak var tabDelegate: StickyHeaderTabBarViewDelegate?

    /// A kind of hacky way of letting view specify its height.
    /// TODO: refactor in terms of preferredContentSize?
    open var tabBarHeight: CGFloat {
        return 60.0
    }

    // MARK: - Private Properties

    fileprivate let titleCellReuseIdentifier = "TitleCellReuseIdentifier"
    fileprivate let cellSpacing: CGFloat = 4.0

    private let flowLayout = UICollectionViewFlowLayout()

    // MARK: - Initialization

    public init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: flowLayout)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    // MARK: - Setup

    private func commonInit() {
        setUpCollectionView()
        setUpFlowLayout()
    }

    private func setUpCollectionView() {
        dataSource = self
        delegate = self
        allowsSelection = true
        allowsMultipleSelection = false
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        register(StickyHeaderTabBarViewCell.self,
                 forCellWithReuseIdentifier: titleCellReuseIdentifier)
    }

    private func setUpFlowLayout() {
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = cellSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0,
                                               left: cellSpacing,
                                               bottom: 0,
                                               right: cellSpacing)
    }
}

// MARK: - UICollectionViewDelegate

extension StickyHeaderTabBarView: UICollectionViewDelegate {

}

// MARK: - UICollectionViewDataSource

extension StickyHeaderTabBarView: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        let tabCount = tabDelegate?.stickyHeaderTabBarViewNumberOfTabs(self) ?? 0

        return tabCount
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let title = tabDelegate?.stickyHeaderTabBarView(self, titleAtIndex: index)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: titleCellReuseIdentifier,
                                                      for: indexPath) as! StickyHeaderTabBarViewCell
        cell.title = title

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StickyHeaderTabBarView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = indexPath.item
        let text = tabDelegate!.stickyHeaderTabBarView(self, titleAtIndex: index)!
        let naturalWidth = StickyHeaderTabBarViewCell.cellSize(for: text).width

        let numberOfTabs = CGFloat(collectionView.numberOfItems(inSection: 0))
        let viewSizeWidth = (collectionView.bounds.width - (2 * cellSpacing)) / numberOfTabs

        let width = max(naturalWidth, viewSizeWidth)

        return CGSize(width: width, height: collectionView.bounds.height)
    }
}
