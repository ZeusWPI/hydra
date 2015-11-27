//
//  HomeFeedService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

let HomeFeedDidUpdateFeedNotification = "HomeFeedDidUpdateFeedNotification"
let UpdateInterval: Double = 30 * 60 // half an hour

class HomeFeedService {
    
    static let sharedService = HomeFeedService()
    
    let associationStore = AssociationStore.sharedStore()
    let restoStore = RestoStore.sharedStore()
    let schamperStore = SchamperStore.sharedStore()
    let preferencesService = PreferencesService.sharedService()
    let locationService = LocationService.sharedService
    
    var previousRefresh = NSDate()
    
    private init() {
        refreshStores()
        locationService.startUpdating()
        
        let notifications = [RestoStoreDidReceiveMenuNotification, AssociationStoreDidUpdateActivitiesNotification, AssociationStoreDidUpdateNewsNotification, SchamperStoreDidUpdateArticlesNotification]
        for notification in notifications {
             NSNotificationCenter.defaultCenter().addObserver(self, selector: "storeUpdatedNotification:", name: notification, object: nil)
        }
    }
    
    
    @objc func storeUpdatedNotification(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName(HomeFeedDidUpdateFeedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func refreshStoresIfNecessary()
    {
        if self.previousRefresh.timeIntervalSinceNow > -UpdateInterval {
            self.refreshStores()
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(HomeFeedDidUpdateFeedNotification, object: nil)
        }
    }
    
    func refreshStores() {
        previousRefresh = NSDate()
        associationStore.reloadActivities()
        associationStore.reloadNewsItems()
        
        restoStore.menuForDay(NSDate())
        restoStore.locations
        
        schamperStore.reloadArticles()
    }
    
    func createFeed() -> [FeedItem] {
        var list = [FeedItem]()

        let feedItemProviders: [FeedItemProtocol] = [associationStore, restoStore, schamperStore]

        for provider in feedItemProviders {
            list.appendContentsOf(provider.feedItems())
        }
        
        // Urgent.fm
        list.append(FeedItem(itemType: .UrgentItem, object: nil, priority: 825))
        
        list.sortInPlace{ $0.priority > $1.priority }
        
        return list
    }
}

protocol FeedItemProtocol {
    func feedItems() -> [FeedItem]
}

struct FeedItem {
    let itemType: FeedItemType
    let object: AnyObject?
    let priority: Int
    
    init(itemType: FeedItemType, object: AnyObject?, priority: Int) {
        self.itemType = itemType
        self.object = object
        self.priority = priority
    }
}

enum FeedItemType {
    case NewsItem
    case ActivityItem
    case InfoItem
    case RestoItem
    case UrgentItem
    case SchamperNewsItem
    case SettingsItem
}