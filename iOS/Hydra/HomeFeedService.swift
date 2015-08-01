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
    
    func createFeed() -> [FeedItem] {
        var list = [FeedItem]()
        //TODO: unread recent important news
        
        // activities
        list.extend(getActivities())
        
        // resto menus
        list.extend(getRestoMenus())
        
        // schamper articles
        list.extend(getSchamperArticles())
        
        list.sortInPlace{ $0.priority > $1.priority }
        
        list.map { el in debugPrint("Type: \(el.itemType), priority: \(el.priority)")}
        return list
    }
    
    //MARK: - Resto functions
    private func getRestoMenus() -> [FeedItem]{
        var day = NSDate()
        var days = [FeedItem]()
        
        // Find the next x days to display
        while (days.count < 5) { //TODO: replace with var
            if day.isTypicallyWorkday() {
                var menu = restoStore.menuForDay(day)
                
                if (menu == nil) {
                    menu = RestoMenu()
                    menu.open = false
                    menu.day = day
                }
                
                days.append(FeedItem(itemType: .RestoItem, object: menu, priority: 1000 - 100*days.count))
            }
            day = day.dateByAddingDays(1)
        }
        
        return days
    }
    
    private func getSchamperArticles() -> [FeedItem] {
        var higlightedArticles = [FeedItem]()
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
                    higlightedArticles.append(FeedItem(itemType: .SchamperNewsItem, object: article, priority: priority))
                }
            }
        }
        return higlightedArticles
    }
    
    private func getActivities() -> [FeedItem] {
        var highlightedActivities = [FeedItem]()
        if let activities = associationStore.activities as? [AssociationActivity] {
            for activity in activities {
                var priority = 1001 //TODO: calculate priorities
                priority += 1
                if priority > 0 {
                    highlightedActivities.append(FeedItem(itemType: .ActivityItem, object: activity, priority: priority))
                }
            }
        }
        return highlightedActivities
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
}