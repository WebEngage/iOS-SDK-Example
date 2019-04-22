//
//  AppDelegate.swift
//  Public Demo
//
//  Created by Yogesh Singh on 22/04/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit
import WebEngage
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // do nothing
        }
        
        AnalyticsHandler.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
}


extension AppDelegate: WEGAppDelegate {

    func wegHandleDeeplink(_ deeplink: String!, userData data: [AnyHashable : Any]!) {

        print("Deeplink URL received from Push Notification: \(deeplink!)")
    }
    
    func didReceiveAnonymousID(_ anonymousID: String!, for reason: WEGReason) {
        print("Anonymous ID:\(anonymousID)  got refreshed for reason: \(reason)")
    }
}
