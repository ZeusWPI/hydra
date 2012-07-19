//
//  RestoMenu.h
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface RestoMenuItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *price;
@property (nonatomic) BOOL recommended;

@end

@interface RestoMenu : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *day;
@property (nonatomic) BOOL open;
@property (nonatomic, strong) NSArray *meat;
@property (nonatomic, strong) NSArray *vegetables;
@property (nonatomic, strong) RestoMenuItem *soup;

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;

@end
