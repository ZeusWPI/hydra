//
//  Assocation.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Association : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *internalName;

+ (NSArray *)updateAssociations:(NSArray *)associations lastModified:(NSDate *)date;

@end
