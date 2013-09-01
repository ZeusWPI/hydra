//
//  RestoMenu.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMenu.h"
#import <RestKit/RestKit.h>

@implementation RestoMenu

- (NSString *)description
{
    NSUInteger count = [self.meat count] + [self.vegetables count];
    return [NSString stringWithFormat:@"<RestoMenu for %@ (%d items) open=%@>",
                self.day, count, NSStringFromBOOL(self.open)];
}

+ (RKObjectMapping *)objectMapping
{
    // Create mapping for menu-item
    RKObjectMapping *itemMapping = [RKObjectMapping mappingForClass:[RestoMenuItem class]];
    [itemMapping addAttributeMappingsFromArray:@[@"name", @"price", @"recommended"]];

    // Create mapping for menu
    RKObjectMapping *menuMapping = [RKObjectMapping mappingForClass:self];
    [menuMapping setForceCollectionMapping:YES];
    [menuMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"day"];
    [menuMapping addAttributeMappingsFromDictionary:
     @{
       @"(day).open": @"open",
       @"(day).vegetables": @"vegetables"
       }];
    RKRelationshipMapping *meatRelationshipMapping =
    [RKRelationshipMapping relationshipMappingFromKeyPath:@"(day).meat" toKeyPath:@"meat" withMapping:itemMapping];
    RKRelationshipMapping *soupRelationshipMapping =
    [RKRelationshipMapping relationshipMappingFromKeyPath:@"(day).soup" toKeyPath:@"soup" withMapping:itemMapping];
    [menuMapping addPropertyMappingsFromArray:@[meatRelationshipMapping,soupRelationshipMapping]];
    // Date format: 2012-03-26
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    menuMapping.dateFormatters = @[ dateFormatter ];

    return menuMapping;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.day = [coder decodeObjectForKey:@"day"];
        self.open = [coder decodeBoolForKey:@"open"];
        self.meat = [coder decodeObjectForKey:@"meat"];
        self.vegetables = [coder decodeObjectForKey:@"vegetables"];
        self.soup = [coder decodeObjectForKey:@"soup"];
        self.lastUpdated = [coder decodeObjectForKey:@"lastUpdated"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.day forKey:@"day"];
    [coder encodeBool:self.open forKey:@"open"];
    [coder encodeObject:self.meat forKey:@"meat"];
    [coder encodeObject:self.vegetables forKey:@"vegetables"];
    [coder encodeObject:self.soup forKey:@"soup"];
    [coder encodeObject:self.lastUpdated forKey:@"lastUpdated"];
}

@end

@implementation RestoMenuItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RestoMenuItem: %@ (%@)>", self.name, self.price];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.price = [coder decodeObjectForKey:@"price"];
        self.recommended = [coder decodeBoolForKey:@"recommended"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.price forKey:@"price"];
    [coder encodeBool:self.recommended forKey:@"recommended"];
}

@end