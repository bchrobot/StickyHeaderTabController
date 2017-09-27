//
//  UIGestureRecognizer+Utils.swift
//  StickyHeaderTabController
//
//  Created by Benjamin Chrobot on 9/27/17.
//

import Foundation

extension UIGestureRecognizer {
    /// Convenience method to cancel current gesture.
    internal func cancelCurrentGesture() {
        isEnabled = false
        isEnabled = true
    }
}
