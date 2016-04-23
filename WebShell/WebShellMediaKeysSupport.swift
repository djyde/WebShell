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
 
 This class will support the WebShell media keys.
 */
class WebShellMediaKeysSupport: NSApplication {
    
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
			case NX_KEYTYPE_PLAY:
                print("Play!")
				// F8 pressed
				break
			case NX_KEYTYPE_FAST:
                print("Fast!")
				// F9 pressed
				break
			case NX_KEYTYPE_REWIND:
                print("Rewind!")
				// F7 pressed
				break
			case NX_KEYTYPE_PREVIOUS: // Not called?
                print("Previous!")
				// F7
				break
			case NX_KEYTYPE_NEXT: // Not called?
                print("Next!")
				// F9 pressed
				break
			default:
				break
			}
		}
	}
}