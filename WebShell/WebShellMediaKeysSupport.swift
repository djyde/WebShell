//
//  WebShellMediaKeysSupport.swift
//  WebShell
//
//  Created by Wesley de Groot on 20-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//
// Issue: it doesn't bind to the system

import AppKit
import Cocoa

/**
 Class WebShellMediaKeysSupport

 This class will support the WebShell media keys. \
 \
 !important note, this class can not communicate with the ViewController.\
 The communication goes via NSUserDefaults.
 */
class WebShellMediaKeysSupport: NSApplication {
	let MediaKeysSettings = WebShell().Settings["MediaKeys"] as! [String: Bool]

	override func sendEvent(theEvent: NSEvent) {
		if theEvent.type == .SystemDefined && theEvent.subtype.rawValue == 8 {
			let keyCode = ((theEvent.data1 & 0xFFFF0000) >> 16)
			let keyFlags = (theEvent.data1 & 0x0000FFFF)
			// Get the key state. 0xA is KeyDown, OxB is KeyUp
			let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
			let keyRepeat = (keyFlags & 0x1)
			mediaKeyEvent(Int32(keyCode), state: keyState, keyRepeat: Bool(keyRepeat))
		}

		super.sendEvent(theEvent)
	}

	func mediaKeyEvent(key: Int32, state: Bool, keyRepeat: Bool) {
		// Only send events on KeyDown. Without this check, these events will happen twice
		if (state) {
			switch (key) {
			case NX_KEYTYPE_PLAY: // F8 / Play
				if (MediaKeysSettings["BackAndForward"] == true) {
					self.goReloadPage()
				} else {
					self.playPausePressed()
				}
				break
			case NX_KEYTYPE_FAST, NX_KEYTYPE_NEXT: // F9 / Forward
				if (MediaKeysSettings["BackAndForward"] == true) {
					self.goForwardIfPossible()
				} else {
					self.nextItem()
				}
				break
			case NX_KEYTYPE_REWIND, NX_KEYTYPE_PREVIOUS: // F7 / Backward
				if (MediaKeysSettings["BackAndForward"] == true) {
					self.goBackIfPossible()
				} else {
					self.previousItem()
				}
				break
			default:
				break
			}
		}
	}

	/**
	 goBackIfPossible

	 Since we can't communicate with the ViewController.\
	 We'll set a NSUserDefaults, and the `WSMediaLoop` does the Job for us.
	 */
	func goBackIfPossible() {
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WSGoBack")
		NSUserDefaults.standardUserDefaults().synchronize()
	}

	/**
	 goForwardIfPossible

	 Since we can't communicate with the ViewController.\
	 We'll set a NSUserDefaults, and the `WSMediaLoop` does the Job for us.
	 */
	func goForwardIfPossible() {
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WSGoForward")
		NSUserDefaults.standardUserDefaults().synchronize()
	}

	/**
	 goReloadPage

	 Since we can't communicate with the ViewController.\
	 We'll set a NSUserDefaults, and the `WSMediaLoop` does the Job for us.
	 */
	func goReloadPage() {
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WSGoReload")
		NSUserDefaults.standardUserDefaults().synchronize()
	}

	func nextItem() -> Bool {
		// ...
		return false
	}

	func previousItem() -> Bool {
		// ...
		return false
	}

	func playPausePressed() -> Bool {
		// ...
		return false
	}
}

extension ViewController {
	/**
	 Communication for the WebShellMediaKeysSupport class

	 - Parameter Sender: AnyObject (used for #selector use self)
	 */
	func WSMediaLoop(Sender: AnyObject) -> Void {
		self.performSelector(#selector(ViewController.WSMediaLoop(_:)), withObject: nil, afterDelay: 0.5)

		if (NSUserDefaults.standardUserDefaults().boolForKey("WSGoBack")) {
			NSUserDefaults.standardUserDefaults().setBool(false, forKey: "WSGoBack")
			NSUserDefaults.standardUserDefaults().synchronize()
			self._goBack(self)
		}

		if (NSUserDefaults.standardUserDefaults().boolForKey("WSGoForward")) {
			NSUserDefaults.standardUserDefaults().setBool(false, forKey: "WSGoForward")
			NSUserDefaults.standardUserDefaults().synchronize()
			self._goForward(self)
		}

		if (NSUserDefaults.standardUserDefaults().boolForKey("WSGoReload")) {
			NSUserDefaults.standardUserDefaults().setBool(false, forKey: "WSGoReload")
			NSUserDefaults.standardUserDefaults().synchronize()
			self._reloadPage(self)
		}

		// @wdg Merge Statut with WebShell.
		// Issue: #56
		if (WebShell().Settings["MenuBarApp"] as! Bool) {
			if ((NSApplication.sharedApplication().keyWindow) != nil) {
				if (self.MustCloseWindow) {
					NSApplication.sharedApplication().keyWindow?.close()
					self.MustCloseWindow = false
				}
			}
		}
	}
}