//
//  TransitionAnimators.swift
//  SheetPresentation
//
//  Created by USER on 10/30/25.
//

import UIKit

/// Custom animation logic, Dealing with view arragement, view movement
class SwipePopTransitionAnimator: TransitionAnimator {

    override func backwardAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, to toViewController: UIViewController, from fromViewController: UIViewController) {
        guard let toView = transitionContext.view(forKey: .to), let fromView = transitionContext.view(forKey: .from) else { return }

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(fromView)

        var toViewRect = transitionContext.finalFrame(for: toViewController)
        let currentWindowBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.effectiveGeometry.coordinateSpace.bounds ?? CGRect.zero
        toViewRect.origin.x = -(currentWindowBounds.width / 3) + 14
        toView.frame = toViewRect

        let dimmedView = TransitionSupporter.createDimmedView(blurEffect: true)
        dimmedView.alpha = 1
        toView.addSubview(dimmedView)

        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            dimmedView.alpha = 0
            toViewRect.origin.x = 0
            toView.frame = toViewRect
            fromView.frame = CGRect(x: toView.frame.width, y: fromView.frame.origin.y, width: fromView.frame.width, height: fromView.frame.height)
        }, completion: { _ in
            dimmedView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class ModalLikeTransitionAnimator: TransitionAnimator {

    override func backwardAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, to toViewController: UIViewController, from fromViewController: UIViewController) {
        guard let toView = transitionContext.view(forKey: .to), let fromView = transitionContext.view(forKey: .from) else { return }

        fromView.layer.shadowColor = UIColor.white.cgColor
        fromView.layer.shadowOffset = CGSize(width: -4, height: 0)
        fromView.layer.shadowRadius = 4
        fromView.layer.masksToBounds = false
        fromView.layer.shadowOpacity = 0.7

        let path = UIBezierPath(rect: fromView.bounds)
        fromView.layer.shadowPath = path.cgPath

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(fromView)

        var toViewRect = transitionContext.finalFrame(for: toViewController)
        toViewRect.origin.x = 0
        toView.frame = toViewRect

        let dimmedView = TransitionSupporter.createDimmedView(blurEffect: false)
        dimmedView.alpha = 1
        toView.addSubview(dimmedView)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            dimmedView.alpha = 0
            toViewRect.origin.x = 0
            toView.frame = toViewRect
            fromView.layer.shadowOpacity = 0
            fromView.alpha = 0
            fromView.frame = CGRect(x: 0, y: fromView.frame.height, width: fromView.frame.width, height: fromView.frame.height)
        }, completion: { _ in
            dimmedView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
