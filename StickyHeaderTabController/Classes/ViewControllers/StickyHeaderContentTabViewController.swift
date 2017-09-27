//
//  StickyHeaderContentTabViewController.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//  Copyright © 2017 Treble Media, Inc. All rights reserved.
//

import UIKit

open class StickyHeaderContentTabViewController: UIViewController {

    // MARK: - Public Properties

    weak var scrollViewDelegate: UIScrollViewDelegate?

    /// Set the top inset for the scrollView. This will be used to calculate the "true" inset.
    open var topInset: CGFloat { return 10.0 }

    /// Set the bottom inset for the scrollView. This will be used to calculate the "true" inset.
    open var bottomInset: CGFloat { return 10.0 }

    /// Generic access to tab's content `scrollView`.
    open var scrollView: UIScrollView {
        fatalError("subclasses must override this property!")
    }

    /// This is the "opaque" content inset value. Setting this will add the appropriate inset for
    /// the specific tab (as defined by `topInset` and `bottomInset`).
    public var contentInset: UIEdgeInsets {
        get {
            let trueInset = scrollView.contentInset
            return UIEdgeInsets(top: trueInset.top - topInset,
                                left: trueInset.left,
                                bottom: trueInset.bottom - bottomInset,
                                right: trueInset.right)
        }
        set {
            scrollView.contentInset = UIEdgeInsets(top: newValue.top + topInset,
                                                   left: newValue.left,
                                                   bottom: newValue.bottom + bottomInset,
                                                   right: newValue.right)
        }
    }

    /// This is the "opaque" content offset value. Setting this will add the appropriate offset for
    /// the specific tab (as defined by `topInset` and `bottomInset`).
    public var contentOffset: CGPoint {
        get {
            let trueOffset = scrollView.contentOffset
            return CGPoint(x: trueOffset.x, y: trueOffset.y + topInset)
        }
        set {
            scrollView.contentOffset = CGPoint(x: newValue.x, y: newValue.y - topInset)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension StickyHeaderContentTabViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
}
