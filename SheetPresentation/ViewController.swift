//
//  ViewController.swift
//  SheetPresentation
//
//  Created by Christopher Aguilera on 10/29/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let presentFullScreenButton = UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: "Full Screen") { [weak self] _ in
                self?.presentFullScreen()
            }
        )
        
        let presentFormSheetButton = UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: "Form Sheet") { [weak self] _ in
                self?.presentFormSheet()
            }
        )
        
        let presentPageSheetButton = UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: "Page Sheet") { [weak self] _ in
                self?.presentPageSheet()
            }
        )
        
        let presentPageSheetWithNavigationStackButton = UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: "Page Sheet with Navigation Stack") { [weak self] _ in
                self?.presentPageSheetWithNavigationStack()
            }
        )
        
        let presentCardButton = UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: "Card") { [weak self] _ in
                self?.presentCard()
            }
        )

        let presentCardWithNavigationStackButton = UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: "Card with Navigation Stack") { [weak self] _ in
                self?.presentCardWithNavigationStack()
            }
        )
        
        let stackView = UIStackView(
            arrangedSubviews: [
                presentFullScreenButton,
                presentFormSheetButton,
                presentPageSheetButton,
                presentPageSheetWithNavigationStackButton,
                presentCardButton,
                presentCardWithNavigationStackButton
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        self.view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    private func presentFullScreen() {
        let viewController = CustomViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .flipHorizontal
        
        self.present(viewController, animated: true)
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .seconds(2),
            execute: { [weak viewController] in
                viewController?.dismiss(animated: true)
            }
        )
    }
    
    private func presentFormSheet() {
        let viewController = CustomViewController()
        viewController.modalPresentationStyle = .formSheet
        
        self.present(viewController, animated: true)
    }
    
    private func presentPageSheet() {
        let viewController = CustomViewController()
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        
        self.present(viewController, animated: true)
    }

    private func presentPageSheetWithNavigationStack() {
        let viewController = CustomViewController()
        let navController = UINavigationController(rootViewController: viewController)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        
        self.present(navController, animated: true)
    }
    
    private var cardTransitioningDelegate: CardTransitioningDelegate?
    
    private func presentCard() {
        let cardTransitioningDelegate = CardTransitioningDelegate()
        self.cardTransitioningDelegate = cardTransitioningDelegate
        
        let viewController = CustomViewController()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = cardTransitioningDelegate
        
        self.present(viewController, animated: true)
    }

    private func presentCardWithNavigationStack() {
        let cardTransitioningDelegate = CardTransitioningDelegate()
        self.cardTransitioningDelegate = cardTransitioningDelegate
        
        let viewController = CustomViewController()
        let navController = CustomNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = cardTransitioningDelegate
        
        self.present(navController, animated: true)
    }
}

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {

    var transitionType: NavigationInteractiveTransition = .swipePop {
        didSet {
            guard oldValue != transitionType else { return }
            interactive = InteractiveTransition<NavigationInteractiveTransition>(convertible: transitionType)
            interactive.attachGesture(in: view)
            interactive.panGesture?.delegate = self
        }
    }

    lazy var interactive = InteractiveTransition<NavigationInteractiveTransition>(convertible: transitionType)

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        self.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // stop default pop gesture
        interactivePopGestureRecognizer?.isEnabled = false
        // add custom interactive
        interactive.attachGesture(in: view)
        interactive.panGesture?.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        // setting the interactive transition context
        let fromViewController = navigationController.topViewController
        interactive.setupContext(from: fromViewController, to: viewController)
        
        guard let transitionCoordinator else {
            self.updatePreferredContentSize(for: viewController)
            return
        }
        
        transitionCoordinator.animate(
            alongsideTransition: { _ in
                self.updatePreferredContentSize(for: viewController)
            },
            completion: nil
        )
    }

    // UINavigationControllerDelegate main method
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard operation == .pop else { return nil } // only in pop action, using interactive animator
        return interactive.animator
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive.useGestureInteractive ? interactive.percentDrivenInteractiveTransition : nil
    }
    
    private func updatePreferredContentSize(for vc: UIViewController) {
        let targetSize = vc.preferredContentSize
        guard self.preferredContentSize.height != targetSize.height else { return }
        self.preferredContentSize = targetSize
    }
}

class CustomViewController: UIViewController {
    
    private static let heights: [CGFloat] = [200, 400, 600]
    private static let colors: [UIColor] = [.green, .orange, .blue, .red, .green]

    private static var counter = 0
    
    init(preferredContentHeight: CGFloat? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Presented Screen"
        
        if let preferredContentHeight {
            self.preferredContentSize = CGSize(width: 0, height: preferredContentHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = Self.colors.randomElement() ?? .black
        
        let pushScreenButton = UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: "Push Screen") { [weak self] _ in
                self?.pushScreen()
            }
        )
        
        let updatePreferredContentHeightButton = UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: "Update Preferred Content Height") { [weak self] _ in
                self?.preferredContentSize = CGSize(width: 0, height: Self.heights.randomElement() ?? 0)
            }
        )
        
        let stackView = UIStackView(
            arrangedSubviews: [
                pushScreenButton,
                updatePreferredContentHeightButton
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        self.view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        let backButton = UIButton(
            configuration: .borderedProminent(),
            primaryAction: UIAction(title: "← Back") { [weak self] _ in
                self?.backScreen()
            }
        )
        self.view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
    
    private func pushScreen() {
        let preferredContentHeight = Self.heights[Self.counter % Self.heights.count]
        Self.counter += 1
        
        let viewController = CustomViewController(preferredContentHeight: preferredContentHeight)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    private func backScreen() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CustomNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard viewControllers.count > 1 else { return false }

        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer, self.view == gestureRecognizer.view {
            return panGesture.direction == .right
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard viewControllers.first != visibleViewController, interactive.animator?.transitionDirection == .backward else {
            return false
        }

        if let otherView = otherGestureRecognizer.view as? UICollectionView {
            let layout = otherView.collectionViewLayout as? UICollectionViewFlowLayout
            if layout?.scrollDirection == .horizontal {
                return otherView.contentOffset.x == 0
            }
        } else if let otherView = otherGestureRecognizer.view as? UIScrollView {
            return otherView.contentOffset.x == 0
        }

        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let cell = otherGestureRecognizer.view as? NavigationControllerGestureShareable,
              let panGesture = otherGestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }

        guard let direction = panGesture.direction else { return false }
        return direction == .right && !cell.usingSwipeGestureDirections.contains(direction)
    }
}

protocol NavigationControllerGestureShareable {
    var usingSwipeGestureDirections: Set<GestureDirection> { get }
}
