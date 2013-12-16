//
//  RestoLegend.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface RestoLegendItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *style; // if bold or underlined

+ (RKObjectMapping *)objectMapping;

@end