//
//  AppDelegate.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 19/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AHUtils

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self])

        Theme.apply(statusBarColor: .primaryColor)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white

        let nav = UINavigationController(rootViewController: MainViewController())
        nav.navigationBar.barTintColor = .primaryColor
        nav.navigationBar.backgroundColor = .primaryColor
        
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? [String : String],
            let alertValue = userInfo["alert"],
            let alert = Alert(rawValue: alertValue),
            let severityValue = userInfo["severity"],
            let severity = Severity(rawValue: severityValue) {
            let alertVC = AlertViewController(alert: alert, severity: severity)
            nav.pushViewController(alertVC, animated: false)
        }

        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if application.applicationState == .inactive {
            guard let userInfo = notification.userInfo else { return }
            
            if let alertValue = userInfo["alert"] as? String,
                let alert = Alert(rawValue: alertValue),
                let severityValue = userInfo["severity"] as? String,
                let severity = Severity(rawValue: severityValue),
                let rootVC = self.window?.rootViewController as? UINavigationController {
                
                if let _ = rootVC.viewControllers.last as? AlertViewController {
                    rootVC.popViewController(animated: false)
                }
                
                let alertVC = AlertViewController(alert: alert, severity: severity)
                rootVC.pushViewController(alertVC, animated: false)
            }
        }
    }
    
    
}
