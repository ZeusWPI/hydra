//
//  AssociationStore.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Association;

extern NSString *const AssociationStoreDidUpdateNewsNotification;
extern NSString *const AssociationStoreDidUpdateActivitiesNotification;

@interface AssociationStore : NSObject

@property (nonatomic, strong, readonly) NSArray *associations;
@property (nonatomic, strong, readonly) NSArray *allActivities;

+ (AssociationStore *)sharedStore;

- (NSArray *)activitiesForAssocation:(Association *)association;
- (NSArray *)newsItemsForAssocation:(Association *)association;

@end
