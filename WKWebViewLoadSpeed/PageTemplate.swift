//
//  PageTemplate.swift
//  WKWebViewLoadSpeed
//
//  Created by alastair.coote on 18/01/2018.
//  Copyright © 2018 Alastair Coote. All rights reserved.
//

import Foundation
import UIKit

func createPageTemplate(withBackground bgColor: UIColor) -> String {
    
    var testParagraphs:String = ""

    
    for i in 0..<20 {
        testParagraphs += "<p>Test paragraph</p>"
    }
    
    
    return """

    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <style>
    p {
    background: #fff;
    margin: 20px;
    padding: 20px;
    }
    </style>
    
    </head>
    <body style='background:#\(bgColor.toHexString)'>
        <h1>Page load test</h1>
    <p>Was visible in <span id='loadtime'></span> seconds</p>
    <p><a href="/load-normal">Load another, normally</a></p>
    <p><a href="/load-precreated">Load another, pre-created</a></p>
    <p><a href="/load-injected">Load another, injecting content</a></p>
    \(testParagraphs)
    </body>

    
    """
}
