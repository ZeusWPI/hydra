//
//  SchamperStore.h
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SchamperStoreDidUpdateArticlesNotification;

@interface SchamperStore : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSArray *articles;
@property (nonatomic, strong, readonly) NSDate *lastUpdated;

+ (SchamperStore *)sharedStore;
- (void)updateArticles;

@end