//
//  WebShellCustomInject.swift
//  WebShell
//
//  Created by Wesley de Groot on 14-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import WebKit

extension ViewController {
    /**
     _WSInjectJS
     
     Injects JavaScript in to a frame, or other position
     
     - Parameter jsContext: JSContext!
     
     - Note: @wdg #36
     */
	internal func _WSInjectJS(jsContext: JSContext!) {
		// JSInject
		if (SETTINGS["JSInject"] as! String != "") {
			jsContext.evaluateScript(SETTINGS["JSInject"] as! String)
		}
	}

    /**
     _WSInjectCSS
     
     Injects CSS in to a frame, or other position
     
     - Parameter jsContext: JSContext!
     
     - Note: @wdg #36
     */
	internal func _WSInjectCSS(jsContext: JSContext!) {
		// CSSInject
		if (SETTINGS["CSSInject"] as! String != "") {
            let css:String = (SETTINGS["CSSInject"] as! String)
                                .stringByReplacingOccurrencesOfString("\n", withString: "")
                                .stringByReplacingOccurrencesOfString("\r", withString: "")
                                .stringByReplacingOccurrencesOfString("'", withString: "\\'")
            
            jsContext.evaluateScript("var css='\(css)',head=document.head,style=document.createElement('style');style.type='text/css';if (style.styleSheet){style.styleSheet.cssText = css;}else{style.appendChild(document.createTextNode(css));}head.appendChild(style);")
		}
	}
}