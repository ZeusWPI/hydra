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
        
        // resto today
        for feedItem in calculateDays() {
            list.append(feedItem)
        }
        
        return list
    }
    
    //MARK: - Resto functions
    private func calculateDays() -> [FeedItem]{
        var day = NSDate()
        var days = [FeedItem]()
        
        // Find the next x days to display
        while (days.count < 5) { //TODO: replace with var
            if day.isTypicallyWorkday() {
                days.append(FeedItem(itemType: .RestoItem, object: restoStore.menuForDay(day)))
            }
            day = day.dateByAddingDays(1)
        }
        
        return days
    }
    
    private func getSchamperArticles() -> [FeedItem]{
        var higlighted_articles = [FeedItem]()
        if let articles = schamperStore.articles as? [SchamperArticle] {
            for article in articles { //TODO: test articles and sort them
                higlighted_articles.append(FeedItem(itemType: .SchamperNewsItem, object: article))
            }
        }
        return higlighted_articles
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