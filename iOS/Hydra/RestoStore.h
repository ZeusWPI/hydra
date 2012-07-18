//
//  SchamperStore.h
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const RestoStoreDidReceiveMenuNotification;

@interface RestoStore : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSArray *menuItems;
@property (nonatomic, readonly) NSUInteger week;

+ (RestoStore *)sharedStore;
- (void)updateMenu;

@end