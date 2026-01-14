//
//  NotificationPermissionPage.swift
//  PageController
//
//  Built-in page for requesting notification permission.
//

import UIKit
import UserNotifications

/// Built-in page for requesting notification permission
public final class NotificationPermissionPage: PermissionPageContent {

    // MARK: - PageContent Properties

    public let id: String
    public var title: String
    public var subtitle: String?
    public var content: String
    public var image: UIImage?
    public var imageName: String?
    public var actionTitle: String?
    public var skipTitle: String?

    // MARK: - PermissionPageContent Properties

    public var autoAdvanceOnGrant: Bool

    // MARK: - Private Properties

    private let helper = NotificationPermissionHelper.shared
    private let authorizationOptions: UNAuthorizationOptions

    // MARK: - Initialization

    public init(
        id: String = "notification_permission",
        title: String = "Stay Notified",
        subtitle: String? = nil,
        content: String = "Enable notifications to receive important updates and stay informed.",
        image: UIImage? = nil,
        imageName: String? = "bell.fill",
        actionTitle: String? = "Enable Notifications",
        skipTitle: String? = "Not Now",
        authorizationOptions: UNAuthorizationOptions = [.alert, .sound, .badge],
        autoAdvanceOnGrant: Bool = true
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.image = image
        self.imageName = imageName
        self.actionTitle = actionTitle
        self.skipTitle = skipTitle
        self.authorizationOptions = authorizationOptions
        self.autoAdvanceOnGrant = autoAdvanceOnGrant
    }

    // MARK: - PermissionPageContent

    public func currentStatus() async -> PermissionStatus {
        await helper.permissionStatus()
    }

    public func requestPermission() async -> PermissionStatus {
        let granted = await helper.requestAuthorization(options: authorizationOptions)
        return granted ? .authorized : .denied
    }

    // MARK: - Lifecycle

    public func onAppear() {}
    public func onDisappear() {}
}

// MARK: - Convenience Initializers

public extension NotificationPermissionPage {
    /// Create with custom messaging
    static func custom(
        title: String,
        content: String,
        options: UNAuthorizationOptions = [.alert, .sound, .badge]
    ) -> NotificationPermissionPage {
        NotificationPermissionPage(
            title: title,
            content: content,
            authorizationOptions: options
        )
    }

    /// Create for alerts only (no badge or sound)
    static var alertsOnly: NotificationPermissionPage {
        NotificationPermissionPage(
            content: "Enable notifications to receive important alerts.",
            authorizationOptions: [.alert]
        )
    }
}
