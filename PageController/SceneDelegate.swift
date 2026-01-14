//
//  SceneDelegate.swift
//  PageController
//
//  Created by Eric Williams on 2022-08-07.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        // sample pages:
        let pages: [PageContent] = [
            // Welcome page
            GenericPage(
                id: "welcome",
                title: "PageController",
                subtitle: "An Onboarding Template",
                content: "Quickly build onboarding flows with permission handling, conditional flow, and customizable pages.",
                imageName: "star",
                actionTitle: "Get Started",
                skipTitle: nil
            ),

            GenericPage(
                id: "features",
                title: "All the Features",
                content: "Protocol-driven pages, async/await permission handling, conditional page display, and full navigation control.",
                imageName: "sparkles",
                actionTitle: "Continue",
                skipTitle: "Skip"
            ),

            // will auto-skip if permission is already granted
            LocationPermissionPage(
                title: "Enable Location",
                content: "Get permissions at the outset."
            ),

            // will auto-skip if permission is already granted
            NotificationPermissionPage(
                title: "Stay Updated",
                content: "Enable notifications from the start."
            ),

            // cmpletion page
            GenericPage(
                id: "complete",
                title: "That's All.",
                content: "You've completed the onboarding.",
                imageName: "checkmark.circle",
                actionTitle: "Continue to App",
                skipTitle: nil,
                onAction: { [weak self] in
                    // Transition to main app starts here
                    print("Onboarding done.")
                    return .success
                }
            )
        ]

        let pageTheme: any PageTheme = PageControllerTheme(
            id: "grey-theme",
            backgroundColour: UIColor(hex: "#F5F5F7"), // Cool light grey
            titleColor: UIColor(hex: "#26262E"), // Deep charcoal
            subtitle: UIColor(hex: "#4D5259"), // Blue-grey
            content: UIColor(hex: "#6B7078"), // Mid blue-grey
            imageTintColor: UIColor(hex: "#7A808A"), // Neutral blue-grey
            pageControlTintColor: UIColor(hex: "#8C9199"), // Muted blue-grey
            pageControlCurrentTintColor: UIColor(hex: "#4D5259"), // Blue-grey
            actionButtonBackgroundColor: UIColor(hex: "#474D54"), // Slate grey
            actionButtonTextColor: UIColor(hex: "#FFFFFF"),       // White
            skipButtonTextColor: UIColor(hex: "#8C9199") // Muted blue-grey
        )

        let configuration = PageControllerConfiguration(
            showPageControl: true,
            showNavigationButtons: true,
            showSkipButton: true,
            allowSwipeNavigation: true,
            pageControlTintColor: .systemGray,
            pageControlCurrentTintColor: .red,
            backgroundColor: pageTheme.backgroundColour,
            transitionStyle: .scroll
        )

        let pageController = PageControllerContainerViewController(
            pages: pages,
            theme: pageTheme,
            configuration: configuration
        )
        pageController.delegate = self

        window.rootViewController = pageController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}

// MARK: - PageControllerContainerDelegate
extension SceneDelegate: PageControllerContainerDelegate {
    func pageControllerDidComplete(_ controller: PageControllerContainerViewController) {
        print("Page controller completed.")

        // Example: Transition to main app
        // let mainVC = MainViewController()
        // window?.rootViewController = mainVC

        // ToDo: Onboaring Controller
    }

    func pageControllerDidCancel(_ controller: PageControllerContainerViewController) {
        print("Page controller cancelled")
    }

    func pageController(_ controller: PageControllerContainerViewController,
                        didNavigateToPageAtIndex index: Int) {
        print("Navigated to page \(index)")
    }
}
