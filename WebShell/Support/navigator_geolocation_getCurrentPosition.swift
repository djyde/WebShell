//
//  navigator_geolocation_getCurrentPosition.swift
//  WebShell
//
//  Created by Wesley de Groot on 29-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import CoreLocation

// @wdg Add location support
// Issue: #41
// This extension will handle all the location services.
extension WSViewController {
	
    /**
     websiteWantsLocation
     
     the requested website wants/needs location services, so start it up
     */
	func websiteWantsLocation() -> Void {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startUpdatingLocation()
	}
	
    /**
     locationManager got some locations for us!

     - Parameter manager: CLLocationManager
     - Parameter locations: AnyObject
     */
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location: CLLocation = locations[0] 
		self.locationInjector(true, location)
	}

    /**
     locationManager got a error!
     
     - Parameter manager: CLLocationManager
     - Parameter error: NSError
     */
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		self.locationInjector(false)
	}
	
    /**
     locationManager got some locations for us!
     
     - Parameter haveLocation: (Bool) have the location?
     - Parameter location: (CLLocation) the location
     */
	func locationInjector(_ haveLocation: Bool, _ location: CLLocation? = CLLocation()) {
		// Ok inject new java Thing! (Cool!)
		let navigatorGeolocationGetCurrentPosition: @convention(block)(String?, String?, String?) -> String = {(correct: String?, invalid: String?, extra: String?) in
			// Checked with.
			// navigator.geolocation.getCurrentPosition(function(position) {console.log(position);},function(position) {console.log(position);});
			
			// X.coords.longitude
			// Safari Demo: > var x={coords: {longitude: 2, latitude: 1}}; console.log(x.coords.longitude);
			// Safari Demo: [Log] 2
			
			if (haveLocation) {
				let check_correct: String = correct!.lowercased()[0...8]
				let returnAs: String = "{coords: {coords: 'Coordinates', accuracy: 10, altitude: \(location!.altitude), altitudeAccuracy: 10, heading: '\(location!.course)', longitude: \(location!.coordinate.longitude), latitude: \(location!.coordinate.latitude), speed: \(location!.speed)}}"
				
				if (check_correct == "function") {
					// Begin with function (all lowercase)
					var newFunction = correct!.lowercased()[0...8]
					// Make the function named _WSLRD (WebShell Location Return Data)
					newFunction = newFunction + " _WSLRD"
					// Check if has space or not, otherwise begin 1 character later
					newFunction = newFunction + (correct?[(correct?.lowercased()[8] == " " ? 8 : 7)...(correct?.count)!])!
					// Call the function
					newFunction = newFunction + "\n;_WSLRD(\(returnAs))" // Insert what to return
					
					self.mainWebview.mainFrame.javaScriptContext.evaluateScript(newFunction) // Call & Done.
				} else {
					// call something else if it is a function, otherwise throw a error.
					
                    let checkAndRun: String = String(describing: "if (typeof \(String(describing: correct)) === 'function'){\(String(describing: correct))(\(returnAs))}else{console.error('\(String(describing: correct)) is not a function')}")
					self.mainWebview.mainFrame.javaScriptContext.evaluateScript(checkAndRun) // Call & Done.
				}
			} else {
				if (invalid != nil) {
					let check_invalid: String = invalid!.lowercased()[0...8]
					let returnAs: String = "{coords: {coords: null, accuracy: null, altitude: null, altitudeAccuracy: null, heading: null, longitude: null, latitude: null, speed: null}}"
					
					if (check_invalid == "function") {
						// Begin with function (all lowercase)
						var newFunction = invalid!.lowercased()[0...8]
						// Make the function named _WSLRD (WebShell Location Return Data)
						newFunction = newFunction + " _WSLRD"
						// Check if has space or not, otherwise begin 1 character later
						newFunction = newFunction + invalid![(invalid!.lowercased()[8] == " " ? 8 : 7)...(invalid!.count)]
						// Call the function
						newFunction = newFunction + "\n;_WSLRD(\(returnAs))" // Insert what to return
						
						self.mainWebview.mainFrame.javaScriptContext.evaluateScript(newFunction) // Call & Done.
					} else {
						// call something else if it is a function, otherwise throw a error.
						
						let checkAndRun: String = "if (typeof \(invalid!) === 'function'){\(invalid!)(\(returnAs))}else{console.error('\(invalid!) is not a function')}"
						self.mainWebview.mainFrame.javaScriptContext.evaluateScript(checkAndRun) // Call & Done.
					}
				}
			}
			
			return "undefined"
		}
		self.mainWebview.mainFrame.javaScriptContext.objectForKeyedSubscript("navigator").objectForKeyedSubscript("geolocation").setObject(unsafeBitCast(navigatorGeolocationGetCurrentPosition, to: AnyObject.self), forKeyedSubscript: "getCurrentPosition" as (NSCopying & NSObjectProtocol)!)
	}
}
// TEST
/*
 Inject via webinfo

 > navigator.geolocation.getCurrentPosition(function(position) {console.log(position.coords.latitude);},function(position) {console.log(position);});
 < "undefined" = $2

 Xcode:
 JS: 52.3593145320769 (Your current latitude)
 */
