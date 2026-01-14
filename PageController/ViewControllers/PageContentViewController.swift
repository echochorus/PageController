//
//  PageContentViewController.swift
//  PageController
//
//  Created by Eric Williams on 2022-08-07.
//

import UIKit

/// Delegate for page content view controller events
public protocol PageContentViewControllerDelegate: AnyObject {
    func pageContentViewController(_ controller: PageContentViewController,
                                   didTapActionForPage page: PageContent)
    func pageContentViewController(_ controller: PageContentViewController,
                                   didTapSkipForPage page: PageContent)
    func pageContentViewController(_ controller: PageContentViewController,
                                   actionDidComplete result: PageActionResult)
}

public final class PageContentViewController: UIViewController { 
    public weak var delegate: PageContentViewControllerDelegate?
    public private(set) var pageContent: PageContent
    public private(set) var pageTheme: PageTheme
    public private(set) var pageIndex: Int

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        return stackView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .darkGray
        return imageView
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    private lazy var actionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.buttonSize = .large
        let button = UIButton(configuration: config)
        button.tintColor = .darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .medium
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    public init(pageContent: PageContent, pageTheme: PageTheme, pageIndex: Int) {
        self.pageContent = pageContent
        self.pageTheme = pageTheme
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        contentSetup()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageContent.onAppear()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageContent.onDisappear()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(textStackView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        textStackView.addArrangedSubview(contentLabel)

        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(actionButton)
        buttonStackView.addArrangedSubview(skipButton)

        actionButton.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -24),

            // stackView
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -24),

            // image
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 200),

            // text stackView
            textStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            textStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),

            // Button StackView
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            // call to action button
            actionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            // activity indicator (centered in button)
            activityIndicator.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
        ])
    }

    private func contentSetup() {
        titleLabel.text = pageContent.title
        titleLabel.tintColor = pageTheme.titleColor

        if let subtitle = pageContent.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
            subtitleLabel.tintColor = pageTheme.subtitle
        } else {
            subtitleLabel.isHidden = true
        }

        contentLabel.text = pageContent.content

        if let image = pageContent.image {
            imageView.image = image
            imageView.isHidden = false
        } else if let imageName = pageContent.imageName {
            // Try system image first, then asset catalog
            if let systemImage = UIImage(systemName: imageName) {
                imageView.image = systemImage.withConfiguration(
                    UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
                )
                imageView.tintColor = pageTheme.imageTintColor
            } else {
                imageView.image = UIImage(named: imageName)
                imageView.tintColor = pageTheme.imageTintColor
            }
            imageView.isHidden = imageView.image == nil
        } else {
            imageView.isHidden = true
        }

        if let actionTitle = pageContent.actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
            actionButton.backgroundColor = pageTheme.actionButtonBackgroundColor
        } else {
            actionButton.isHidden = true
        }

        if let skipTitle = pageContent.skipTitle {
            skipButton.setTitle(skipTitle, for: .normal)
            skipButton.isHidden = false
            skipButton.tintColor = pageTheme.skipButtonTextColor
        } else {
            skipButton.isHidden = true
        }
    }
}

// MARK: - Actions
extension PageContentViewController {

    @objc private func actionButtonTapped() {
        delegate?.pageContentViewController(self, didTapActionForPage: pageContent)
        performAction()
    }

    @objc private func skipButtonTapped() {
        delegate?.pageContentViewController(self, didTapSkipForPage: pageContent)
    }

    private func performAction() {
        setLoading(true)
        Task { @MainActor in
            let result = await pageContent.onAction()
            setLoading(false)
            delegate?.pageContentViewController(self, actionDidComplete: result)
        }
    }
}

// MARK: - State
extension PageContentViewController {
 
    public func setLoading(_ loading: Bool) {
        actionButton.isEnabled = !loading

        if loading {
            // Store current title and clear it
            actionButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            // Restore title
            actionButton.setTitle(pageContent.actionTitle, for: .normal)
        }
    }

    public func updateActionButton(title: String?, enabled: Bool) {
        actionButton.setTitle(title, for: .normal)
        actionButton.isEnabled = enabled
        actionButton.isHidden = title == nil
    }
}
