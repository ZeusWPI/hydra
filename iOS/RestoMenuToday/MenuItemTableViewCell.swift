//
//  MenuItemTableViewCell.swift
//  Hydra
//
//  Created by Simon Schellaert on 12/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    
    // MARK: Interface Builder Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    // MARK: Properties
    
    let numberFormatter = NSNumberFormatter()
    
    var menuItem : MenuItem! {
        didSet {
            if menuItem != nil {
                self.nameLabel.text  = menuItem.name
                
                if let price = menuItem.price {
                    self.priceLabel.text = numberFormatter.stringFromNumber(price)
                } else {
                    self.priceLabel.text = ""
                }
            }
        }
    }
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        self.numberFormatter.numberStyle = .CurrencyStyle
        self.numberFormatter.locale = NSLocale(localeIdentifier: "nl_BE")
        
        super.init(coder: aDecoder)
    }
}
