//
//  CardPresentationController.swift
//  SheetPresentation
//
//  Created by Christopher Aguilera on 10/29/25.
//

import UIKit

final class CardPresentationController: UIPresentationController {
    
    private static let cornerRadius: CGFloat = 26
    private static let horizontalPadding: CGFloat = 8
    private static let bottomPadding: CGFloat = 36
    
    private let dimmingView = UIView()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        
        let height: CGFloat
        let preferredContentHeight = self.presentedViewController.preferredContentSize.height
        if preferredContentHeight > 0 {
            height = preferredContentHeight
        } else {
             height = containerView.bounds.height * 0.55
        }
        return CGRect(
            x: Self.horizontalPadding,
            y: containerView.bounds.height - height - Self.bottomPadding,
            width: containerView.bounds.width - (2 * Self.horizontalPadding),
            height: height
        )
    }
    
    override init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        
        self.dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissPresentedController))
        self.dimmingView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissPresentedController() {
        self.presentedViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin() {
        self.containerView?.insertSubview(self.dimmingView, at: 0)
        self.dimmingView.alpha = 0
        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }
        )
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: { _ in
                self.dimmingView.removeFromSuperview()
            }
        )
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        self.dimmingView.frame = self.containerView?.frame ?? .zero
        
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        
        self.presentedView?.layer.masksToBounds = true
        self.presentedView?.layer.cornerRadius = Self.cornerRadius
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: any UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        guard let presentedView else { return }
        
        let updatedFrame = self.frameOfPresentedViewInContainerView
        if presentedView.frame != updatedFrame {
            presentedView.frame = updatedFrame
        }
    }
}
