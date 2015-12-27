//
//  AssociationStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 20/11/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

extension AssociationStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        return getActivities() + getNewsItems()
    }
    
    private func getActivities() -> [FeedItem] {
        var feedItems = [FeedItem]()
        let preferencesService = PreferencesService.sharedService()
        if let activities = activities as? [AssociationActivity] {
            var filter: ((AssociationActivity) -> (Bool))
            if preferencesService.filterAssociations {
                let associations = preferencesService.preferredAssociations
                filter = { activity in activity.highlighted || associations.contains { activity.association.internalName == ($0 as! String) } }
            } else {
                if preferencesService.showActivitiesInFeed {
                    filter = { _ in true }
                } else {
                    filter = { $0.highlighted }
                    feedItems.append(FeedItem(itemType: .SettingsItem, object: nil, priority: 850))
                }
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
        
        if let newsItems = newsItems as? [AssociationNewsItem] {
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