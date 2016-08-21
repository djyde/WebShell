//
//  WebShellPageActions.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import AppKit

extension ViewController {
	func addObservers() {
		// add menu action observers
		let observers = ["goHome", "reload", "copyUrl", "clearNotificationCount", "printThisPage"]

		for observer in observers {
			NotificationCenter.default.addObserver(self, selector: NSSelectorFromString(observer), name: NSNotification.Name(rawValue: observer), object: nil)
		}
	}

	func goHome() {
		loadUrl((WebShellSettings["url"] as? String)!)
	}

	func reload() {
		let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.url?.absoluteString)!
		loadUrl(currentUrl)
	}

	func copyUrl() {
		let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.url?.absoluteString)!
		let clipboard: NSPasteboard = NSPasteboard.general()
		clipboard.clearContents()

		clipboard.setString(currentUrl, forType: NSStringPboardType)
	}

	func initSettings() {
		// controll the progress bar
		if (!(WebShellSettings["showLoadingBar"] as? Bool)!) {
			progressBar.isHidden = true // @wdg: Better progress indicator | Issue: #37
		}

		// @wdg Add Custom useragent support
		// Issue: #52
		if ((WebShellSettings["useragent"] as! String).lowercased() == "default") {
			var UA: String = Bundle.main.infoDictionary!["CFBundleName"] as! String
			UA = UA + "/"
			UA = UA + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
			UA = UA + " based on Safari/AppleWebKit (KHTML, like Gecko)"

			UserDefaults.standard.register(defaults: ["UserAgent": UA]) // For iOS
			mainWebview.customUserAgent = UA // For Mac OS X
		} else {
			let UA: String = WebShellSettings["useragent"] as! String
			UserDefaults.standard.register(defaults: ["UserAgent": UA]) // For iOS
			mainWebview.customUserAgent = UA // For Mac OS X
		}

		// set launching text
		launchingLabel.stringValue = (WebShellSettings["launchingText"] as? String)!
	}

	func initWindow() {
		firstAppear = false

		// set window size
		var frame: NSRect = mainWindow.frame

		let WIDTH: CGFloat = CGFloat(WebShellSettings["initialWindowWidth"] as! Int),
			HEIGHT: CGFloat = CGFloat(WebShellSettings["initialWindowHeight"] as! Int)

		frame.size.width = WIDTH
		frame.size.height = HEIGHT

		// @wdg Fixed screen position (now it centers)
		// Issue: #19
		// Note: do not use HEIGHT, WIDTH for some strange reason the window will be positioned 25px from bottom!
		let ScreenHeight: CGFloat = (NSScreen.main()?.frame.size.width)!,
			WindowHeight: CGFloat = CGFloat(WebShellSettings["initialWindowWidth"] as! Int), // do not use HEIGHT!
		ScreenWidth: CGFloat = (NSScreen.main()?.frame.size.height)!,
			WindowWidth: CGFloat = CGFloat(WebShellSettings["initialWindowHeight"] as! Int) // do not use WIDTH!
		frame.origin.x = (ScreenHeight / 2 - WindowHeight / 2)
		frame.origin.y = (ScreenWidth / 2 - WindowWidth / 2)

		// @froge-xyz Fixed initial window size
		// Issue: #1, #45
		mainWindow.window?.setFrame(frame, display: true)
		// defims Fixed the initial window size.
		mainWindow.frame = frame

		// set window title
		mainWindow.window?.title = WebShellSettings["title"] as! String

		// Force some preferences before loading...
		mainWebview.preferences.isJavaScriptEnabled = true
		mainWebview.preferences.javaScriptCanOpenWindowsAutomatically = true
		mainWebview.preferences.arePlugInsEnabled = true
	}

	func loadUrl(_ url: String) {
		if ((WebShellSettings["showLoadingBar"] as? Bool)!) {
			progressBar.isHidden = false
			progressBar.startAnimation(self)
			progressBar.maxValue = 100;
			progressBar.minValue = 1;
			progressBar.increment(by: 24)
		}
		let URL = Foundation.URL(string: url)
		mainWebview.mainFrame.load(URLRequest(url: URL!))
	}

	// @wdg Add Print Support
	// Issue: #39
	func printThisPage(_ Sender: AnyObject?) -> Void {
		let url = mainWebview.mainFrame.dataSource?.request?.url?.absoluteString

		let operation: NSPrintOperation = NSPrintOperation.init(view: mainWebview)
		operation.jobTitle = "Printing \(url!)"

		// If want to print landscape
		operation.printInfo.orientation = NSPaperOrientation.landscape
		operation.printInfo.scalingFactor = 0.7

		if operation.run() {
			print("Printed?")
		}
	}
}
