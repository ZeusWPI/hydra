//
//  HomeFeedService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

class HomeFeedService {
    
    static let sharedService = HomeFeedService()
    
    let associationStore = AssociationStore.sharedStore()
    let restoStore = RestoStore.sharedStore()
    let schamperStore = SchamperStore.sharedStore()
    let preferencesService = PreferencesService.sharedService()
    
    private init() {
        refreshStores()
    }
    
    func refreshStores() {
        associationStore.reloadActivities()
        associationStore.reloadNewsItems()
        
        restoStore.menuForDay(NSDate())
        restoStore.locations
        
        schamperStore.reloadArticles()
    }
    
    func createFeed() -> Array<FeedItem> {
        var list = Array<FeedItem>()
        //TODO: unread recent important news
        
        // resto today
        //TODO: test if today is weekday
        list.append(FeedItem(itemType: .RestoItem, object: restoStore.menuForDay(NSDate())))
        return list
    }
}

struct FeedItem {
    let itemType: FeedItemType
    let object: AnyObject?
    
    init(itemType: FeedItemType, object: AnyObject? ) {
        self.itemType = itemType
        self.object = object
    }
}

enum FeedItemType {
    case NewsItem
    case ActivityItem
    case InfoItem
    case RestoItem
    case UrgentItem
    case SchamperNewsItem
}