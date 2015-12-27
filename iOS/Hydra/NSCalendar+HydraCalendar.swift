//
//  NSCalendar+HydraCalendar.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

extension NSCalendar {
    
    class func hydraCalendar() -> NSCalendar {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
    }
}
