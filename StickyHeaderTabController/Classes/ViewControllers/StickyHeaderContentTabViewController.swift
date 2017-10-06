//
//  StickyHeaderContentTabViewController.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//

import UIKit

open class StickyHeaderContentTabViewController: UIViewController {

    // MARK: - Public Properties

    weak var scrollViewDelegate: UIScrollViewDelegate?

    /// Set the top inset for the scrollView. This will be used to calculate the "true" inset.
    open var topInset: CGFloat { return 10.0 }

    /// Set the bottom inset for the scrollView. This will be used to calculate the "true" inset.
    open var bottomInset: CGFloat { return 10.0 }

    private var supplementalBottomInset: CGFloat = 0.0 {
        didSet {
            if oldValue != supplementalBottomInset {
                updateContentInset()
            }
        }
    }

    /// Generic access to tab's content `scrollView`.
    open var scrollView: UIScrollView {
        fatalError("subclasses must override this property!")
    }

    /// This is the "opaque" content inset value. Setting this will add the appropriate inset for
    /// the specific tab (as defined by `topInset` and `bottomInset`).
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            updateContentInset()
        }
    }

    /// This is the "opaque" content offset value. Setting this will add the appropriate offset for
    /// the specific tab (as defined by `topInset` and `bottomInset`).
    public var contentOffset: CGPoint = .zero {
        didSet {
            updateContentOffset()
        }
    }

    // MARK: - Private Methods

    private func updateContentInset() {
        let newBottomInset = contentInset.bottom + bottomInset + supplementalBottomInset
        scrollView.contentInset = UIEdgeInsets(top: contentInset.top + topInset,
                                               left: contentInset.left,
                                               bottom: newBottomInset,
                                               right: contentInset.right)
    }

    private func updateContentOffset() {
        let newOffsetY = contentOffset.y - topInset
        scrollView.contentOffset.y = newOffsetY
        updateSupplementalInsetForOffsetY(newOffsetY)
    }

    fileprivate func updateSupplementalInsetForOffsetY(_ offsetY: CGFloat) {
        let contentBottomPosition = scrollView.contentSize.height - offsetY
        let adjustedBottomPosition = contentBottomPosition + bottomInset

        supplementalBottomInset = max(0, view.bounds.height - adjustedBottomPosition)
    }
}

// MARK: - UIScrollViewDelegate

extension StickyHeaderContentTabViewController: UIScrollViewDelegate {

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)

        let offsetY = scrollView.contentOffset.y
        let insetBottom = scrollView.contentInset.bottom
        let contentBottomPosition = scrollView.contentSize.height + insetBottom - offsetY
        if contentBottomPosition > view.bounds.height {
            updateSupplementalInsetForOffsetY(scrollView.contentOffset.y)
        }
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
}
