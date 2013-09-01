//
//  AssociationNewsItem.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AssociationNewsItem.h"
#import "Association.h"
#import "AssociationStore.h"
#import <RestKit/RestKit.h>

@implementation AssociationNewsItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssocationNewsItem '%@'>", self.title];
}

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:self];
    [objectMapping addAttributeMappingsFromArray:@[@"title", @"date", @"content", @"highlighted"]];
    [objectMapping addAttributeMappingsFromDictionary:@{@"id": @"itemId"}];
    [objectMapping addRelationshipMappingWithSourceKeyPath:@"association" mapping:[Association objectMapping]];
    return objectMapping;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        _itemId = [coder decodeIntegerForKey:@"itemId"];
        _title = [coder decodeObjectForKey:@"title"];
        _association = [coder decodeObjectForKey:@"association"];
        _date = [coder decodeObjectForKey:@"date"];
        _content = [coder decodeObjectForKey:@"content"];
        _highlighted = [coder decodeBoolForKey:@"highlighted"];
        _read = [coder decodeBoolForKey:@"read"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.itemId forKey:@"itemId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.association forKey:@"association"];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeBool:self.highlighted forKey:@"highlighted"];
    [coder encodeBool:self.read forKey:@"read"];
}

#pragma mark - Properties

- (void)setRead:(BOOL)read
{
    if (read != _read) {
        _read = read;
        [[AssociationStore sharedStore] markStorageOutdated];
    }
}

@end
