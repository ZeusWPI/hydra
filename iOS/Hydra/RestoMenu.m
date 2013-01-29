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

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;
{
    // Create mapping for menu-item
    RKObjectMapping *itemMapping = [RKObjectMapping mappingForClass:[RestoMenuItem class]];
    [itemMapping mapAttributes:@"name", @"price", @"recommended", nil];

    // Create mapping for menu
    RKObjectMapping *menuMapping = [RKObjectMapping mappingForClass:self];
    [menuMapping setForceCollectionMapping:YES];
    [menuMapping mapKeyOfNestedDictionaryToAttribute:@"day"];
    [menuMapping mapKeyPath:@"(day).meat" toRelationship:@"meat" withMapping:itemMapping];
    [menuMapping mapKeyPath:@"(day).soup" toRelationship:@"soup" withMapping:itemMapping];
    [menuMapping mapKeyPath:@"(day).open" toAttribute:@"open"];
    [menuMapping mapKeyPath:@"(day).vegetables" toAttribute:@"vegetables"];

    // Date format: 2012-03-26
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    menuMapping.dateFormatters = @[ dateFormatter ];

    // Register mapping
    [mappingProvider setObjectMapping:menuMapping forKeyPath:@""];
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