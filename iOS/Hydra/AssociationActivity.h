//
//  AssociationActivity.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMappingProvider;

@interface AssociationActivity : NSObject

@property (nonatomic, copy) NSString *associationId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;

@end
