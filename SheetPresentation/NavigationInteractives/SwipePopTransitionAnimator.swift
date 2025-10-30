//
//  SwipePopTransitionAnimator.swift
//  VibeMusic
//
//  Created by NAVER on 2018. 1. 12..
//  Copyright © 2018년 VIBE. All rights reserved.
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

        let dimmedView = TransitionSupporter.createDimmedView(blurEffect: false)
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
