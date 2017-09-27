//
//  ObjectAssociation.swift
//  StickyHeaderTabController
//
//  Created by Benjamin Chrobot on 9/26/17.
//

import Foundation

extension UIScrollView {
    // startingOffset
    private static let startingOffsetAssociation = ObjectAssociation<CGPoint>()
    var startingOffset: CGPoint? {
        get { return UIScrollView.startingOffsetAssociation[self] }
        set { UIScrollView.startingOffsetAssociation[self] = newValue }
    }

    // lastPointInBounds
    private static let lastPointInBoundsAssociation = ObjectAssociation<CGPoint>()
    var lastPointInBounds: CGPoint? {
        get { return UIScrollView.lastPointInBoundsAssociation[self] }
        set { UIScrollView.lastPointInBoundsAssociation[self] = newValue }
    }

    // animator
    private static let animatorAssociation = ObjectAssociation<UIDynamicAnimator>()
    var animator: UIDynamicAnimator? {
        get { return UIScrollView.animatorAssociation[self] }
        set { UIScrollView.animatorAssociation[self] = newValue }
    }

    // decelerationBehavior
    private static let decelerationBehaviorAssociation = ObjectAssociation<UIDynamicItemBehavior>()
    var decelerationBehavior: UIDynamicItemBehavior? {
        get { return UIScrollView.decelerationBehaviorAssociation[self] }
        set { UIScrollView.decelerationBehaviorAssociation[self] = newValue }
    }

    // springBehavior
    private static let springBehaviorAssociation = ObjectAssociation<UIAttachmentBehavior>()
    var springBehavior: UIAttachmentBehavior? {
        get { return UIScrollView.springBehaviorAssociation[self] }
        set { UIScrollView.springBehaviorAssociation[self] = newValue }
    }

    // dynamicItem
    private static let dynamicItemAssociation = ObjectAssociation<TMDynamicItem>()
    var dynamicItem: TMDynamicItem? {
        get { return UIScrollView.dynamicItemAssociation[self] }
        set { UIScrollView.dynamicItemAssociation[self] = newValue }
    }

    /// Convenience accessor
    private var scrollVertical: Bool {
        return contentSize.height + contentInset.top + contentInset.bottom > bounds.height
    }

    /// Convenience accessor
    private var scrollHorizontal: Bool {
        return self.contentSize.width + contentInset.left + contentInset.right > bounds.width
    }

    private var minContentOffset: CGPoint {
        return CGPoint(x: -contentInset.left, y: -contentInset.top)
    }

    private var maxContentOffset: CGPoint {
        return CGPoint(x: contentSize.width + contentInset.bottom - bounds.size.width,
                       y: contentSize.height + contentInset.bottom - bounds.height)
    }

    private var outsideOffsetMinimum: Bool {
        return contentOffset.x < minContentOffset.x || contentOffset.y < minContentOffset.y
    }

    private var outsideOffsetMaximum: Bool {
        return contentOffset.x > maxContentOffset.x
            || contentOffset.y > maxContentOffset.y
    }

    /// Helper function
    private func rubberBandDistance(offset: CGFloat, dimension: CGFloat) -> CGFloat {
        // Apple's consant value
        let constant: CGFloat = 0.55
        let result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset))

        // The algorithm expects a positive offset, so we have to negate the result if the offset
        // was negative.
        return offset < 0.0 ? -result : result
    }

    /// Roll our own scrolling
    internal func handlePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let gestureView = panGestureRecognizer.view ?? self

        if self.animator == nil {
            self.animator = UIDynamicAnimator(referenceView: self)
        }

        if self.dynamicItem == nil {
            self.dynamicItem = TMDynamicItem(transform: CGAffineTransform(), center: .zero)
        }

        switch panGestureRecognizer.state {
        case .began:
            self.startingOffset = self.contentOffset
            self.animator!.removeAllBehaviors()

            // Need to explicitly nil these out
            self.decelerationBehavior = nil
            self.springBehavior = nil

        case .changed:
            var translation = panGestureRecognizer.translation(in: gestureView)
            var contentOffset = self.startingOffset!

            if !scrollHorizontal {
                translation.x = 0.0
            }
            if !scrollVertical {
                translation.y = 0.0
            }

            let newOffsetX = contentOffset.x - translation.x
            let constrainedOffsetX = max(minContentOffset.x, min(newOffsetX, maxContentOffset.x))
            let rubberBandedX = rubberBandDistance(offset: newOffsetX - constrainedOffsetX, dimension: bounds.width)
            contentOffset.x = constrainedOffsetX + rubberBandedX

            let newOffsetY = contentOffset.y - translation.y
            let constrainedOffsetY = max(minContentOffset.y, min(newOffsetY, maxContentOffset.y))
            let rubberBandedY = rubberBandDistance(offset: newOffsetY - constrainedOffsetY, dimension: bounds.height)
            contentOffset.y = constrainedOffsetY + rubberBandedY

            self.contentOffset = contentOffset

        case .ended,
             .cancelled:
            var velocity = panGestureRecognizer.velocity(in: self)
            if !scrollHorizontal {
                velocity.x = 0.0
            }
            if !scrollVertical {
                velocity.y = 0.0
            }
            velocity.x = -velocity.x
            velocity.y = -velocity.y

            // Use `center` to store `contentOffset`
            self.dynamicItem!.center = self.contentOffset
            let decelerationBehavior = UIDynamicItemBehavior(items: [self.dynamicItem!])
            decelerationBehavior.addLinearVelocity(velocity, for: self.dynamicItem!)
            decelerationBehavior.resistance = 2.0

            decelerationBehavior.action = { [unowned self] in
                self.setContentOffsetWithSpring(self.dynamicItem!.center)
            }

            animator!.addBehavior(decelerationBehavior)
            self.decelerationBehavior = decelerationBehavior

        default:
            break
        }
    }

    internal func setContentOffsetWithSpring(_ contentOffset: CGPoint) {
        self.contentOffset = contentOffset

        if (outsideOffsetMinimum || outsideOffsetMaximum)
            && (decelerationBehavior != nil && springBehavior == nil) {
            let anchor = self.anchor

            let springBehavior = UIAttachmentBehavior(item: self.dynamicItem!,
                                                      attachedToAnchor: anchor)
            // Has to be equal to zero, because otherwise the bounds.origin wouldn't exactly match the target's position.
            springBehavior.length = 0
            // These two values were chosen by trial and error.
            springBehavior.damping = 1
            springBehavior.frequency = 2

            self.animator!.addBehavior(springBehavior)
            self.springBehavior = springBehavior

        }

        if !outsideOffsetMinimum && !outsideOffsetMaximum {
            lastPointInBounds = contentOffset
        }
    }

    private var anchor: CGPoint {
        return CGPoint(x: max(minContentOffset.x, min(contentOffset.x, maxContentOffset.x)),
                       y: max(minContentOffset.y, min(contentOffset.y, maxContentOffset.y)))
    }
}

internal class TMDynamicItem: NSObject, UIDynamicItem {
    let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
    var transform: CGAffineTransform
    var center: CGPoint

    init(transform: CGAffineTransform, center: CGPoint) {
        self.transform = transform
        self.center = center

        super.init()
    }
}
