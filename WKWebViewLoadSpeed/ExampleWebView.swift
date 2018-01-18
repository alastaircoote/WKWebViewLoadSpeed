//
//  ExampleWebView.swift
//  WKWebViewLoadSpeed
//
//  Created by alastair.coote on 18/01/2018.
//  Copyright © 2018 Alastair Coote. All rights reserved.
//

import Foundation
import UIKit
import WebKit

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
    
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff),
            Int(a * 0xff)
        )
    }
}

extension UIView {
    func capture() -> UIImage? {
        var image: UIImage?
        
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.opaque = isOpaque
            
            let renderer = UIGraphicsImageRenderer(size: CGSize(width:1,height:1), format: format)
            image = renderer.image { context in
                drawHierarchy(in: frame, afterScreenUpdates: true)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, UIScreen.main.scale)
            drawHierarchy(in: frame, afterScreenUpdates: true)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return image
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        
        let pixelData = self.cgImage?.dataProvider?.data!
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let b = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let r = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

enum LoadStyle {
    case normal
    case staged
    case injected
}



class ExampleWebView : UIViewController, WKNavigationDelegate {
    
    let webview:WKWebView
    let backgroundColor: UIColor
    let startTime:TimeInterval
    
    
    init(loadStyle: LoadStyle) {
        if loadStyle == .normal {
            self.webview = WKWebView(frame: UIScreen.main.bounds)
        } else {
            self.webview = staging.getWaiting()
        }
        
        self.webview.scrollView.backgroundColor = UIColor.blue
        self.backgroundColor = UIColor.random
        self.startTime = Date().timeIntervalSince1970
        super.init(nibName: nil, bundle: nil)
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.addSubview(self.webview)
        self.title = "Test WKWebView"
        
        let pageTemplate = createPageTemplate(withBackground: self.backgroundColor)
        
        if loadStyle == .injected {
            
            let escaped = pageTemplate
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "")
            self.webview.evaluateJavaScript("document.documentElement.innerHTML = \"\(escaped)\"; document.documentElement.innerHTML", completionHandler: { (result, err) in
                NSLog("oh no! \(err) \(result)")
            })
        } else {
            self.webview.loadHTMLString("<html>" + pageTemplate + "</html>", baseURL: URL(string: "test://test/first"))
        }
        self.webview.navigationDelegate = self
        self.checkColor()

    }
    
    func checkColor() {
        let test = self.webview.capture()!
        let foundColor = test.getPixelColor(pos: CGPoint(x: 0, y: 0))
        
//        self.view.addSubview(UIImageView(image:test))
        
        if foundColor.toHexString == self.backgroundColor.toHexString {
            NSLog("WOAH! \(Date().timeIntervalSince1970 - self.startTime), (setLoadTime(\(Date().timeIntervalSince1970 - self.startTime))")
            self.webview.evaluateJavaScript("document.getElementById('loadtime').innerHTML = \(Date().timeIntervalSince1970 - self.startTime)", completionHandler: nil)
            staging.createNewWaitingView()
        } else {
            NSLog("NO \(foundColor.toHexString) \(self.backgroundColor.toHexString)")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: self.checkColor)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let command = navigationAction.request.url?.path
        
        if command == "/first" {
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.cancel)
        
        if command == "/load-normal" {
            self.navigationController?.pushViewController(ExampleWebView(loadStyle: LoadStyle.normal), animated: true)
        }
        
        if command == "/load-precreated" {
            self.navigationController?.pushViewController(ExampleWebView(loadStyle: LoadStyle.staged), animated: true)
        }
        
        if command == "/load-injected" {
            self.navigationController?.pushViewController(ExampleWebView(loadStyle: LoadStyle.injected), animated: true)
        }
        
        
        
        NSLog(command!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
