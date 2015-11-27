//
//  SchamperStore.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 20/11/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation

extension SchamperStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        var feedItems = [FeedItem]()
        if let articles = articles as? [SchamperArticle] {
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
}