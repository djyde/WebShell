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
import SpriteKit
// TODO: Function 'swipeWithEvent' is not being called.
//NSGestureRecognizerDelegate, NSGestureRecognizerState, NSGestureRecognizer
class WSTrackpadGestures : NSResponder {
    override func mouseDown(event: NSEvent) {
        //        let point: NSPoint = event.locationInView
        print("X: \'point.x'")
        print("Y: \'point.y'")
    }
    
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
    
    var setAcceptsTouchEvents: Bool {
        return true
    }
    
    var userInteractionEnabled: Bool {
        return true
    }
    
    override func touchesBeganWithEvent(event: NSEvent) {
        print("Touch \(event)")
    }
    
    override func touchesMovedWithEvent(event: NSEvent) {
        print("Moved \(event)")
    }
    
    override func touchesEndedWithEvent(event: NSEvent) {
        print("Ended \(event)")
    }
    
    override func touchesCancelledWithEvent(event: NSEvent) {
        print("Cancelled \(event)")
    }
}
/**
 This extension will support the swipe gestures
 */
extension ViewController : NSGestureRecognizerDelegate {
	/**
	 SwipeWithEvent

	 - Parameter event: NSEvent
	 */
    func WSinitSwipeGestures() {
        
        let swipeDown:NSGestureRecognizer = NSGestureRecognizer(target: self, action: #selector(ViewController.WSswipedDown(_:)))
        swipeDown.enabled = true
        swipeDown.target = self
        swipeDown.action = #selector(ViewController.WSswipedDown(_:))
        self.view.addGestureRecognizer(swipeDown)
        mainWebview.acceptsTouchEvents = true
        mainWebview.addGestureRecognizer(swipeDown)

    }
    
    func WSswipedDown(sender: AnyObject) {
        print("DOWN!")
    }
    
    override func mouseDown(event: NSEvent) {
//        let point: NSPoint = event.locationInView
        print("X: \'point.x'")
        print("Y: \'point.y'")
    }

    override func swipeWithEvent(event: NSEvent) {
        print(event.deltaY)
        let deltaX = event.deltaX
        
        if deltaX > 0 { // Left
            if mainWebview.canGoBack {
                if mainWebview.loading {
                    mainWebview.stopLoading(nil)
                }
                mainWebview.goBack(nil)
            } else {
                NSBeep()
            }
        } else if deltaX < 0 { // Right
            if mainWebview.canGoForward {
                if mainWebview.loading {
                    mainWebview.stopLoading(nil)
                }
                mainWebview.goForward(nil)
            } else {
                NSBeep()
            }
        }
    }
    
    func swipeWithEvent2(event: NSEvent) {
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
			direction = "Unknown!";
			break;
		}
		print("Swiped \(direction) Direction")
	}

	override func touchesMovedWithEvent(event: NSEvent) {
//		print("Moved::: \(event)")
//        swipeWithEvent(event)
//        swipeWithEvent2(event)
	}

}

// TODO: Function 'swipeWithEvent' is not being called.

/**
 This extension will support the swipe gestures
 */
class x: WebView, NSGestureRecognizerDelegate {
    func WSswipedDown(sender: AnyObject) {
        self.print("DOWN!")
    }
    
    override func mouseDown(event: NSEvent) {
        //        let point: NSPoint = event.locationInView
        self.print("X: \'point.x'")
        self.print("Y: \'point.y'")
    }
    
	override var acceptsFirstResponder: Bool {
		return true
	}

	var setAcceptsTouchEvents: Bool {
		return true
	}

	var userInteractionEnabled: Bool {
		return true
	}

	override func touchesBeganWithEvent(event: NSEvent) {
		Swift.print("WV: Touch \(event)")
	}

	override func touchesMovedWithEvent(event: NSEvent) {
		Swift.print("WV: Moved \(event)")
	}

	override func touchesEndedWithEvent(event: NSEvent) {
		Swift.print("WV: Ended \(event)")
	}

	override func touchesCancelledWithEvent(event: NSEvent) {
		Swift.print("WV: Cancelled \(event)")
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