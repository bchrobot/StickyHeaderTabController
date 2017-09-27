//
//  StickyHeaderHeroView.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//

import UIKit

public protocol StickyHeaderHeroViewDelegate: class {
    func stickyHeaderHeroView(_ stickyHeaderHeroView: StickyHeaderHeroView,
                              didChangeHeight height: CGFloat)
}

open class StickyHeaderHeroView: UIView {

    // MARK: - Public Properties

    /// A kind of hacky way of letting view specify its height.
    /// TODO: refactor in terms of preferredContentSize?
    open var heroHeight: CGFloat {
        return 200.0
    }
}
