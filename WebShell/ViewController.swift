//
//  ViewController.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015 RandyLu. All rights reserved.
//
//  Wesley de Groot (@wdg), Added Notification and console.log Support

import Cocoa
import WebKit
import Foundation
import AppKit
import AudioToolbox
import IOKit.ps
import Darwin
import CoreLocation

// @wdg Clean up code base
// Issue: #43
class ViewController: NSViewController, WebFrameLoadDelegate, WebUIDelegate, WebResourceLoadDelegate, WebPolicyDelegate, CLLocationManagerDelegate {

	@IBOutlet var mainWindow: NSView!
	@IBOutlet weak var mainWebview: WebView!
	@IBOutlet weak var launchingLabel: NSTextField!
	@IBOutlet weak var progressBar: NSProgressIndicator!
	var firstLoadingStarted = false
	var firstAppear = true
	var notificationCount = 0
	let locationManager = CLLocationManager()

	// TODO: configure your app here
	var SETTINGS: [String: Any] = [

		// Url to browse to.
		"url": "https://www.google.com",

		// set the app title
		"title": NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String,

		// if you want to use the default one then leave it default || default = title/version based on Safari/AppleWebKit (KHTML, like Gecko)
		// otherwise change it to a useragent you want.
		"useragent": "default",

		// Do you want to use the document title? (Default: true)
		"useDocumentTitle": true,

		// Multilanguage loading text!
		"launchingText": NSLocalizedString("Launching...", comment: "Launching..."),

		// Note that the window min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
		"initialWindowHeight": 640,
		"initialWindowWidth": 1000,

		// Open target=_blank in a new screen? (Default: false)
		"openInNewScreen": false,

		// Do you want a loading bar? (Default: true)
		"showLoadingBar": true,

		// Add console.log support? (Default: false)
		"consoleSupport": false,

		// Does the app needs Location support (Default: false)
		// note: if true, then WebShell always uses location, whenever it is used or not
		"needLocation": false,

		// run the app in debug mode? (Default: false)
		// will be overridden by xCode (runs with -NSDocumentRevisionsDebugMode YES)
		"debugmode": false,
		
		// Please paste here the JavaScript you want to load on a website
		"JSInject": "",
		
		// Please paste here the CSS you want to load on a website
        "CSSInject": ""
	]
}
