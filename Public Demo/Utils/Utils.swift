//
//  Utils.swift
//  Public Demo
//
//  Created by Yogesh Singh on 22/04/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import Foundation

struct Utils {
    static func getAppInfoPlistItems() -> [String: Any]? {
        return Bundle.main.infoDictionary
    }
}
