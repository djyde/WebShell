//
//  WebShellInjector.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import WebKit


/**
 This extension will catch up with the webhooks!
 - Note: @wdg: Iframes, Webhooks, and more. (Issue: #23, #5, #2, #35, #38, #39 & More)
 */
extension ViewController {
	/**
	 Loop Trough iFrames

	 This function will loop trough different frames (if they exists) and will inject all the javascript what they want!

	 - Note: @wdg Fix for iFrames (Issue #23)
	 */
	func loopThroughiFrames() {
		if (mainWebview.subviews.count > 0) {
			// We've got subViews!
			
			if (mainWebview.subviews[0].subviews.count > 0) {
				// mainWebview.subviews[0] = WebFrameView
				
				let goodKids = mainWebview.subviews[0].subviews[0]
				// mainWebview.subviews[0] = WebFrameView.subviews[0] = WebDynamicScrollBarsView (= goodKids)
				
				var children = goodKids.subviews[0]
				// mainWebview.subviews[0] = WebFrameView.subviews[0] = WebDynamicScrollBarsView.subviews[0] = WebClipView (= children)
				
				// We need > 0 subviews here, otherwise don't add them. and the script will continue
				if children.subviews.count > 0 {
					// mainWebview.subviews[0] = WebFrameView.subviews[0] = WebDynamicScrollBarsView.subviews[0] = WebClipView.subviews[0] = WebHTMLView
					children = goodKids.subviews[0].subviews[0]
				}
				
				// Finally. parsing those good old iframes
				// We don't check them for iframes, somewhere the fun must be ended.
				for child in children.subviews {
                    Dprint("Found a Child...")
                    Ddump(child)
					// mainWebview.subviews[0] = WebFrameView.subviews[0] = WebDynamicScrollBarsView.subviews[0] = WebClipView.subviews[0] = WebHTMLView.subviews[x] = WebFrameView (Finally) (name = child)
					if (child.isKind(of: WebFrameView.self)) {
						let frame: NSView = child
						let context: JSContext = frame.webFrame.javaScriptContext
						
                        Dprint("Injecting hooks!")
						injectWebhooks(context)
					}
				}
			}
		}
	}
	
	/**
	 InjectWebhooks

	 Injects javascript in to a frame, or other position

	 - Parameter jsContext: JSContext!

	 - Note: @wdg Fixes a lot (Issues #23, #5, #2, #35, #38, #39 & More.)
	 */
	func injectWebhooks(_ jsContext: JSContext!) {
		// Injecting javascript (via jsContext)
		
		// @wdg Hack URL's if settings is set.
		// Issue: #5
		if ((WebShellSettings["openInNewScreen"] as? Bool) != false) {
			// _blank to external
			// JavaScript -> Select all <a href='...' target='_blank'>
			jsContext.evaluateScript("var links=document.querySelectorAll('a');for(var i=0;i<links.length;i++){if(links[i].target==='_blank'){links[i].addEventListener('click',function () {app.openExternal(this.href);})}}")
		} else {
			// _blank to internal
			// JavaScript -> Select all <a href='...' target='_blank'>
			jsContext.evaluateScript("var links=document.querySelectorAll('a');for(var i=0;i<links.length;i++){if(links[i].target==='_blank'){links[i].addEventListener('click',function () {app.openInternal(this.href);})}}")
		}
		
		// @wdg Add Notification Support
		// Issue: #2, #35, #38 (webkitNotification)
		jsContext.evaluateScript("function Notification(myTitle, options){if(typeof options === 'object'){var body,icon,tag;if (typeof options['body'] !== 'undefined'){body=options['body']}if (typeof options['icon'] !== 'undefined'){Notification.note(myTitle, body, options['icon'])}else{Notification.note(myTitle, body)}}else{if(typeof options === 'string'){Notification.note(myTitle, options)}else{Notification.note(myTitle)}}}Notification.length=1;Notification.permission='granted';Notification.requestPermission=function(callback){if(typeof callback === 'function'){callback('granted');}else{return 'granted'}};window.Notification=Notification;window.webkitNotification=Notification;")
		let myNofification: @convention(block)(NSString?, NSString?, NSString?) -> Void = {(title: NSString?, message: NSString?, icon: NSString?) in
			self.makeNotification(title!, message: message!, icon: icon!)
		}
		jsContext.objectForKeyedSubscript("Notification").setObject(unsafeBitCast(myNofification, to: AnyObject.self), forKeyedSubscript: "note" as (NSCopying & NSObjectProtocol)!)
		
		// Add console.log ;)
		// Add Console.log (and console.error, and console.warn)
		if (WebShellSettings["consoleSupport"] as! Bool) {
			jsContext.evaluateScript("var console = {log: function () {var message = '';for (var i = 0; i < arguments.length; i++) {message += arguments[i] + ' '};console.print(message)},warn: function () {var message = '';for (var i = 0; i < arguments.length; i++) {message += arguments[i] + ' '};console.print(message)},error: function () {var message = '';for (var i = 0; i < arguments.length; i++){message += arguments[i] + ' '};console.print(message)}};")
			let logFunction: @convention(block)(NSString!) -> Void = {(message: NSString!) in
				print("JS: \(message)")
			}
			jsContext.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self), forKeyedSubscript: "print" as (NSCopying & NSObjectProtocol)!)
		}
		
		// @wdg Add support for target=_blank
		// Issue: #5
		// Fake window.app Library.
		jsContext.evaluateScript("var app={};") ;
		
		// _blank external
		let openInBrowser: @convention(block)(NSString!) -> Void = {(url: NSString!) in
			NSWorkspace.shared().open(URL(string: (url as String))!)
		}
		
		// _blank internal
		let openNow: @convention(block)(NSString!) -> Void = {(url: NSString!) in
			self.loadUrl((url as String))
		}
		// _blank external
		jsContext.objectForKeyedSubscript("app").setObject(unsafeBitCast(openInBrowser, to: AnyObject.self), forKeyedSubscript: "openExternal" as (NSCopying & NSObjectProtocol)!)
		
		// _blank internal
		jsContext.objectForKeyedSubscript("app").setObject(unsafeBitCast(openNow, to: AnyObject.self), forKeyedSubscript: "openInternal" as (NSCopying & NSObjectProtocol)!)
		
		// @wdg Add Print Support
		// Issue: #39
		// window.print()
		let printMe: @convention(block)(NSString?) -> Void = {(url: NSString?) in self.printThisPage(self)}
		jsContext.objectForKeyedSubscript("window").setObject(unsafeBitCast(printMe, to: AnyObject.self), forKeyedSubscript: "print" as (NSCopying & NSObjectProtocol)!)
		
		// navigator.getBattery()
		jsContext.objectForKeyedSubscript("navigator").setObject(BatteryManager.self, forKeyedSubscript: "battery" as (NSCopying & NSObjectProtocol)!)
		
		jsContext.evaluateScript("window.navigator.getBattery = window.navigator.battery.getBattery;")
		
		// navigator.vibrate
		let vibrateNow: @convention(block)(NSString!) -> Void = {(data: NSString!) in
			self.flashScreen(data)
		}
		jsContext.objectForKeyedSubscript("navigator").setObject(unsafeBitCast(vibrateNow, to: AnyObject.self), forKeyedSubscript: "vibrate" as (NSCopying & NSObjectProtocol)!)
        
		// @wdg Add localstorage Support
		// Issue: #25
		let saveToLocal: @convention(block)(NSString?, NSString?) -> Void = {(key: NSString?, value: NSString?) in
			let host: String = (self.mainWebview.mainFrame.dataSource?.request.url?.host)!
			let newKey = "WSLS:\(host):\(key)"
			
			UserDefaults.standard.setValue(value, forKey: newKey)
		}
		
		let getFromLocal: @convention(block)(NSString!) -> String = {(key: NSString!) in
			let host: String = (self.mainWebview.mainFrame.dataSource?.request.url?.host)!
			let newKey = "WSLS:\(host):\(key)"
			let val = UserDefaults.standard.value(forKey: newKey as String)
			
			if let myVal = val as? String {
				return String(myVal)
			}
			else {
				return "null"
			}
		}
		
		jsContext.objectForKeyedSubscript("localStorage").setObject(unsafeBitCast(saveToLocal, to: AnyObject.self), forKeyedSubscript: "setItem" as (NSCopying & NSObjectProtocol)!)
		jsContext.objectForKeyedSubscript("localStorage").setObject(unsafeBitCast(getFromLocal, to: AnyObject.self), forKeyedSubscript: "getItem" as (NSCopying & NSObjectProtocol)!)
		
		// @wdg Support for window.open (popup)
		// Issue: #21
        // openNewWindow(url: "THEURL", height: "0", width: "0")
		// window.open(URL, name, specs, replace)
        let windowOpen: @convention(block)(NSString?, NSString?, NSString?, NSString?) -> Void = {(url: NSString?, target: NSString?, specs: NSString?, replace: NSString?) in
            self.parseWindowOpen(url! as String, options: specs as! String)
        }
		jsContext.objectForKeyedSubscript("window").setObject(unsafeBitCast(windowOpen, to: AnyObject.self), forKeyedSubscript: "open" as (NSCopying & NSObjectProtocol)!)
        
		// Get window.webshell
		let nsObject: Any? = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
		jsContext.evaluateScript("window.webshell={version:'\(nsObject as! String)'};webshell=window.webshell;")

        _WSInjectCSS(jsContext)
        _WSInjectJS(jsContext)
	}
	
	// @wdg Add Localstorage Support
	// Issue: #25
	func resetLocalStorage(_ Sender: AnyObject?) -> Void {
		UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
	}
	
	// @wdg Support for window.open (popup)
	// Issue: #25
	func parseWindowOpen(_ url: String, options: String) -> Void {
		// We ignore x and y. (initial position on the screen)
		// Using specifications of W3Schools: http://www.w3schools.com/jsref/met_win_open.asp
		// "Open a new window called "MsgWindow", and write some text into it" is not (yet) supported!
		var width = "0"
		var height = "0"
		let options = Array(options.components(separatedBy: ","))
        
		for i in 0 ..< options.count {
			var tmp = Array(options[i].components(separatedBy: "="))
            
			if (tmp[0] == "width" || tmp[0] == " width") {
				width = tmp[1]
                print("width=\(tmp[1])")
			}
			if (tmp[0] == "height" || tmp[0] == " height") {
				height = tmp[1]
                print("height=\(tmp[1])")
			}
		}
        
		// After parsing call
		openNewWindow(url: url, height: "\(height)", width: "\(width)")
	}
}
