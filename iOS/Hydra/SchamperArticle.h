//
//  SchamperArticle.h
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMappingProvider;

@interface SchamperArticle : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, assign) BOOL read;

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;

@end
