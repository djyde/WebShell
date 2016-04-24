//
//  Settings.swift
//  WebShell
//
//  Created by Wesley de Groot on 23-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation

/**
 WebShell Class

 This class is the main class for WebShell.
 */
class WebShell {
	/**
	 The settings Dictionary
	 */
	var Settings: [String: Any] = [
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
		"debugmode": true,

		// Please paste here the JavaScript you want to load on a website
		"JSInject": "",

		// Please paste here the CSS you want to load on a website
		"CSSInject": "",

		"MediaKeys": [
			// Enable "Back" & "Forward"
			"BackAndForward": true,

			// Media Player support (experimental)
			"MediaPlayers": false
		],

		"Contextmenu": [
			// Enable "Back" & "Forward"
			"BackAndForward": true,

			// Enable "Download"
			"Download": true,

			// Enable "Reload"
			"Reload": true,

			// Enable "Open in a new window"
			"newWindow": true
		],

		// Just a placeholder.
		"fake": true
	]
}