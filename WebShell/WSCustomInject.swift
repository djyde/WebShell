//
//  WebShellCustomInject.swift
//  WebShell
//
//  Created by Wesley de Groot on 14-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import WebKit

extension WSViewController {
	/**
	 _WSInjectJS

	 Injects JavaScript in to a frame, or other position

	 - Parameter jsContext: JSContext!

	 - Note: @wdg #36
	 */
	internal func _WSInjectJS(_ jsContext: JSContext!) {
		// JSInject
		if !settings.jsInject.isEmpty {
			jsContext.evaluateScript(settings.jsInject)
		}
		_WSFindJS(jsContext)
	}

	/**
	 _WSInjectCSS

	 Injects CSS in to a frame, or other position

	 - Parameter jsContext: JSContext!

	 - Note: @wdg #36
	 */
	internal func _WSInjectCSS(_ jsContext: JSContext!) {
		// CSSInject
		if !settings.cssInject.isEmpty {
			let css = settings.cssInject
				.replacingOccurrences(of: "\n", with: "")
				.replacingOccurrences(of: "\r", with: "")
				.replacingOccurrences(of: "'", with: "\\'")

			jsContext.evaluateScript("var css='\(css)',head=document.head,style=document.createElement('style');style.type='text/css';if (style.styleSheet){style.styleSheet.cssText = css;}else{style.appendChild(document.createTextNode(css));}head.appendChild(style);")
		}
		_WSFindCSS(jsContext)
	}

    /**
     _WSFindCSS
     
     Find CSS to inject
     
     - Parameter jsContext: JSContext!
     
     - Note: @wdg #36
     */
	internal func _WSFindCSS(_ jsContext: JSContext!) {
		if settings.enableInjectImport { // (EII)

			let Seperated = (CommandLine.arguments[0]).components(separatedBy: "/")
			var newPath = ""

			for i in 0 ... (Seperated.count - 3) {
				newPath = newPath + Seperated[i] + "/"
			}

			newPath = newPath + "Resources/CSS"

			if FileManager().fileExists(atPath: newPath) {
				do {
					let fm = FileManager.default
					let contents = try fm.contentsOfDirectory(atPath: newPath)
					let filter = NSPredicate(format: "self ENDSWITH '.css'", argumentArray: nil)
					let fileList = contents.filter { filter.evaluate(with: $0) }
					for injectFile in fileList {
						let fc = try String(contentsOfFile: newPath + "/" + injectFile, encoding: String.Encoding.utf8)
                            .replacingOccurrences(of: "\n", with: "")
							.replacingOccurrences(of: "\r", with: "")
							.replacingOccurrences(of: "'", with: "\\'")
						jsContext.evaluateScript("var css='\(fc)',head=document.head,style=document.createElement('style');style.type='text/css';if (style.styleSheet){style.styleSheet.cssText = css;}else{style.appendChild(document.createTextNode(css));}head.appendChild(style);")
					}
				}
				catch { }
				// Look
			} else {
				// Create Directory
				do {
					try FileManager().createDirectory(atPath: newPath, withIntermediateDirectories: true, attributes: nil)
				}
				catch {
					print("Failed to create path.")
				}
			}
		}
	}

    /**
     _WSFindJS
     
     Find JS to inject
     
     - Parameter jsContext: JSContext!
     
     - Note: @wdg #36
     */
	internal func _WSFindJS(_ jsContext: JSContext!) {
		if settings.enableInjectImport { // (EII)

			let Seperated = (CommandLine.arguments[0]).components(separatedBy: "/")
			var newPath = ""

			for i in 0 ... (Seperated.count - 3) {
				newPath = newPath + Seperated[i] + "/"
			}

			newPath = newPath + "Resources/JavaScript"

			if FileManager().fileExists(atPath: newPath) {
				do {
					let fm = FileManager.default
					let contents = try fm.contentsOfDirectory(atPath: newPath)
					let filter = NSPredicate(format: "self ENDSWITH '.js'", argumentArray: nil)
					let fileList = contents.filter { filter.evaluate(with: $0) }
					for injectFile in fileList {
						let fc = try String(contentsOfFile: newPath + "/" + injectFile, encoding: String.Encoding.utf8)
						jsContext.evaluateScript(fc)
					}
				}
				catch { }
				// Look
			} else {
				// Create Directory
				do {
					try FileManager().createDirectory(atPath: newPath, withIntermediateDirectories: true, attributes: nil)
				}
				catch {
					print("Failed to create path.")
				}
			}
		}
	}
}
