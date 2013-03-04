//
//  AssociationActivity.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping, Association, FacebookEvent;

@interface AssociationActivity : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) Association *association;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, assign) BOOL highlighted;

@property (nonatomic, strong, readonly) FacebookEvent *facebookEvent;

+ (RKObjectMapping *)objectMapping;
- (BOOL)hasCoordinates;

@end
