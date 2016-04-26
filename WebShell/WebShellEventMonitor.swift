//
//  WebShellEventMonitor.swift
//  WebShell
//
//  Created by Wesley de Groot on 26-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Cocoa

// @wdg Merge Statut with WebShell.
// Issue: #56
class EventMonitor {
    private var monitor: AnyObject?
    private let mask: NSEventMask
    private let handler: NSEvent? -> ()
    
    internal init(mask: NSEventMask, handler: NSEvent? -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    internal func start() {
        monitor = NSEvent.addGlobalMonitorForEventsMatchingMask(mask, handler: handler)
    }
    
    internal func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
