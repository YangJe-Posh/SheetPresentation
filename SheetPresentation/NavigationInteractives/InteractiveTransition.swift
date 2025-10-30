//
//  InteractiveTransition.swift
//  SheetPresentation
//
//  Created by USER on 10/30/25.
//

import UIKit

/// Managing pan gesture, calculating the progress, checking threshold value
class InteractiveTransition<Convertible: InteractiveTransitionConvertible>: NSObject, UIGestureRecognizerDelegate {

    var canUseGestureInteractive = true {
        didSet {
            panGesture?.isEnabled = canUseGestureInteractive
        }
    }
    var useGestureInteractive = false

    var isDuringAnimation: Bool = false

    var allowedPanGestureDirections: [GestureDirection] = [.up, .down, .left, .right]

    private var shouldComplete = false

    private(set) var transitionContext: InteractiveTransitionContext?

    private(set) var convertible: Convertible?

    private(set) var animator: TransitionAnimator?

    private(set) var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?

    private(set) var panGesture: UIPanGestureRecognizer?

    private var onStart: (() -> Void)?

    private var onPanning: ((CGFloat) -> Void)?

    private var onFinished: ((Bool) -> Void)?

    private var isStarted: Bool = false

    convenience init(convertible: Convertible, onStart: (() -> Void)? = nil, onPanning: ((CGFloat) -> Void)? = nil, onFinished: ((Bool) -> Void)? = nil) {
        self.init(convertible: convertible)
        self.onStart = onStart
        self.onPanning = onPanning
        self.onFinished = onFinished
    }

    required init(convertible: Convertible) {
        super.init()
        self.convertible = convertible
        self.animator = convertible.animator
        self.percentDrivenInteractiveTransition = convertible.percentDrivenInteractiveTransition
    }

    func setupContext(from fromViewController: UIViewController?, to toViewController: UIViewController?) {
        transitionContext = InteractiveTransitionContext(from: fromViewController, to: toViewController)
    }

    func attachGesture(in view: UIView) {
        if let panGesture = panGesture {
            view.removeGestureRecognizer(panGesture)
        }

        let interactivePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handle(_:)))
        interactivePanGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(interactivePanGesture)
        panGesture = interactivePanGesture
    }

    func removeGesture(in view: UIView) {
        guard let gestureRecognizer = view.gestureRecognizers?.last else { return }
        view.removeGestureRecognizer(gestureRecognizer)
    }

    @objc private func handle(_ recognizer: UIPanGestureRecognizer) {
        guard canUseGestureInteractive else { return }
        switch recognizer.state {
        case .began:
            guard convertible?.useInteractiveTransition ?? false else { return }
            guard let panDirection = panGesture?.direction, allowedPanGestureDirections.contains(panDirection) else { return }

            useGestureInteractive = true
            isDuringAnimation = true
            onStart?()
        case .changed:
            guard isDuringAnimation else { return }
            let threshold: CGFloat = convertible?.threshold ?? 0.5
            let percent: CGFloat = recognizer.view
                .flatMap(recognizer.translation(in:))
                .flatMap(calcuratePercent(at:)) ?? 0
            if percent > 0, isStarted == false {
                isStarted = true
                begin()
            }
            percentDrivenInteractiveTransition?.update(percent)
            let velocity = recognizer.velocity(in: recognizer.view)
            shouldComplete = percent > threshold || (convertible?.completeCondition(from: velocity) ?? false)
            onPanning?(percent)
        case .cancelled, .ended:
            onFinished?(useGestureInteractive && recognizer.state == .ended && shouldComplete)
            if recognizer.state == .cancelled || !shouldComplete {
                percentDrivenInteractiveTransition?.completionSpeed = convertible?.cancelCompletionSpeed ?? 0.2
                percentDrivenInteractiveTransition?.cancel()
            } else {
                percentDrivenInteractiveTransition?.completionSpeed = convertible?.finishCompletionSpeed ?? 1
                percentDrivenInteractiveTransition?.finish()
            }
            useGestureInteractive = false
            isDuringAnimation = false
            isStarted = false
        default: break
        }
    }
}

private extension InteractiveTransition {

    func begin() {
        guard let context = transitionContext else { return }
        switch animator?.transitionDirection {
        case .forward?: convertible?.forward(using: context)
        case .backward?: convertible?.backward(using: context)
        case .none: break
        }
    }

    func calcuratePercent(at translation: CGPoint) -> CGFloat {
        let translationValue: CGFloat = convertible.map { $0.swipeDirection == .vertical ? translation.y : translation.x } ?? 0
        let dragAmount = convertible.flatMap { $0.dragAmount }.map { animator?.transitionDirection == .forward ? -$0 : $0 } ?? 0
        var percent = translationValue / dragAmount
        percent = fmax(percent, 0)
        percent = fmin(percent, 1)
        return percent
    }
}

enum SwipeDirection {
    case horizontal, vertical
}

enum GestureDirection: String {
    case up
    case down
    case left
    case right
}

extension UIPanGestureRecognizer {
    var direction: GestureDirection? {
        let velocity = velocity(in: view)
        let vertical = abs(velocity.y) > abs(velocity.x)
        switch (vertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return nil
        }
    }
}

class InteractiveTransitionContext {

    private(set) weak var fromViewController: UIViewController?
    private(set) weak var toViewController: UIViewController?

    init(from fromViewController: UIViewController?, to toViewController: UIViewController?) {
        self.fromViewController = fromViewController
        self.toViewController = toViewController
    }
}
