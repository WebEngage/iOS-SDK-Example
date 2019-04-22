//
//  Router.swift
//  Public Demo
//
//  Created by Yogesh Singh on 22/04/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit

struct Router {
    
    static func getRootViewController() -> UIViewController? {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        return (storyboard.instantiateInitialViewController())
    }
}
