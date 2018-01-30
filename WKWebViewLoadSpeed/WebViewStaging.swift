//
//  WebViewStaging.swift
//  WKWebViewLoadSpeed
//
//  Created by alastair.coote on 18/01/2018.
//  Copyright © 2018 Alastair Coote. All rights reserved.
//

import Foundation
import WebKit


class WebviewStaging {
    
    var waitingWebview: WKWebView?
    
    init() {
    }
    
    
    func createNewWaitingView() {
        NSLog("creating new pending webview")
        self.waitingWebview = WKWebView(frame: UIScreen.main.bounds)
        self.waitingWebview!.loadHTMLString("<html><body></body></html>", baseURL: URL(string: "test://testa/first"))
    }
    
    func getWaiting() -> WKWebView {
        return self.waitingWebview!
    }
}

// static instance of the above
let staging = WebviewStaging()
