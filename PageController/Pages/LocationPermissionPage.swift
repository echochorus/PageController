//
//  LocationPermissionPage.swift
//  PageController
//
//  Created by Eric Williams on 2022-11-25.
//

import UIKit
import CoreLocation

/// Built-in page for requesting location permission
public final class LocationPermissionPage: PermissionPageContent {

    public enum AuthorizationType {
        case whenInUse
        case always
    }

    public let id: String
    public var title: String
    public var subtitle: String?
    public var content: String
    public var image: UIImage?
    public var imageName: String?
    public var actionTitle: String?
    public var skipTitle: String?


    public var autoAdvanceOnGrant: Bool


    private let locationPermissionManager = LocationPermissionManager.shared
    private let authorizationType: AuthorizationType

    public init(
        id: String = "location_permission",
        title: String = "Enable Location",
        subtitle: String? = nil,
        content: String = "Allow access to your location to enhance your experience with location-based features.",
        image: UIImage? = nil,
        imageName: String? = "location.fill",
        actionTitle: String? = "Enable Location",
        skipTitle: String? = "Not Now",
        authorizationType: AuthorizationType = .whenInUse,
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
        self.authorizationType = authorizationType
        self.autoAdvanceOnGrant = autoAdvanceOnGrant
    }

    public func currentStatus() async -> PermissionStatus {
        locationPermissionManager.permissionStatus
    }

    public func requestPermission() async -> PermissionStatus {
        let status: CLAuthorizationStatus

        switch authorizationType {
        case .whenInUse:
            status = await locationPermissionManager.requestWhenInUseAuthorization()
        case .always:
            status = await locationPermissionManager.requestAlwaysAuthorization()
        }

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }

    public func onAppear() { }

    public func onDisappear() { }
}

public extension LocationPermissionPage {
    /// For custom messaging:
    static func custom(
        title: String,
        content: String,
        authorizationType: AuthorizationType = .whenInUse
    ) -> LocationPermissionPage {
        LocationPermissionPage(
            title: title,
            content: content,
            authorizationType: authorizationType
        )
    }
}
