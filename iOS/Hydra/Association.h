//
//  Assocation.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Association : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSString *parentAssociation;

// Check that the current association list is up-to-date with the one provided in the application bundle
+ (NSDictionary *)updateAssociations:(NSDictionary *)associations;

@end
