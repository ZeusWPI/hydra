//
//  AssociationNewsItem.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Association, RKObjectMappingProvider;

@interface AssociationNewsItem : NSObject

@property (nonatomic, copy) NSString *associationId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *body;

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;

@end
