//
//  GenericPage.swift
//  PageController
//
//  Created by Eric Williams on 2022-08-08.
//

import UIKit
 
public final class GenericPage: PageContent { 
    public let id: String
    public var title: String
    public var subtitle: String?
    public var content: String
    public var image: UIImage?
    public var imageName: String?
    public var actionTitle: String?
    public var skipTitle: String?

    private var shouldShowClosure: (() async -> Bool)?
    private var onActionClosure: (() async -> PageActionResult)?
    private var onAppearClosure: (() -> Void)?
    private var onDisappearClosure: (() -> Void)?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        content: String,
        image: UIImage? = nil,
        imageName: String? = nil,
        actionTitle: String? = nil,
        skipTitle: String? = "Skip",
        shouldShow: (() async -> Bool)? = nil,
        onAction: (() async -> PageActionResult)? = nil,
        onAppear: (() -> Void)? = nil,
        onDisappear: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.image = image
        self.imageName = imageName
        self.actionTitle = actionTitle
        self.skipTitle = skipTitle
        self.shouldShowClosure = shouldShow
        self.onActionClosure = onAction
        self.onAppearClosure = onAppear
        self.onDisappearClosure = onDisappear
    }

    public func shouldShow() async -> Bool {
        await shouldShowClosure?() ?? true
    }

    public func onAction() async -> PageActionResult {
        await onActionClosure?() ?? .success
    }

    public func onAppear() {
        onAppearClosure?()
    }

    public func onDisappear() {
        onDisappearClosure?()
    }
}

public extension GenericPage {
    static func info(
        id: String,
        title: String,
        content: String,
        imageName: String? = nil
    ) -> GenericPage {
        GenericPage(
            id: id,
            title: title,
            content: content,
            imageName: imageName,
            actionTitle: nil,
            skipTitle: nil
        )
    }

    static func withAction(
        id: String,
        title: String,
        content: String,
        imageName: String? = nil,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> GenericPage {
        GenericPage(
            id: id,
            title: title,
            content: content,
            imageName: imageName,
            actionTitle: actionTitle,
            skipTitle: nil,
            onAction: {
                action()
                return .success
            }
        )
    }
}
