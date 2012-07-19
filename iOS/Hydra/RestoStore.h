//
//  SchamperStore.h
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

extern NSString *const RestoStoreDidReceiveMenuNotification;

@class RestoMenu;

@interface RestoStore : NSObject <NSCoding, RKObjectLoaderDelegate> {
    RKObjectManager *objectManager;
    NSMutableArray *activeRequests;
    NSMutableDictionary *menus;
}

+ (RestoStore *)sharedStore;
- (RestoMenu *)menuForDay:(NSDate *)day;

@end