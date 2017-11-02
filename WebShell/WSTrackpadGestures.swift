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

		let WSswipeGesture: NSGestureRecognizer = NSGestureRecognizer(target: self, action: #selector(ViewController.swipe(with:)))
		WSswipeGesture.isEnabled = true
		WSswipeGesture.target = self
		WSswipeGesture.action = #selector(ViewController.swipe(with:))
		self.view.addGestureRecognizer(WSswipeGesture)
		mainWebview.addGestureRecognizer(WSswipeGesture)

		let WSpanGesture: NSPanGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(_:)))
		WSpanGesture.isEnabled = true
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
	@objc func handlePan(_ event: NSEvent) {
		print("Pan = \(event)")
	}

    /**
     SwipeWithEvent
     
     - Parameter event: NSEvent
     
     @wdg #44: Support Trackpad gestures
     */
	override func swipe(with event: NSEvent) {
		var action = 0;
		if (event.type == .gesture) {
			let touches: Set<NSTouch> = event.touches(matching: NSTouch.Phase.any, in: self.view)
			if (touches.count == 2) {
				for touch in touches {
					if ((touch as AnyObject).phase == NSTouch.Phase.began) {
//                        Dprint("Began X:\(touch.normalizedPosition.x) Y:\(touch.normalizedPosition.y)")
                        WSgestureLog = [(touch as AnyObject).normalizedPosition.x, (touch as AnyObject).normalizedPosition.y]
					}
					if ((touch as AnyObject).phase == NSTouch.Phase.ended) {
//                        Dprint("Ended  X:\(touch.normalizedPosition.x) Y:\(touch.normalizedPosition.y)")
//                        Dprint("Versus X:\(WSgestureLog[0]) Y:\(WSgestureLog[1])")
                        if ((touch as AnyObject).normalizedPosition.x < WSgestureLog[0]) {
                            action = -1
                        } else {
                            action = 1
                        }
					}
				}
			}
		}

//        if (action != 0) {
//            Dprint(action > 0 ? "Left?" : action == 0 ? "" : "Right?")
//        }
        
        if !(WebShellSettings["navigateViaTrackpad"] as! Bool) {
            action = 0 // ignore, disabled
        }
        
        
		if (action == 0) {
			// ignore
		} else if (action > 0) { // > Left
			if (mainWebview.canGoBack) {
				if (mainWebview.isLoading) {
					mainWebview.stopLoading(nil)
				}
				mainWebview.goBack(nil)
			} else {
//				NSBeep()
			}
		} else if (action < 0) { // < Right
			if (mainWebview.canGoForward) {
				if (mainWebview.isLoading) {
					mainWebview.stopLoading(nil)
				}
				mainWebview.goForward(nil)
			} else {
//				NSBeep()
			}
		}
	}

	override func touchesMoved(with event: NSEvent) {
		if (event.type == .gesture) {
			swipe(with: event)
		}
	}
}

/**
 This extension will support the swipe gestures
 
 - Just for overriding
 
 @wdg #44: Support Trackpad gestures
 */
class x: WebView, NSGestureRecognizerDelegate {
	func WSswipedDown(_ sender: AnyObject) {}
	
    override func mouseDown(with event: NSEvent) {}
    
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
