//
//  NavigationInteractiveTransition.swift
//  VibeMusic
//
//  Created by NAVER on 2018. 1. 12..
//  Copyright © 2018년 VIBE. All rights reserved.
//

import UIKit

enum NavigationInteractiveTransitionType: RawRepresentable {

    init?(rawValue: String) {
        return nil
    }

    case swipePop

    var rawValue: String {
        switch self {
        case .swipePop: return "swipePop"
        }
    }
}

extension NavigationInteractiveTransitionType: InteractiveTransitionValues {

    var useInteractiveTransition: Bool {
        switch self {
        case .swipePop: return true
        }
    }

    var dragAmount: CGFloat {
        switch self {
        case .swipePop: return UIScreen.main.bounds.width
        default: return UIScreen.main.bounds.height
        }
    }

    var swipeDirection: SwipeDirection {
        switch self {
        case .swipePop: return .horizontal
        }
    }

    var threshold: CGFloat {
        return 0.2
    }

    var cancelCompletionSpeed: CGFloat {
        return 0.5
    }

    var finishCompletionSpeed: CGFloat {
        return 1
    }

    var animator: TransitionAnimator? {
        switch self {
        case .swipePop: return SwipePopTransitionAnimator(direction: .backward, duration: 0.8)
        }
    }

    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
        return UIPercentDrivenInteractiveTransition()
    }

    func completeCondition(from velocity: CGPoint) -> Bool {
        return false
    }
}

extension NavigationInteractiveTransitionType: InteractiveTransitionActions {

    func forward(using context: InteractiveTransitionContext) {
        guard let toViewController = context.toViewController else {
            return
        }
        guard (context.fromViewController?.navigationController?.viewControllers.contains(toViewController) ?? true) == false else { return }
        context.fromViewController?.navigationController?.pushViewController(toViewController, animated: true)
    }

    func backward(using context: InteractiveTransitionContext) {
        context.toViewController?.navigationController?.popViewController(animated: true)
    }
}
