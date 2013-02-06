//
//  AssociationNewsItem.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AssociationNewsItem.h"
#import "Association.h"
#import <RestKit/RestKit.h>

@implementation AssociationNewsItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssocationNewsItem '%@'>", self.title];
}

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:self];
    [objectMapping mapAttributes:@"title", @"date", @"content", @"highlighted", nil];
    [objectMapping mapRelationship:@"association" withMapping:[Association objectMapping]];
    return objectMapping;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.title = [coder decodeObjectForKey:@"title"];
        self.association = [coder decodeObjectForKey:@"association"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.highlighted = [coder decodeBoolForKey:@"highlighted"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.association forKey:@"association"];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeBool:self.highlighted forKey:@"highlighted"];
}

@end
