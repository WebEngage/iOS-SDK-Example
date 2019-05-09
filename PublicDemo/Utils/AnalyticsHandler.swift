//
//  AnalyticsHandler.swift
//  Public Demo
//
//  Created by Yogesh Singh on 22/04/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit
import WebEngage

class AnalyticsHandler {

    static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {

        WebEngage.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        WebEngage.sharedInstance().analytics.trackEvent(withName: "app_launched")

        WebEngage.sharedInstance()?.autoTrackUserLocation(with: .forCountry)
    }
}
