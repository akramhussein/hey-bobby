//
//  Theme.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 19/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import UIKit

struct Theme {

    static var statusBar: UIView? {
        return (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView
    }

    static func apply(statusBarColor: UIColor) {
        UIBarButtonItem.appearance().tintColor = .white

        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().isOpaque = true
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 26.0)
        ]

        UINavigationBar.appearance().setBackgroundImage(UIImage(),
                                                        for: .any,
                                                        barMetrics: .default)

        UINavigationBar.appearance().shadowImage = UIImage()

        self.statusBar?.backgroundColor = statusBarColor
    }
}
