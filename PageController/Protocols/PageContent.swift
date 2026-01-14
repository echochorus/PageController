//
//  PageContent.swift
//  PageController
//
//  Created by Eric Williams on 2022-09-11.
//

import UIKit

public enum PageActionResult: Sendable {
    case success
    case failure(Error)
    case cancelled
}

public protocol PageContent: AnyObject, Identifiable {
    var id: String { get }

    var title: String { get }
    var subtitle: String? { get }
    var content: String { get }
    var image: UIImage? { get }
    var imageName: String? { get }

    var actionTitle: String? { get }
    var skipTitle: String? { get }

    func shouldShow() async -> Bool
    func onAppear()
    func onDisappear()
    func onAction() async -> PageActionResult
}

// MARK: - Default Implementation
public extension PageContent {
    var subtitle: String? { nil }
    var image: UIImage? { nil }
    var imageName: String? { nil }
    var actionTitle: String? { nil }
    var skipTitle: String? { "Skip" }

    func onAppear() {}
    func onDisappear() {}
    func shouldShow() async -> Bool { true }
    func onAction() async -> PageActionResult { .success }
}

public protocol PageTheme: AnyObject, Identifiable {
    var id: String { get }

    var backgroundColour: UIColor { get }
    var titleColor: UIColor { get }
    var subtitle: UIColor { get }
    var content: UIColor { get }
    var imageTintColor: UIColor { get }
    var pageControlTintColor: UIColor { get }
    var pageControlCurrentTintColor: UIColor { get } 
    var actionButtonBackgroundColor: UIColor { get }
    var actionButtonTextColor: UIColor { get }

    var skipButtonTextColor: UIColor { get }

}
