//
//  Settings.swift
//  WebShell
//
//  Created by Wesley de Groot on 23-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation

class Settings: WSBaseSettings {
	static let shared = Settings()
	
	override private init() {
		super.init()
		// Override default settings for this particular target
		self.url = "http://djyde.github.io/WebShell/WebShell/"
		self.menuBarApp = true
	}
}
