//
//  LocationPermissionHelper.swift
//  PageController
//
//  Created by Eric Williams on 2022-09-14.
//

import CoreLocation
import UIKit

/// Helper class for location permission management
public final class LocationPermissionManager: NSObject {

    public static let shared = LocationPermissionManager()

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    private override init() {
        super.init()
    }

    public var currentStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    public var permissionStatus: PermissionStatus {
        switch currentStatus {
        case .notDetermined:
            return .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
    }
}

extension LocationPermissionManager {
    public func requestWhenInUseAuthorization() async -> CLAuthorizationStatus {
        // If already determined, return current status
        guard currentStatus == .notDetermined else {
            return currentStatus
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    public func requestAlwaysAuthorization() async -> CLAuthorizationStatus {
        // Can upgrade from whenInUse to always
        guard currentStatus == .notDetermined || currentStatus == .authorizedWhenInUse else {
            return currentStatus
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestAlwaysAuthorization()
        }
    }

    public func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationPermissionManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationContinuation?.resume(returning: manager.authorizationStatus)
        authorizationContinuation = nil
    }
}
