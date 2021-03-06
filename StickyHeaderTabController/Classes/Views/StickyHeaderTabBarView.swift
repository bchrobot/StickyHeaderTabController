//
//  StickyHeaderTabBarView.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//

import UIKit

public protocol StickyHeaderTabBarViewDelegate: class {
    func stickyHeaderTabBarView(_ stickyHeaderTabBarView: StickyHeaderTabBarView,
                                tabSelectedAtIndex index: Int)
}

public protocol StickyHeaderTabBarViewDataSource: class {
    func stickyHeaderTabBarViewNumberOfTabs(_ stickyHeaderTabBarView: StickyHeaderTabBarView) -> Int
    func stickyHeaderTabBarView(_ stickyHeaderTabBarView: StickyHeaderTabBarView,
                                titleAtIndex index: Int) -> String?
}

open class StickyHeaderTabBarView: UICollectionView {

    // MARK: - Public Properties

    public weak var tabDelegate: StickyHeaderTabBarViewDelegate?
    public weak var tabDataSource: StickyHeaderTabBarViewDataSource?

    public var bottomBorderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    public var bottomBorderWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
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
        heightAnchor.constraint(equalToConstant: 60.0).isActive = true

        backgroundColor = UIColor(white: 0.97, alpha: 1.0)

        setUpCollectionView()
        setUpFlowLayout()
    }

    private func setUpCollectionView() {
        dataSource = self
        delegate = self

        bounces = false
        allowsSelection = true
        allowsMultipleSelection = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        registerCellForReuse()
    }

    private func setUpFlowLayout() {
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = cellSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0,
                                               left: cellSpacing,
                                               bottom: 0.0,
                                               right: cellSpacing)
    }

    // MARK: - Open Methods

    open func registerCellForReuse() {
        register(StickyHeaderTabBarViewCell.self,
                 forCellWithReuseIdentifier: titleCellReuseIdentifier)
    }

    // MARK: - Public Methods

    public func setTabIndex(_ tabIndex: Int, animated: Bool) {
        let newIndexPath = IndexPath(item: tabIndex, section: 0)
        selectItem(at: newIndexPath, animated: animated, scrollPosition: .bottom)
    }

    // MARK: - Override

    open override func draw(_ rect: CGRect) {
        guard let borderColor = bottomBorderColor, bottomBorderWidth > 0 else {
            super.draw(rect)

            return
        }

        let borderRect = CGRect(x: 0,
                                y: rect.height - bottomBorderWidth,
                                width: rect.width,
                                height: rect.width)
        let borderPath = UIBezierPath(rect: borderRect)

        borderColor.set()
        borderPath.fill()
    }
}

// MARK: - UICollectionViewDelegate

extension StickyHeaderTabBarView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        tabDelegate?.stickyHeaderTabBarView(self, tabSelectedAtIndex: indexPath.item)
    }
}

// MARK: - UICollectionViewDataSource

extension StickyHeaderTabBarView: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        let tabCount = tabDataSource?.stickyHeaderTabBarViewNumberOfTabs(self) ?? 0

        return tabCount
    }

    open func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let title = tabDataSource?.stickyHeaderTabBarView(self, titleAtIndex: index)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: titleCellReuseIdentifier,
                                                      for: indexPath) as! StickyHeaderTabBarViewCell
        cell.title = title

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StickyHeaderTabBarView: UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = indexPath.item
        let text = tabDataSource!.stickyHeaderTabBarView(self, titleAtIndex: index)!
        let naturalWidth = StickyHeaderTabBarViewCell.cellSize(for: text).width

        let numberOfTabs = CGFloat(collectionView.numberOfItems(inSection: 0))
        let spacingSumSize = CGFloat(numberOfTabs + 1) * cellSpacing
        let viewSizeWidth = (collectionView.bounds.width - spacingSumSize) / numberOfTabs

        let width = max(naturalWidth, viewSizeWidth)

        return CGSize(width: width, height: collectionView.bounds.height)
    }
}
