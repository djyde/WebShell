//
//  WSBaseSettings.swift
//  WebShell
//
//  Created by Fahim Farook on 9/12/17.
//  Copyright © 2017 RandyLu. All rights reserved.
//

import Foundation

class WSBaseSettings {
	// URL to browse to
	var url = "http://djyde.github.io/WebShell/WebShell/"
	
	// The last URL the app was on
	var lastURL: String {
		set {
			let def = UserDefaults.standard
			def.set(newValue, forKey: title + "-LastURL")
			def.synchronize()
		}
		get {
			let def = UserDefaults.standard
			if let url = def.value(forKey: title + "-LastURL") as? String {
				return url
			}
			return ""
		}
	}
	
	// set the app title
	var	title = Bundle.main.infoDictionary!["CFBundleName"] as! String
		
	// if you want to use the default one then leave it default || default = title/version based on Safari/AppleWebKit (KHTML, like Gecko)
	// otherwise change it to a useragent you want. (Default: "default")
	var useragent = "default"
	
	// Do you want to use the document title? (Default: true)
	var useDocumentTitle = true
	
	// Multilanguage loading text!
	var launchingText = NSLocalizedString("Launching...", comment: "Launching...")
	
	// Note that the window min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
	var initialWindowHeight = 640
	var initialWindowWidth = 1000
	
	// Open target=_blank in a new screen? (Default: false)
	var openInNewScreen = false
	
	// Do you want a loading bar? (Default: true)
	var showLoadingBar = true
	
	// Add console.log support? (Default: false)
	var consoleSupport = false
	
	// Does the app needs Location support (Default: false)
	// note: if true, then WebShell always uses location, whenever it is used or not
	var needLocation = false
	
	// run the app in debug mode? (Default: false)
	// will be overridden by Xcode (runs with -NSDocumentRevisionsDebugMode YES)
	var debugmode = false
	
	// Please paste here the JavaScript you want to load on a website (Default: "")
	var jsInject = ""
	
	// Please paste here the CSS you want to load on a website (Default: "")
	var cssInject = ""
	
	// Enable (inject) import (JS/CSS) Folder. (Default: true)
	var enableInjectImport = true
	
	// Menubar app (right side next to clock) (Default: false)
	var menuBarApp = false
	
	// Navigate trough trackpad (back/forward) (Default: true)
	var navigateViaTrackpad = true
	
	// Use a password manager (Default: true).
	var passwordManager = true
	
	// Media keys settings - Enable "Back" & "Forward"
	var mkBackAndForward = true
	
	// Media Player support (experimental)
	var mkMediaPlayers = false
	
	// Contextmenu settings - // Enable "Back" & "Forward" (Default: true)
	var cmBackAndForward = true

	// Enable "Download" (Default: true)
	var cmDownload = true

	// Enable "Reload" (Default: true)
	var cmReload = true

	// Enable "Open in a new window" (Default: true)
	var cmNewWindow = true
	
    // open with last url? (Default: false)
	var openLastUrl = false
	
	// The URL to start with - the last page you were on or the base URL
	func startURL() -> String {
		if lastURL.isEmpty {
			return url
		}
        return openLastUrl ? lastURL : url
	}
}
