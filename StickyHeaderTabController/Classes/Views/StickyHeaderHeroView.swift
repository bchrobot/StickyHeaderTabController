//
//  StickyHeaderHeroView.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//  Copyright © 2017 Treble Media, Inc. All rights reserved.
//

import UIKit

public protocol StickyHeaderHeroViewDelegate: class {
    func stickyHeaderHeroView(_ stickyHeaderHeroView: StickyHeaderHeroView,
                              didChangeHeight height: CGFloat)
}

open class StickyHeaderHeroView: UIView {

    /// A kind of hacky way of letting view specify its height.
    /// TODO: refactor in terms of preferredContentSize?
    open var heroHeight: CGFloat {
        return 200.0
    }

}
