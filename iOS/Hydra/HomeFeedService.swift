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

        // news items
        list.appendContentsOf(getNewsItems())
        
        // activities
        list.appendContentsOf(getActivities())
        
        // resto menus
        list.appendContentsOf(getRestoMenus())
        
        // schamper articles
        list.appendContentsOf(getSchamperArticles())
        
        // Urgent.fm
        list.append(FeedItem(itemType: .UrgentItem, object: nil, priority: 825))
        
        list.sortInPlace{ $0.priority > $1.priority }
        
        return list
    }
    
    //MARK: - Resto functions
    private func getRestoMenus() -> [FeedItem]{
        var day = NSDate()
        if day.hour > 20 {
            day = day.dateByAddingDays(1)
        }
        var feedItems = [FeedItem]()
        
        // Find the next x days to display
        while (feedItems.count < 5) { //TODO: replace with var
            if day.isTypicallyWorkday() {
                var menu = restoStore.menuForDay(day)
                
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
    
    private func getSchamperArticles() -> [FeedItem] {
        var feedItems = [FeedItem]()
        if let articles = schamperStore.articles as? [SchamperArticle] {
            for article in articles { //TODO: test articles and sort them
                let daysOld = article.date.daysBeforeDate(NSDate())
                var priority = 999
                if !article.read {
                    priority = priority - daysOld*40
                } else {
                    priority = priority - daysOld*150
                }
                if priority > 0 {
                    feedItems.append(FeedItem(itemType: .SchamperNewsItem, object: article, priority: priority))
                }
            }
        }
        return feedItems
    }
    
    private func getActivities() -> [FeedItem] {
        var feedItems = [FeedItem]()
        if let activities = associationStore.activities as? [AssociationActivity] {
            var filter: ((AssociationActivity) -> (Bool))
            if preferencesService.filterAssociations {
                let associations = preferencesService.preferredAssociations
                filter = { activity in activity.highlighted || associations.contains { activity.association.internalName == ($0 as! String) } }
            } else {
                filter = { $0.highlighted }
                feedItems.append(FeedItem(itemType: .SettingsItem, object: nil, priority: 850))
            }

            for activity in activities.filter(filter) {
                // Force load facebookEvent
                if let facebookEvent = activity.facebookEvent {
                    facebookEvent.update()
                }
                var priority = 999 //TODO: calculate priorities, with more options
                priority -= activity.start.daysAfterDate(NSDate()) * 100
                if priority > 0 {
                    feedItems.append(FeedItem(itemType: .ActivityItem, object: activity, priority: priority))
                }
            }
        }
        return feedItems
    }
    
    private func getNewsItems() -> [FeedItem] {
        var feedItems = [FeedItem]()
        
        if let newsItems = associationStore.newsItems as? [AssociationNewsItem] {
            for newsItem in newsItems {
                var priority = 999
                let daysOld = newsItem.date.daysBeforeDate(NSDate())
                if newsItem.highlighted {
                    priority -= 25*daysOld
                } else {
                    priority -= 90*daysOld
                }

                if priority > 0 {
                    feedItems.append(FeedItem(itemType: .NewsItem, object: newsItem, priority: priority))
                }
            }
        }
        
        return feedItems
    }
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