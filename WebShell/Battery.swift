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
    var chargingTime: Int { get set }
    var dischargingTime: Int { get set }
    var level: Double { get set }
    
    static func getBattery() -> BatteryManager
}

@objc class BatteryManager : NSObject, BatteryManagerJSExports {
    internal var level: Double
    internal var chargingTime: Int

    dynamic var charging: Bool
//    dynamic var chargingTime: Int
    dynamic var dischargingTime: Int
//    dynamic var level: Double
    
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
            let batterySource = sourceArray.object(at: 0) // just use first battery
            let pSource = IOPSGetPowerSourceDescription(blob, batterySource as CFTypeRef!).takeUnretainedValue()
            
            let batteryDic:NSDictionary = pSource
            
            let isCharge = batteryDic.object(forKey: kIOPSIsChargingKey) as! Int // 1 for charging, 0 for not
            let curCapacity = batteryDic.object(forKey: kIOPSCurrentCapacityKey) as! Int // current capacity
            let maxCapacity = batteryDic.object(forKey: kIOPSMaxCapacityKey) as! Int // max capacity
            let chargingTime = batteryDic.object(forKey: kIOPSTimeToEmptyKey) as! Int // time to empty(not charging)
            let dischargingTime = batteryDic.object(forKey: kIOPSTimeToFullChargeKey) as! Int // time to full(charging)
            let level = Double(curCapacity) / Double(maxCapacity) // current level
            
            battery.charging = isCharge == 1 ? true : false
            battery.chargingTime = chargingTime
            battery.dischargingTime = dischargingTime
            battery.level = level
            
            return battery
        }
    }
    
}
