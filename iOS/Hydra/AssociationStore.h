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

@interface AssociationStore : NSObject <NSCoding, RKObjectLoaderDelegate> {
    RKObjectManager *objectManager;
}

@property (nonatomic, strong, readonly) NSArray *assocations;

+ (AssociationStore *)sharedStore;

- (NSArray *)activitiesForAssocation:(Association *)assocation;
- (NSArray *)newsItemsForAssocation:(Association *)assocation;

@end
