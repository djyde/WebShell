//
//  WebShellPageActions.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import AppKit

extension WSViewController {
    /**
     Add Observers for menu items
     */
	func addObservers() {
		// add menu action observers
		let observers = ["goHome", "reload", "copyUrl", "clearNotificationCount", "printThisPage"]

		for observer in observers {
			NotificationCenter.default.addObserver(self, selector: NSSelectorFromString(observer), name: NSNotification.Name(rawValue: observer), object: nil)
		}
	}

    /**
     Go to the home url
     */
	func goHome() {
		loadUrl((WebShellSettings["url"] as? String)!)
	}

    /**
     Reload the current webpage
     */
	func reload() {
        mainWebview.mainFrame.reload()
	}

    /**
     Copy the URL
     */
	func copyUrl() {
		let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.url?.absoluteString)!
		let clipboard: NSPasteboard = NSPasteboard.general
		clipboard.clearContents()

        clipboard.setString(currentUrl, forType: .string)
	}

    /**
     Initialize settings
     */
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

    /**
     Initialize window
     */
	func initWindow() {
		firstAppear = false
		// set window title
		mainWindow.window?.title = WebShellSettings["title"] as! String

		// Force some preferences before loading...
		mainWebview.preferences.isJavaScriptEnabled = true
		mainWebview.preferences.javaScriptCanOpenWindowsAutomatically = true
		mainWebview.preferences.arePlugInsEnabled = true
	}

    /**
     Load a specific URL
     
     - Parameter url: The url to load
     */

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

    /**
     Add Print Support (#39) [@wdg]
     
     - Parameter Sender: The sending object
     */
	func printThisPage(_ Sender: AnyObject?) -> Void {
		let url = mainWebview.mainFrame.dataSource?.request?.url?.absoluteString

		let operation: NSPrintOperation = NSPrintOperation(view: mainWebview)
		operation.jobTitle = "Printing \(url!)"

		// If want to print landscape
		operation.printInfo.orientation = NSPrintInfo.PaperOrientation.landscape
		operation.printInfo.scalingFactor = 0.7

		if operation.run() {
			print("Printed?")
		}
	}
}
