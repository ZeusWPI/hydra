//
//  AssociationNewsItem.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMappingProvider, Association;

@interface AssociationNewsItem : NSObject

@property (nonatomic, strong) NSString *associationId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *body;

@property (nonatomic, readonly) Association *association;

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;

@end
