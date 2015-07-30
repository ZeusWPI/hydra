//
//  String.swift
//  Hydra
//
//  Created by Simon Schellaert on 14/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import Foundation

extension String {
    /** 
    A representation of the receiver with the first character capitalized. (read-only)
    */
    var sentenceCapitalizedString : NSString {
        if self.characters.count > 0 {
            return (self as NSString).substringToIndex(1).uppercaseString.stringByAppendingString((self as NSString).substringFromIndex(1))
        } else {
            return self
        }
    }
}