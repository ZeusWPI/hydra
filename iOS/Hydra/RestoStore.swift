//
//  RestoStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 20/11/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

extension RestoStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        var day = NSDate()
        if day.hour > 20 {
            day = day.dateByAddingDays(1)
        }
        var feedItems = [FeedItem]()
        
        // Find the next x days to display
        while (feedItems.count < 5) { //TODO: replace with var
            if day.isTypicallyWorkday() {
                var menu = menuForDay(day)
                
                if (menu == nil) {
                    menu = RestoMenu()
                    menu.open = false
                    menu.day = day
                }
                
                feedItems.append(FeedItem(itemType: .RestoItem, object: menu, priority: 1000 - 100*feedItems.count))
            }
            day = day.dateByAddingDays(1)
        }
        
        return feedItems
    }
}