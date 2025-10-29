//
//  CardAnimator.swift
//  SheetPresentation
//
//  Created by Christopher Aguilera on 10/29/25.
//

import UIKit

final class CardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }
    
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let container = ctx.containerView
        let key: UITransitionContextViewControllerKey = self.isPresenting ? .to : .from
        
        guard let viewController = ctx.viewController(forKey: key) else { return }
        
        if self.isPresenting {
            container.addSubview(viewController.view)
            let finalFrame = ctx.finalFrame(for: viewController)
            viewController.view.frame = finalFrame.offsetBy(dx: 0, dy: container.bounds.height)
            UIView.animate(
                withDuration: self.transitionDuration(using: ctx),
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.6,
                options: [.curveEaseOut]
            ) {
                viewController.view.frame = finalFrame
            } completion: { _ in
                ctx.completeTransition(true)
            }
        } else {
            let initialFrame = viewController.view.frame
            UIView.animate(
                withDuration: self.transitionDuration(using: ctx),
                delay: 0,
                options: [.curveEaseIn]
            ) {
                viewController.view.frame = initialFrame.offsetBy(dx: 0, dy: container.bounds.height)
            } completion: { _ in
                ctx.completeTransition(true)
            }
        }
    }
}
