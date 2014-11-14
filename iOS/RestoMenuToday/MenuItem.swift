//
//  MenuItem.swift
//  Hydra
//
//  Created by Simon Schellaert on 12/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import UIKit



/**
Menu item type

- Main:      For main menu items (meat, fish and vegetarian)
- Vegetable: For vegetables
- Soup:      For soups (the meal soup is also considered a soup)
*/
enum MenuItemType {
    case Main
    case Vegetable
    case Soup
}



class MenuItem: NSObject, Printable {
    
    // MARK: Properties
    
    let name: String
    let type: MenuItemType
    let price: NSDecimalNumber?
    
    
    // MARK: Initialization
    
    init(name: String, type: MenuItemType, price: NSDecimalNumber?) {
        self.name = name
        self.type = type
        self.price = price
    }
    
    
    // MARK: <Printable>
    
    override var description : String {
        return "<MenuItem; name: \(self.name); type: \(self.type); price: \(self.price)>\n"
    }
}
