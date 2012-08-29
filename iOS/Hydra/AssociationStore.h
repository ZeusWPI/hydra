//
//  AssociationStore.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@class Association;

extern NSString *const AssociationStoreDidUpdateNewsNotification;
extern NSString *const AssociationStoreDidUpdateActivitiesNotification;

@interface AssociationStore : NSObject <NSCoding, RKObjectLoaderDelegate, RKRequestDelegate>

@property (nonatomic, strong, readonly) NSArray *associations;

+ (AssociationStore *)sharedStore;

- (NSArray *)activitiesForAssocation:(Association *)association;
- (NSArray *)newsItemsForAssocation:(Association *)association;

@end
