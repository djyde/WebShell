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

/**
 @wdg: This extension will support the swipe gestures
 Issue: #44
 */
extension ViewController: NSGestureRecognizerDelegate {
	/**
	 WSinitSwipeGestures

	 Initialize Swipe Gestures!!!
     
     @wdg #44: Support Trackpad gestures
	 */
	func WSinitSwipeGestures() {
		mainWebview.acceptsTouchEvents = true
		self.view.acceptsTouchEvents = true

		let WSswipeGesture: NSGestureRecognizer = NSGestureRecognizer(target: self, action: #selector(ViewController.swipeWithEvent(_:)))
		WSswipeGesture.enabled = true
		WSswipeGesture.target = self
		WSswipeGesture.action = #selector(ViewController.swipeWithEvent(_:))
		self.view.addGestureRecognizer(WSswipeGesture)
		mainWebview.addGestureRecognizer(WSswipeGesture)

		let WSpanGesture: NSPanGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(_:)))
		WSpanGesture.enabled = true
		WSpanGesture.target = self
		WSpanGesture.action = #selector(ViewController.handlePan(_:))
		self.view.addGestureRecognizer(WSpanGesture)
		mainWebview.addGestureRecognizer(WSpanGesture)
	}

	override var acceptsFirstResponder: Bool {
		return true
	}

    /**
     handlePan (not called)
     
     - Parameter event: NSEvent
     
     @wdg #44: Support Trackpad gestures
     */
	func handlePan(event: NSEvent) {
		print("Pan = \(event)")
	}

    /**
     SwipeWithEvent
     
     - Parameter event: NSEvent
     
     @wdg #44: Support Trackpad gestures
     */
	override func swipeWithEvent(event: NSEvent) {
		var action = 0;
		if (event.type == .EventTypeGesture) {
			let touches: NSSet = event.touchesMatchingPhase(NSTouchPhase.Any, inView: self.view)
			if (touches.count == 2) {
				for touch in touches {
					if (touch.phase == NSTouchPhase.Began) {
//						print("Began X:\(touch.normalizedPosition.x) Y:\(touch.normalizedPosition.y)")
                        WSgestureLog = [touch.normalizedPosition.x, touch.normalizedPosition.y]
					}
					if (touch.phase == NSTouchPhase.Ended) {
//						print("Ended  X:\(touch.normalizedPosition.x) Y:\(touch.normalizedPosition.y)")
//                      print("Versus X:\(WSgestureLog[0]) Y:\(WSgestureLog[1])")
                        if (touch.normalizedPosition.x < WSgestureLog[0]) {
                            action = -1
                        } else {
                            action = 1
                        }
					}
				}
			}
		}

        if !(WebShellSettings["navigateViaTrackpad"] as! Bool) {
            action = 0 // ignore, disabled
        }
        
		if (action == 0) {
			// ignore
		} else if (action > 0) { // > Left
			if (mainWebview.canGoBack) {
				if (mainWebview.loading) {
					mainWebview.stopLoading(nil)
				}
				mainWebview.goBack(nil)
			} else {
//				NSBeep()
			}
		} else if (action < 0) { // < Right
			if (mainWebview.canGoForward) {
				if (mainWebview.loading) {
					mainWebview.stopLoading(nil)
				}
				mainWebview.goForward(nil)
			} else {
//				NSBeep()
			}
		}
	}

	override func touchesMovedWithEvent(event: NSEvent) {
		if (event.type == .EventTypeGesture) {
			swipeWithEvent(event)
		}
	}
}

/**
 This extension will support the swipe gestures
 
 - Just for overriding
 
 @wdg #44: Support Trackpad gestures
 */
class x: WebView, NSGestureRecognizerDelegate {
	func WSswipedDown(sender: AnyObject) {}
	
    override func mouseDown(event: NSEvent) {}
    
	override var acceptsFirstResponder: Bool {
		return true
	}

	var setAcceptsTouchEvents: Bool {
		return true
	}

	var userInteractionEnabled: Bool {
		return true
	}
}