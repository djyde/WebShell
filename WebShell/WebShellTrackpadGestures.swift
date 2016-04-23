//
//  WebShellTrackpadGestures.swift
//  WebShell
//
//  Created by Wesley de Groot on 20-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import AppKit
import WebKit

// TODO: Function 'swipeWithEvent' is not being called.

/**
 This extension will support the swipe gestures
*/
extension ViewController {
    /**
     SwipeWithEvent
     
     - Parameter event: NSEvent
    */
	override func swipeWithEvent(event: NSEvent) {
		let x: CGFloat = event.deltaX
		let y: CGFloat = event.deltaY
		var swipeColorValue = ""
		var direction = ""

		if (x != 0) {
			swipeColorValue = (x > 0) ? "SwipeLeft" : "SwipeRight";
		}
		if (y != 0) {
			swipeColorValue = (y > 0) ? "SwipeUp" : "SwipeDown";
		}

		switch (swipeColorValue) {
		case "SwipeLeft":
			direction = "left";
			break;
		case "SwipeRight":
			direction = "right";
			break;
		case "SwipeUp":
			direction = "up";
			break;
		case "SwipeDown":
			direction = "down";
			break
		default:
			direction = "down";
			break;
		}
		print("Swiped \(direction)")
	}

	override var acceptsFirstResponder: Bool {
		return true
	}

	override func touchesBeganWithEvent(event: NSEvent) {
		print("TUCH?!")
	}

	override func touchesMovedWithEvent(event: NSEvent) {
        print("SomeThingCool")
	}
}

// TODO: Function 'swipeWithEvent' is not being called.

/**
 This extension will support the swipe gestures
 */
class x: WebView {
    var userInteractionEnabled: Bool {
        return true
    }

    override var acceptsFirstResponder: Bool {
		return true
	}

	override func swipeWithEvent(event: NSEvent) {
		let deltaX = event.deltaX
		if deltaX > 0 { // Left
			if canGoBack {
				if loading {
					stopLoading(nil)
				}
				goBack(nil)
			} else {
				NSBeep()
			}
		} else if deltaX < 0 { // Right
			if canGoForward {
				if loading {
					stopLoading(nil)
				}
				goForward(nil)
			} else {
				NSBeep()
			}
		}
	}
}