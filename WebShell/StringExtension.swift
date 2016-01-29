//
//  StringExtension.swift
//  WebShell
//
//  Created by Wesley de Groot on 17-01-16.
//  Copyright © 2016 WDGWV. All rights reserved.
//

import Foundation

/**
 Extensions for Strings
 */
public extension String {
    /**
     get string length
     */
    public var length: Int {
        get {
            return self.characters.count
        }
    }
    
    /**
     contains
     - Parameter s: String to check
     - Returns: true/false
     */
    public func contains(s: String) -> Bool {
        return self.rangeOfString(s) != nil ? true : false
    }
    
    /**
     Replace
     - Parameter target: String
     - Parameter withString: Replacement
     - Returns: Replaced string
     */
    public func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    /**
     Character At Index
     - Parameter index: The index
     - Returns Character
     */
    func characterAtIndex(index: Int) -> Character! {
        var cur = 0
        for char in self.characters {
            if cur == index {
                return char
            }
            cur++
        }
        return nil
    }
    
    /**
     add subscript
     */
    public subscript(i: Int) -> Character {
        get {
            let index = self.startIndex.advancedBy(i)
            return self[index]
        }
    }
    /**
     add subscript
     */
    public subscript(r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex - 1)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}