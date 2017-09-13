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
    fileprivate var monitor: Any?
    fileprivate let mask: NSEvent.EventTypeMask
    fileprivate let handler: (NSEvent?) -> ()
    
    /**
     Init monitoring for events
     
     - Parameter mask: under which mask?
     - Parameter handler: with which handler?
     */
    internal init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    /**
     Starts monitoring for events
     */
    internal func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    /**
     Removes event monitor
     */
    internal func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
