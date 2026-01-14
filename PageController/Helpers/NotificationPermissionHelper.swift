//
//  NotificationPermissionHelper.swift
//  PageController
//
//  Created by Eric Williams on 2022-11-20.
//

import UserNotifications
import UIKit

/// Helper class for notification permission management
public final class NotificationPermissionHelper {

    public static let shared = NotificationPermissionHelper()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    public func currentStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    public func permissionStatus() async -> PermissionStatus {
        let status = await currentStatus()
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .provisional:
            return .provisional
        case .ephemeral:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    /// Request notification authorization:
    /// parameter options for authorization request
    /// returns authorization request response
    public func requestAuthorization(options: UNAuthorizationOptions = [.alert, .sound, .badge]) async -> Bool {
        do {
            return try await center.requestAuthorization(options: options)
        } catch {
            return false
        }
    }

    /// Request authorization and return the resulting permission status:
    /// parameter options for authorization request
    /// returns  permission status
    public func requestAuthorizationWithStatus(options: UNAuthorizationOptions = [.alert, .sound, .badge]) async -> PermissionStatus {
        let granted = await requestAuthorization(options: options)
        return granted ? .authorized : .denied
    }

    public func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}
