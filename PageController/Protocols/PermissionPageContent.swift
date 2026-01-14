//
//  PermissionPageContent.swift
//  PageController
//
//  Protocol for permission-requesting pages with built-in status checking.
//

import Foundation

/// Enum representing permission states across different permission types
public enum PermissionStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case provisional // For notifications
}

/// Error type for permission-related failures
public enum PermissionError: Error {
    case denied
    case restricted
    case notDetermined
    case unknown
}

/// Protocol for permission-requesting pages
public protocol PermissionPageContent: PageContent {
    /// The current permission status
    func currentStatus() async -> PermissionStatus

    /// Request the permission from the user
    func requestPermission() async -> PermissionStatus

    /// Whether to auto-advance to the next page after permission is granted
    var autoAdvanceOnGrant: Bool { get }
}

// MARK: - Default Implementations

public extension PermissionPageContent {
    /// Default: Only show page if permission hasn't been determined yet
    func shouldShow() async -> Bool {
        let status = await currentStatus()
        return status == .notDetermined
    }

    /// Default action: Request permission and return appropriate result
    func onAction() async -> PageActionResult {
        let result = await requestPermission()
        switch result {
        case .authorized, .provisional:
            return .success
        case .denied, .restricted:
            return .failure(PermissionError.denied)
        case .notDetermined:
            return .cancelled
        }
    }

    var autoAdvanceOnGrant: Bool { true }
}
