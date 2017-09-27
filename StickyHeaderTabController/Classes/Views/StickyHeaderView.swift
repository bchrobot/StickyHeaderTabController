//
//  StickyHeaderView.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//

import UIKit

public protocol StickyHeaderViewDelegate: class {
    func stickyHeaderView(_ stickyHeaderView: StickyHeaderView, didChangeHeight height: CGFloat)
}

open class StickyHeaderView: UIView {

    // MARK: - Public Properties

    public weak var delegate: StickyHeaderViewDelegate?

    /// A kind of hacky way of letting view specify its height.
    /// TODO: refactor in terms of preferredContentSize?
    open var headerHeight: CGFloat {
        return 170.0
    }

    /// The minimum header height (while pinned in sticky top position)
    open var pinnedHeight: CGFloat {
        return 60.0
    }

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
