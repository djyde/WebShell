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
		// Overridden settings for this target
		self.url = "http://udemy.com"
		
	}
}
