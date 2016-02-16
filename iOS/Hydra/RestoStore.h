//
//  SchamperStore.h
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const RestoStoreDidReceiveMenuNotification;
extern NSString *const RestoStoreDidUpdateInfoNotification;
extern NSString *const RestoStoreDidUpdateSandwichesNotification;

@class RestoMenu;

@interface RestoStore : NSObject

@property (nonatomic, strong, readonly) NSArray *locations;
@property (nonatomic, strong, readonly) NSArray *legend;
@property (nonatomic, strong, readonly) NSArray *sandwiches;

+ (RestoStore *)sharedStore;
- (RestoMenu *)menuForDay:(NSDate *)day;

@end