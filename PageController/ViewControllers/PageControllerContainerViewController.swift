//
//  PageControllerContainerViewController.swift
//  PageController
//
//  Created by Eric Williams on 2022-08-07.
//

import UIKit

public protocol PageControllerContainerDelegate: AnyObject {
    func pageControllerDidComplete(_ controller: PageControllerContainerViewController)
    func pageControllerDidCancel(_ controller: PageControllerContainerViewController)
    func pageController(_ controller: PageControllerContainerViewController,
                        didNavigateToPageAtIndex index: Int)
}

public struct PageControllerConfiguration {
    public var showPageControl: Bool
    public var showNavigationButtons: Bool
    public var showSkipButton: Bool
    public var allowSwipeNavigation: Bool
    public var pageControlTintColor: UIColor
    public var pageControlCurrentTintColor: UIColor
    public var backgroundColor: UIColor
    public var transitionStyle: UIPageViewController.TransitionStyle

    public init(
        showPageControl: Bool = true,
        showNavigationButtons: Bool = true,
        showSkipButton: Bool = true,
        allowSwipeNavigation: Bool = true,
        pageControlTintColor: UIColor = .systemGray,
        pageControlCurrentTintColor: UIColor = .darkGray,
        backgroundColor: UIColor = .systemBackground,
        transitionStyle: UIPageViewController.TransitionStyle = .scroll
    ) {
        self.showPageControl = showPageControl
        self.showNavigationButtons = showNavigationButtons
        self.showSkipButton = showSkipButton
        self.allowSwipeNavigation = allowSwipeNavigation
        self.pageControlTintColor = pageControlTintColor
        self.pageControlCurrentTintColor = pageControlCurrentTintColor
        self.backgroundColor = backgroundColor
        self.transitionStyle = transitionStyle
    }
}

public final class PageControllerContainerViewController: UIViewController {

    public weak var delegate: PageControllerContainerDelegate?

    public let pageManager: PageManager
    public let pageTheme: any PageTheme
    private let configuration: PageControllerConfiguration

    private var pageViewController: UIPageViewController!

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.pageIndicatorTintColor = pageTheme.pageControlTintColor
        control.currentPageIndicatorTintColor = pageTheme.pageControlCurrentTintColor
        control.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        return control
    }()

    private lazy var navigationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()

    private lazy var backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.title = "Back"
        config.imagePlacement = .leading
        config.imagePadding = 4
        let button = UIButton(configuration: config)
        button.tintColor = pageTheme.actionButtonBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.right")
        config.title = "Next"
        config.imagePlacement = .trailing
        config.imagePadding = 4
        let button = UIButton(configuration: config)
        button.tintColor = pageTheme.actionButtonBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Skip"
        let button = UIButton(configuration: config)
        button.tintColor = pageTheme.actionButtonBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()

     
    public init(pages: [any PageContent],
                theme: any PageTheme,
                configuration: PageControllerConfiguration = PageControllerConfiguration()) {
        self.pageManager = PageManager(pages: pages)
        self.pageTheme = theme
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    public init(manager: PageManager,
                theme: any PageTheme,
                configuration: PageControllerConfiguration = PageControllerConfiguration()) {
        self.pageManager = manager
        self.pageTheme = theme
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }


    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = pageTheme.backgroundColour //configuration.backgroundColor
        pageManager.delegate = self

        Task {
            await setupVisiblePages()
            setupPageViewController()
            uiSetup()
            setupConstraints()
            updateNavigationState()
        }
    }
    private func setupVisiblePages() async {
        await pageManager.rebuildVisiblePages()
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: configuration.transitionStyle,
            navigationOrientation: .horizontal,
            options: nil
        )

        pageViewController.dataSource = configuration.allowSwipeNavigation ? self : nil
        pageViewController.delegate = self

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)

        if let firstVC = createPageContentViewController(for: 0) {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }

    private func uiSetup() {
        if configuration.showPageControl {
            view.addSubview(pageControl)
            pageControl.numberOfPages = pageManager.pageCount
            pageControl.currentPage = pageManager.currentIndex
        }

        // navigation
        if configuration.showNavigationButtons || configuration.showSkipButton {
            view.addSubview(navigationStackView)

            if configuration.showNavigationButtons {
                navigationStackView.addArrangedSubview(backButton)
            } else {
                let spacer = UIView()
                navigationStackView.addArrangedSubview(spacer)
            }

            if configuration.showSkipButton {
                navigationStackView.addArrangedSubview(skipButton)
            }

            if configuration.showNavigationButtons {
                navigationStackView.addArrangedSubview(nextButton)
            } else {
                let spacer = UIView()
                navigationStackView.addArrangedSubview(spacer)
            }
        }
    }

    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []

        // Page View Controller
        let bottomAnchor: NSLayoutYAxisAnchor
        if configuration.showPageControl {
            bottomAnchor = pageControl.topAnchor
        } else if configuration.showNavigationButtons || configuration.showSkipButton {
            bottomAnchor = navigationStackView.topAnchor
        } else {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }

        constraints.append(contentsOf: [
            pageViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])

        // Page Control
        if configuration.showPageControl {
            let navBottomAnchor: NSLayoutYAxisAnchor
            if configuration.showNavigationButtons || configuration.showSkipButton {
                navBottomAnchor = navigationStackView.topAnchor
            } else {
                navBottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
            }

            constraints.append(contentsOf: [
                pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                pageControl.bottomAnchor.constraint(equalTo: navBottomAnchor, constant: -8),
                pageControl.heightAnchor.constraint(equalToConstant: 30),
            ])
        }

        // Navigation Stack
        if configuration.showNavigationButtons || configuration.showSkipButton {
            constraints.append(contentsOf: [
                navigationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                navigationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                navigationStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
                navigationStackView.heightAnchor.constraint(equalToConstant: 44),
            ])
        }

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - State
extension PageControllerContainerViewController {
    private func updateNavigationState() {
        pageControl.currentPage = pageManager.currentIndex
        pageControl.numberOfPages = pageManager.pageCount

        backButton.isHidden = pageManager.isFirstPage
        skipButton.isHidden = pageManager.isLastPage

        if pageManager.isLastPage {
            nextButton.setTitle("Done", for: .normal)
            nextButton.configuration?.image = nil
        } else {
            nextButton.setTitle("Next", for: .normal)
            nextButton.configuration?.image = UIImage(systemName: "chevron.right")
        }

        delegate?.pageController(self, didNavigateToPageAtIndex: pageManager.currentIndex)
    }

    private func createPageContentViewController(for index: Int) -> PageContentViewController? {
        guard let page = pageManager.page(at: index) else { return nil }
        let vc = PageContentViewController(
            pageContent: page,
            pageTheme: pageTheme,
            pageIndex: index
        )
        vc.view.backgroundColor = pageTheme.backgroundColour
        vc.delegate = self
        return vc
    }
}

// MARK: - Navigation
extension PageControllerContainerViewController {
    public func navigateToNext(animated: Bool = true) {
        guard pageManager.canGoNext else {
            pageManager.complete()
            return
        }

        _ = pageManager.next()
        if let vc = createPageContentViewController(for: pageManager.currentIndex) {
            pageViewController.setViewControllers([vc], direction: .forward, animated: animated)
        }
        updateNavigationState()
    }

    public func navigateToPrevious(animated: Bool = true) {
        guard pageManager.canGoBack else { return }

        _ = pageManager.previous()
        if let vc = createPageContentViewController(for: pageManager.currentIndex) {
            pageViewController.setViewControllers([vc], direction: .reverse, animated: animated)
        }
        updateNavigationState()
    }

    public func navigateToPage(at index: Int, animated: Bool = true) {
        let direction: UIPageViewController.NavigationDirection = index > pageManager.currentIndex ? .forward : .reverse

        guard pageManager.navigateTo(index: index) else { return }

        if let vc = createPageContentViewController(for: index) {
            pageViewController.setViewControllers([vc], direction: direction, animated: animated)
        }
        updateNavigationState()
    }

    public func skipToEnd() {
        pageManager.skipToEnd()
        if let vc = createPageContentViewController(for: pageManager.currentIndex) {
            pageViewController.setViewControllers([vc], direction: .forward, animated: true)
        }
        updateNavigationState()
    }
}

// MARK: - Actions
extension PageControllerContainerViewController {
    @objc private func backButtonTapped() {
        navigateToPrevious()
    }

    @objc private func nextButtonTapped() {
        if pageManager.isLastPage {
            pageManager.complete()
        } else {
            navigateToNext()
        }
    }

    @objc private func skipButtonTapped() {
        skipToEnd()
    }

    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        navigateToPage(at: sender.currentPage)
    }
}

// MARK: - UIPageViewControllerDataSource
extension PageControllerContainerViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let contentVC = viewController as? PageContentViewController else { return nil }
        let previousIndex = contentVC.pageIndex - 1
        return createPageContentViewController(for: previousIndex)
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let contentVC = viewController as? PageContentViewController else { return nil }
        let nextIndex = contentVC.pageIndex + 1
        return createPageContentViewController(for: nextIndex)
    }
}

// MARK: - UIPageViewControllerDelegate
extension PageControllerContainerViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        guard completed,
              let contentVC = pageViewController.viewControllers?.first as? PageContentViewController else {
            return
        }

        _ = pageManager.navigateTo(index: contentVC.pageIndex)
        updateNavigationState()
    }
}

// MARK: - PageContentViewControllerDelegate
extension PageControllerContainerViewController: PageContentViewControllerDelegate {
    public func pageContentViewController(_ controller: PageContentViewController,
                                          didTapActionForPage page: any PageContent) {
        // Action button tapped - the controller will handle the async action
    }

    public func pageContentViewController(_ controller: PageContentViewController,
                                          didTapSkipForPage page: any PageContent) {
        navigateToNext()
    }

    public func pageContentViewController(_ controller: PageContentViewController,
                                          actionDidComplete result: PageActionResult) {
        switch result {
        case .success:
            // Check if this is a permission page with auto-advance
            if let permissionPage = controller.pageContent as? any PermissionPageContent,
               permissionPage.autoAdvanceOnGrant {
                Task { @MainActor in
                    await pageManager.advanceAfterAction()
                    if let vc = createPageContentViewController(for: pageManager.currentIndex) {
                        pageViewController.setViewControllers([vc], direction: .forward, animated: true)
                    }
                    updateNavigationState()
                }
            } else {
                navigateToNext()
            }
        case .failure:
            // Stay on current page, user can retry or skip
            break
        case .cancelled:
            // User cancelled, stay on current page
            break
        }
    }
}

// MARK: - PageManagerDelegate
extension PageControllerContainerViewController: PageManagerDelegate {
    public func pageManagerDidUpdateVisiblePages(_ manager: PageManager) {
        pageControl.numberOfPages = manager.pageCount
        updateNavigationState()
    }

    public func pageManager(_ manager: PageManager, didNavigateToIndex index: Int) {
        // Already handled in navigation methods
    }

    public func pageManagerDidComplete(_ manager: PageManager) {
        delegate?.pageControllerDidComplete(self)
    }
}
