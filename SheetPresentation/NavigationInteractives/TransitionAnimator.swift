//
//  TransitionAnimator.swift
//  SheetPresentation
//
//  Created by USER on 10/30/25.
//
import UIKit

protocol TransitionAnimatorInterface {

    var duration: TimeInterval { get set }
    var transitionDirection: TransitionDirection { get set }

    func forwardAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, to toViewController: UIViewController, from fromViewController: UIViewController)
    func backwardAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, to toViewController: UIViewController, from fromViewController: UIViewController)
}

enum TransitionDirection {
    case forward, backward
}

class TransitionAnimator: NSObject, TransitionAnimatorInterface {

    var transitionDirection: TransitionDirection
    var duration: TimeInterval

    required init(direction: TransitionDirection = .forward, duration: TimeInterval = 0.4) {
        self.transitionDirection = direction
        self.duration = duration
        super.init()
    }

    func forwardAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, to toViewController: UIViewController, from fromViewController: UIViewController) {
    }

    func backwardAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, to toViewController: UIViewController, from fromViewController: UIViewController) {
    }
}

/// A set of methods for implementing the animations for a custom view controller transition.
extension TransitionAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
            fatalError("viewController does not exist.")
        }
        switch transitionDirection {
        case .forward: forwardAnimateTransition(using: transitionContext, to: toViewController, from: fromViewController)
        case .backward: backwardAnimateTransition(using: transitionContext, to: toViewController, from: fromViewController)
        }
    }
}

struct DimmedConfiguration {
    var backgroundColor: UIColor
    var blurEffectStyle: UIBlurEffect.Style
}

struct TransitionSupporter {

    static func createDimmedView(blurEffect: Bool = false) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let dimmed = DimmedConfiguration(backgroundColor: .white, blurEffectStyle: .regular)
        view.backgroundColor = dimmed.backgroundColor
        view.alpha = 0
        if blurEffect {
            let blurEffect = UIBlurEffect(style: dimmed.blurEffectStyle)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            view.addSubview(visualEffectView)
        }
        return view
    }
}
