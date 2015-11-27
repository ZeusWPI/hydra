//
//  Menu.swift
//  Hydra
//
//  Created by Simon Schellaert on 12/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import UIKit

class Menu: NSObject {
    
    // MARK: Properties
    
    let date: NSDate
    let menuItems: [MenuItem]
    let open: Bool

    // MARK: Initialization
    
    init(date: NSDate, menuItems: [MenuItem], open: Bool) {
        self.date = date
        self.menuItems = menuItems
        self.open = open
    }

    // MARK: <Printable>
    
    override var description : String {
        return "<Menu; date: \(self.date); menuItems: \(self.menuItems); open: \(self.open)>"
    }
}
