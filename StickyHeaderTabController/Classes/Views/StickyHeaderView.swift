//
//  StickyHeaderView.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//  Copyright © 2017 Treble Media, Inc. All rights reserved.
//

import UIKit

public protocol StickyHeaderViewDelegate: class {
    func stickyHeaderView(_ stickyHeaderView: StickyHeaderView, didChangeHeight height: CGFloat)
}

open class StickyHeaderView: UIView {

    // MARK: - Public Properties

    public weak var delegate: StickyHeaderViewDelegate?
    
}
