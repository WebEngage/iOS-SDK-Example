//
//  WebViewBridge.swift
//  WebEngageExampleSwift
//
//  Created by Yogesh Singh on 07/02/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit
import WebKit
import WebEngage

class WebViewBridge: UIViewController {

    @IBAction func doneTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaultConfig = WKWebViewConfiguration()
        let webengageBridgeObject = WEGMobileBridge()

        let webengageConfig = webengageBridgeObject.enhanceWebConfig(forMobileWebBridge: defaultConfig)!

        let webView = WKWebView(frame: CGRect.init(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height - 130), configuration: webengageConfig)

        webView.layer.borderWidth = 1
        webView.layer.borderColor = UIColor.red.cgColor

        let url = URL(string: "http://shahrukh931.tumblr.com/")
        let requestObj = URLRequest(url: url! as URL)
        webView.load(requestObj)

        self.view.addSubview(webView)
    }
}
