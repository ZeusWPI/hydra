//
//  AssociationActivity.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMappingProvider, Association;

@interface AssociationActivity : NSObject <NSCoding>

@property (nonatomic, strong) NSString *associationId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;

@property (nonatomic, readonly) Association *association;

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;

@end
