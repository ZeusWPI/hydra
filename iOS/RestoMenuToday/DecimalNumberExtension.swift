//
//  DecimalNumberExtension.swift
//  Hydra
//
//  Created by Simon Schellaert on 11/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import Foundation

extension NSDecimalNumber {
    
    /**
    Creates and returns an NSDecimalNumber object whose value is equivalent to that in a given numeric string.
    All non-numerical characters are automatically stripped from the given string.
    */
    convenience init(euroString : String) {
        // Replace the comma by a point since the NSDecimalNumber expects a point as decimal separator
        var euroString = euroString.stringByReplacingOccurrencesOfString(",", withString: ".", options: nil, range: nil)

        // Remove any non-numerical characters
        let charactersToRemove = NSCharacterSet(charactersInString: "0123456789.").invertedSet
        euroString = "".join(euroString.componentsSeparatedByCharactersInSet(charactersToRemove))
        
        self.init(string: euroString)
    }
    
}