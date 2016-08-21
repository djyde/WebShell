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

    // Swift 3 hates this.
//	override func send(event: NSEvent) {
//		if event.type == .systemDefined && theEvent.subtype.rawValue == 8 {
//			let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
//			let keyFlags = (event.data1 & 0x0000FFFF)
//			// Get the key state. 0xA is KeyDown, OxB is KeyUp
//			let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
//			let keyRepeat = (keyFlags & 0x1)
//			mediaKeyEvent(Int32(keyCode), state: keyState, keyRepeat: Bool(keyRepeat))
//		}
//
//		super.sendEvent(event)
//	}
//TODO: FIX THIS.
    
	func mediaKeyEvent(_ key: Int32, state: Bool, keyRepeat: Bool) {
		// Only send events on KeyDown. Without this check, these events will happen twice
		if (state) {
			switch (key) {
			case NX_KEYTYPE_PLAY: // F8 / Play
				if (MediaKeysSettings["BackAndForward"] == true) {
					self.goReloadPage()
				} else {
					let _ = self.playPausePressed()
				}
				break
			case NX_KEYTYPE_FAST, NX_KEYTYPE_NEXT: // F9 / Forward
				if (MediaKeysSettings["BackAndForward"] == true) {
					self.goForwardIfPossible()
				} else {
					let _ = self.nextItem()
				}
				break
			case NX_KEYTYPE_REWIND, NX_KEYTYPE_PREVIOUS: // F7 / Backward
				if (MediaKeysSettings["BackAndForward"] == true) {
					self.goBackIfPossible()
				} else {
					let _ = self.previousItem()
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
		UserDefaults.standard.set(true, forKey: "WSGoBack")
		UserDefaults.standard.synchronize()
	}

	/**
	 goForwardIfPossible

	 Since we can't communicate with the ViewController.\
	 We'll set a NSUserDefaults, and the `WSMediaLoop` does the Job for us.
	 */
	func goForwardIfPossible() {
		UserDefaults.standard.set(true, forKey: "WSGoForward")
		UserDefaults.standard.synchronize()
	}

	/**
	 goReloadPage

	 Since we can't communicate with the ViewController.\
	 We'll set a NSUserDefaults, and the `WSMediaLoop` does the Job for us.
	 */
	func goReloadPage() {
		UserDefaults.standard.set(true, forKey: "WSGoReload")
		UserDefaults.standard.synchronize()
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
	func WSMediaLoop(_ Sender: AnyObject) -> Void {
		self.perform(#selector(ViewController.WSMediaLoop(_:)), with: nil, afterDelay: 0.5)

		if (UserDefaults.standard.bool(forKey: "WSGoBack")) {
			UserDefaults.standard.set(false, forKey: "WSGoBack")
			UserDefaults.standard.synchronize()
			self._goBack(self)
		}

		if (UserDefaults.standard.bool(forKey: "WSGoForward")) {
			UserDefaults.standard.set(false, forKey: "WSGoForward")
			UserDefaults.standard.synchronize()
			self._goForward(self)
		}

		if (UserDefaults.standard.bool(forKey: "WSGoReload")) {
			UserDefaults.standard.set(false, forKey: "WSGoReload")
			UserDefaults.standard.synchronize()
			self._reloadPage(self)
		}

		// @wdg Merge Statut with WebShell.
		// Issue: #56
		if (WebShellSettings["MenuBarApp"] as! Bool) {
			if ((NSApplication.shared().keyWindow) != nil) {
				if (self.MustCloseWindow) {
					NSApplication.shared().keyWindow?.close()
					self.MustCloseWindow = false
				}
			}
		}
	}
}
