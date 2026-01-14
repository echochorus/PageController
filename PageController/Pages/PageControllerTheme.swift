//
//  PageControllerTheme.swift
//  PageController
//
//  Created by Eric Williams on 2024-11-14.
//

import UIKit

final class PageControllerTheme: PageTheme {

    var id: String
    var backgroundColour: UIColor
    var titleColor: UIColor
    var subtitle: UIColor
    var content: UIColor
    var imageTintColor: UIColor
    var pageControlTintColor: UIColor 
    var pageControlCurrentTintColor: UIColor
    var actionButtonBackgroundColor: UIColor
    var actionButtonTextColor: UIColor 
    var skipButtonTextColor: UIColor


    public init(
        id: String,
        backgroundColour: UIColor,
        titleColor: UIColor,
        subtitle: UIColor,
        content: UIColor,
        imageTintColor: UIColor,
        pageControlTintColor: UIColor,
        pageControlCurrentTintColor: UIColor,
        actionButtonBackgroundColor: UIColor,
        actionButtonTextColor: UIColor,
        skipButtonTextColor: UIColor
    ) {
        self.id = id
        self.backgroundColour = backgroundColour
        self.titleColor = titleColor
        self.subtitle = subtitle
        self.content = content
        self.imageTintColor = imageTintColor
        self.pageControlTintColor = pageControlTintColor
        self.pageControlCurrentTintColor = pageControlCurrentTintColor
        self.actionButtonBackgroundColor = actionButtonBackgroundColor
        self.actionButtonTextColor = actionButtonTextColor
        self.skipButtonTextColor = skipButtonTextColor
    }
}
