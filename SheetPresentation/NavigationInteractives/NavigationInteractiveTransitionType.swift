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

    case swipePop, dragDownPop

    var rawValue: String {
        switch self {
        case .swipePop: return "swipePop"
        case .dragDownPop: return "modal"
        }
    }
}

extension NavigationInteractiveTransitionType: InteractiveTransitionValues {

    var useInteractiveTransition: Bool {
        switch self {
        case .swipePop: return true
        case .dragDownPop: return true
        }
    }

    var dragAmount: CGFloat {
        switch self {
        case .swipePop: return UIScreen.main.bounds.width
        case .dragDownPop: return UIScreen.main.bounds.width
        }
    }

    var swipeDirection: SwipeDirection {
        switch self {
        case .swipePop, .dragDownPop: return .horizontal
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
        case .swipePop: return SwipePopTransitionAnimator(direction: .backward, duration: 0.2)
        case .dragDownPop: return ModalLikeTransitionAnimator(direction: .backward, duration: 0.4)
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
