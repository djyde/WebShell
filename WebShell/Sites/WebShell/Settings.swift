//
//  Settings.swift
//  WebShell
//
//  Created by Wesley de Groot on 23-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation

class Settings: WSBaseSettings {
	static let shared = Settings()
	
	override private init() {
		super.init()
		// Override default settings for this particular target
		self.url = "http://djyde.github.io/WebShell/WebShell/"
        
        // set the app title
        self.title = Bundle.main.infoDictionary!["CFBundleName"] as! String
        
        // if you want to use the default one then leave it default || default = title/version based on Safari/AppleWebKit (KHTML, like Gecko)
        // otherwise change it to a useragent you want. (Default: "default")
        self.useragent = "default"
        
        // Do you want to use the document title? (Default: true)
        self.useDocumentTitle = true
        
        // Multilanguage loading text!
        self.launchingText = NSLocalizedString("Launching...", comment: "Launching...")
        
        // Open target=_blank in a new screen? (Default: false)
        self.openInNewScreen = false
        
        // Do you want a loading bar? (Default: true)
        self.showLoadingBar = true
        
        // Add console.log support? (Default: false)
        self.consoleSupport = false
        
        // Does the app needs Location support (Default: false)
        // note: if true, then WebShell always uses location, whenever it is used or not
        self.needLocation = false
        
        // run the app in debug mode? (Default: false)
        // will be overridden by Xcode (runs with -NSDocumentRevisionsDebugMode YES)
        self.debugmode = false
        
        // Please paste here the JavaScript you want to load on a website (Default: "")
        self.jsInject = ""
        
        // Please paste here the CSS you want to load on a website (Default: "")
        self.cssInject = ""
        
        // Enable (inject) import (JS/CSS) Folder. (Default: true)
        self.enableInjectImport = true
        
        // Menubar app (right side next to clock) (Default: false)
        self.menuBarApp = false
        
        // Navigate trough trackpad (back/forward) (Default: true)
        self.navigateViaTrackpad = true
        
        // Use a password manager (Default: true).
        self.passwordManager = true
        
        // Media keys settings - Enable "Back" & "Forward"
        self.mkBackAndForward = true
        
        // Media Player support (experimental)
        self.mkMediaPlayers = false
        
        // Contextmenu settings - // Enable "Back" & "Forward" (Default: true)
        self.cmBackAndForward = true
        
        // Enable "Download" (Default: true)
        self.cmDownload = true
        
        // Enable "Reload" (Default: true)
        self.cmReload = true
        
        // Enable "Open in a new window" (Default: true)
        self.cmNewWindow = true
        
        // open with last url? (Default: false)
        self.openLastUrl = false
	}
}
