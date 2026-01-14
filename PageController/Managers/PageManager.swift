//
//  PageManager.swift
//  PageController
//
//  Created by Eric Williams on 2022-08-08.
//

import Foundation
import Combine

public protocol PageManagerDelegate: AnyObject {
    func pageManagerDidUpdateVisiblePages(_ manager: PageManager)
    func pageManager(_ manager: PageManager, didNavigateToIndex index: Int)
    func pageManagerDidComplete(_ manager: PageManager)
}

public final class PageManager: ObservableObject {
    @Published public private(set) var allPages: [any PageContent]
    @Published public private(set) var visiblePages: [any PageContent] = []
    @Published public private(set) var currentIndex: Int = 0
    @Published public private(set) var isLoading: Bool = false

    public var currentPage: (any PageContent)? {
        guard currentIndex >= 0 && currentIndex < visiblePages.count else { return nil }
        return visiblePages[currentIndex]
    }

    public var canGoBack: Bool {
        currentIndex > 0
    }

    public var canGoNext: Bool {
        currentIndex < visiblePages.count - 1
    }

    public var isLastPage: Bool {
        currentIndex == visiblePages.count - 1
    }

    public var isFirstPage: Bool {
        currentIndex == 0
    }

    public var progress: Float {
        guard visiblePages.count > 0 else { return 0 }
        return Float(currentIndex + 1) / Float(visiblePages.count)
    }

    public var pageCount: Int {
        visiblePages.count
    }

    public weak var delegate: PageManagerDelegate?

    private var cancellables = Set<AnyCancellable>()

    public init(pages: [any PageContent] = []) {
        self.allPages = pages
    }
 
    public func addPages(_ pages: [any PageContent]) {
        allPages.append(contentsOf: pages)
    }

    public func insertPage(_ page: any PageContent, at index: Int) {
        allPages.insert(page, at: min(index, allPages.count))
    }

    public func removePage(withId id: String) {
        allPages.removeAll { $0.id == id }
    }

    /// Replace all pages
    public func setPages(_ pages: [any PageContent]) {
        allPages = pages
    }
    
    @MainActor
    public func rebuildVisiblePages() async {
        isLoading = true
        var visible: [any PageContent] = []

        for page in allPages {
            if await page.shouldShow() {
                visible.append(page)
            }
        }

        visiblePages = visible

        // Adjust currentIndex if needed
        if currentIndex >= visiblePages.count {
            currentIndex = max(0, visiblePages.count - 1)
        }

        isLoading = false
        delegate?.pageManagerDidUpdateVisiblePages(self)
    }
}

// MARK: - Navigation
extension PageManager {
    @discardableResult
    public func next() -> Bool {
        guard canGoNext else { return false }
        currentIndex += 1
        delegate?.pageManager(self, didNavigateToIndex: currentIndex)
        return true
    }

    @discardableResult
    public func previous() -> Bool {
        guard canGoBack else { return false }
        currentIndex -= 1
        delegate?.pageManager(self, didNavigateToIndex: currentIndex)
        return true
    }

    @discardableResult
    public func navigateTo(index: Int) -> Bool {
        guard index >= 0 && index < visiblePages.count else { return false }
        currentIndex = index
        delegate?.pageManager(self, didNavigateToIndex: currentIndex)
        return true
    }

    public func skipToEnd() {
        currentIndex = max(0, visiblePages.count - 1)
        delegate?.pageManager(self, didNavigateToIndex: currentIndex)
    }

    public func complete() {
        delegate?.pageManagerDidComplete(self)
    }

    @MainActor
    public func advanceAfterAction() async {
        // Rebuild when conditions changed (i.e.: permission granted)
        await rebuildVisiblePages()

        if canGoNext {
            _ = next()
        } else {
            complete()
        }
    }

    public func canProceed() async -> Bool {
        guard let currentPage = currentPage else { return true }

        // For permission pages, check if permission was granted
        if let permissionPage = currentPage as? (any PermissionPageContent) {
            let status = await permissionPage.currentStatus()
            return status == .authorized || status == .provisional
        }

        return true
    }

    public func page(at index: Int) -> (any PageContent)? {
        guard index >= 0 && index < visiblePages.count else { return nil }
        return visiblePages[index]
    }

    public func indexOfPage(withId id: String) -> Int? {
        visiblePages.firstIndex { $0.id == id }
    }
}
