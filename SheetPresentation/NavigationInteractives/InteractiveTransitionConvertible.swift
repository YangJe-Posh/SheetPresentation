//
//  InteractiveTransitionConvertible.swift
//  SheetPresentation
//
//  Created by USER on 10/30/25.
//

import UIKit

typealias InteractiveTransitionConvertible = InteractiveTransitionConvertibleValues & InteractiveTransitionConvertibleActions

protocol InteractiveTransitionConvertibleValues {

    var useInteractiveTransition: Bool { get }

    var dragAmount: CGFloat { get }

    var swipeDirection: SwipeDirection { get }

    var threshold: CGFloat { get }

    var cancelCompletionSpeed: CGFloat { get }

    var finishCompletionSpeed: CGFloat { get }

    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition { get }

    var animator: TransitionAnimator? { get }

    func completeCondition(from velocity: CGPoint) -> Bool
}

protocol InteractiveTransitionConvertibleActions {

    func forward(using context: InteractiveTransitionContext)

    func backward(using context: InteractiveTransitionContext)
}
