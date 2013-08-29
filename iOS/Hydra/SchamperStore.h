//
//  SchamperStore.h
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SchamperStoreDidUpdateArticlesNotification;

@interface SchamperStore : NSObject

@property (nonatomic, strong, readonly) NSArray *articles;
@property (nonatomic, assign) BOOL updateCache;

+ (SchamperStore *)sharedStore;
- (void)updateArticles;
- (void)reloadArticles;
- (void)updateStoreCache;

@end