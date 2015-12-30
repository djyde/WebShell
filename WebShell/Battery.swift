//
//  Battery.swift
//  WebShell
//
//  Created by lizhuoli on 15/12/31.
//  Copyright © 2015年 RandyLu. All rights reserved.
//

import Foundation
import WebKit

@objc protocol BatteryManagerJSExports : JSExport {
    var charging: Bool { get set }
    var chargingTime: NSNumber { get set }
    var dischargingTime:NSNumber { get set }
    var level:NSNumber { get set }
    
    static func getBattery() -> BatteryManager
}

@objc class BatteryManager : NSObject, BatteryManagerJSExports {
    dynamic var charging: Bool
    dynamic var chargingTime: NSNumber
    dynamic var dischargingTime: NSNumber
    dynamic var level: NSNumber
    
    override init() {
        self.charging = true
        self.chargingTime = 0
        self.dischargingTime = 999
        self.level = 1.0
    }
    
    class func getBattery() -> BatteryManager {
        // Object to export to JavaScript
        let battery = BatteryManager()
        
        // Use IOKit to get battery infomation
        let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(blob).takeRetainedValue()
        let sourceArray:NSArray = sources
        if (sourceArray.count == 0) { // Could not retrieve battery information.
            return battery
        } else {
            let batterySource = sourceArray.objectAtIndex(0) // just use first battery
            let pSource = IOPSGetPowerSourceDescription(blob, batterySource).takeUnretainedValue()
            
            let batteryDic:NSDictionary = pSource
            
            let isCharge = batteryDic.objectForKey(kIOPSIsChargingKey) as! Int // 1 for charging, 0 for not
            let curCapacity = batteryDic.objectForKey(kIOPSCurrentCapacityKey) as! Int // current capacity
            let maxCapacity = batteryDic.objectForKey(kIOPSMaxCapacityKey) as! Int // max capacity
            let chargingTime = batteryDic.objectForKey(kIOPSTimeToEmptyKey) as! Int // time to empty(not charging)
            let dischargingTime = batteryDic.objectForKey(kIOPSTimeToFullChargeKey) as! Int // time to full(charging)
            let level = Double(curCapacity) / Double(maxCapacity) // current level
            
            battery.charging = isCharge == 1 ? true : false
            battery.chargingTime = chargingTime
            battery.dischargingTime = dischargingTime
            battery.level = level
            
            return battery
        }
    }
    
}