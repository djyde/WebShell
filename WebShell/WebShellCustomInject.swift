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
		if (WebShell().Settings["JSInject"] as! String != "") {
			jsContext.evaluateScript(WebShell().Settings["JSInject"] as! String)
		}
		_WSFindJS(jsContext)
	}

	/**
	 _WSInjectCSS

	 Injects CSS in to a frame, or other position

	 - Parameter jsContext: JSContext!

	 - Note: @wdg #36
	 */
	internal func _WSInjectCSS(jsContext: JSContext!) {
		// CSSInject
		if (WebShell().Settings["CSSInject"] as! String != "") {
			let css: String = (WebShell().Settings["CSSInject"] as! String)
				.stringByReplacingOccurrencesOfString("\n", withString: "")
				.stringByReplacingOccurrencesOfString("\r", withString: "")
				.stringByReplacingOccurrencesOfString("'", withString: "\\'")

			jsContext.evaluateScript("var css='\(css)',head=document.head,style=document.createElement('style');style.type='text/css';if (style.styleSheet){style.styleSheet.cssText = css;}else{style.appendChild(document.createTextNode(css));}head.appendChild(style);")
		}
		_WSFindCSS(jsContext)
	}

	internal func _WSFindCSS(jsContext: JSContext!) {
		if (WebShell().Settings["EnableInjectImport"] as! Bool) { // (EII)

			let Seperated = (Process.arguments[0]).componentsSeparatedByString("/")
			var newPath = ""

			for i in 0 ... (Seperated.count - 3) {
				newPath = newPath.stringByAppendingString(Seperated[i]) + "/"
			}

			newPath = newPath.stringByAppendingString("Resources/CSS")

			if NSFileManager().fileExistsAtPath(newPath) {
				do {
					let fm = NSFileManager.defaultManager()
					let contents = try fm.contentsOfDirectoryAtPath(newPath)
					let filter = NSPredicate(format: "self ENDSWITH '.css'", argumentArray: nil)
					let fileList = contents.filter { filter.evaluateWithObject($0) }
					for injectFile in fileList {
						let fc = try String(contentsOfFile: newPath + "/" + injectFile, encoding: NSUTF8StringEncoding)
                            .stringByReplacingOccurrencesOfString("\n", withString: "")
							.stringByReplacingOccurrencesOfString("\r", withString: "")
							.stringByReplacingOccurrencesOfString("'", withString: "\\'")
						jsContext.evaluateScript("var css='\(fc)',head=document.head,style=document.createElement('style');style.type='text/css';if (style.styleSheet){style.styleSheet.cssText = css;}else{style.appendChild(document.createTextNode(css));}head.appendChild(style);")
					}
				}
				catch { }
				// Look
			} else {
				// Create Directory
				do {
					try NSFileManager().createDirectoryAtPath(newPath, withIntermediateDirectories: true, attributes: nil)
				}
				catch {
					print("Failed to create path.")
				}
			}
		}
	}

	internal func _WSFindJS(jsContext: JSContext!) {
		if (WebShell().Settings["EnableInjectImport"] as! Bool) { // (EII)

			let Seperated = (Process.arguments[0]).componentsSeparatedByString("/")
			var newPath = ""

			for i in 0 ... (Seperated.count - 3) {
				newPath = newPath.stringByAppendingString(Seperated[i]) + "/"
			}

			newPath = newPath.stringByAppendingString("Resources/JavaScript")

			if NSFileManager().fileExistsAtPath(newPath) {
				do {
					let fm = NSFileManager.defaultManager()
					let contents = try fm.contentsOfDirectoryAtPath(newPath)
					let filter = NSPredicate(format: "self ENDSWITH '.js'", argumentArray: nil)
					let fileList = contents.filter { filter.evaluateWithObject($0) }
					for injectFile in fileList {
						let fc = try String(contentsOfFile: newPath + "/" + injectFile, encoding: NSUTF8StringEncoding)
						jsContext.evaluateScript(fc)
					}
				}
				catch { }
				// Look
			} else {
				// Create Directory
				do {
					try NSFileManager().createDirectoryAtPath(newPath, withIntermediateDirectories: true, attributes: nil)
				}
				catch {
					print("Failed to create path.")
				}
			}
		}
	}
}