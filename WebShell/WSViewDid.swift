//
//  WebshellViewDid.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Cocoa
import Foundation
import AppKit
import Darwin

// See: #43
extension ViewController {
	override func viewDidAppear() {
		if (firstAppear) {
			initWindow()
		}
	}

	// @wdg Possible fix for Mavericks
	// Issue: #18
	override func awakeFromNib() {
		// if (![self respondsToSelector:@selector(viewWillAppear)]) {

		if (!NSViewController().responds(to: #selector(NSViewController.viewWillAppear))) {
            checkSettings()
            
            let myPopup: NSAlert = NSAlert()
            myPopup.messageText = "Hello!"
            myPopup.informativeText = "You are running mavericks?"
            myPopup.alertStyle = NSAlertStyle.informational
            myPopup.addButton(withTitle: "Yes")
            myPopup.addButton(withTitle: "No")
            
            let res = myPopup.runModal()
            
            
			print("MAVERICKS \(res)")

			// OS X 10.9
			if (firstAppear) {
				initWindow()
			}

			mainWebview.uiDelegate = self
			mainWebview.resourceLoadDelegate = self
			mainWebview.downloadDelegate = self
            mainWebview.editingDelegate = self
            mainWebview.policyDelegate = self
            //WebUIDelegate

			addObservers()
			initSettings()
			goHome()
            WSMediaLoop(self)
            WSinitSwipeGestures()
		}
	}

	override func viewDidLoad() {
        checkSettings()
        //self.view = goodView()
		super.viewDidLoad()

		mainWebview.uiDelegate = self
		mainWebview.resourceLoadDelegate = self
		mainWebview.downloadDelegate = self
        mainWebview.editingDelegate = self
        mainWebview.policyDelegate = self
        
        WebShellSettings["WSMW"] = mainWebview;
        
		checkSettings()
		addObservers()
		initSettings()
		goHome()
        WSMediaLoop(self)
        WSinitSwipeGestures()
	}
}
