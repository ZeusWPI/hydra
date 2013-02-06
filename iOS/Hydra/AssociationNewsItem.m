//
//  AssociationNewsItem.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AssociationNewsItem.h"
#import <RestKit/RestKit.h>
#import "AssociationStore.h"

@interface AssociationNewsItem ()

@property (nonatomic, strong) NSString *associationId;
@property (nonatomic, strong) Association *association;

@end

@implementation AssociationNewsItem

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:self];
    [objectMapping mapAttributes:@"title", @"date", @"content", @"highlighted", nil];
    [objectMapping mapKeyPath:@"association" toAttribute:@"associationId"];
    
    [mappingProvider registerObjectMapping:objectMapping withRootKeyPath:@""];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssocationNewsItem '%@'>", self.title];
}

- (Association *)association
{
    if (!_association) {
        _association = [[AssociationStore sharedStore] associationWithName:self.associationId];
    }
    return _association;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.associationId = [coder decodeObjectForKey:@"associationId"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.date = [coder decodeObjectForKey:@"date"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.highlighted = [coder decodeBoolForKey:@"highlighted"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.associationId forKey:@"associationId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeBool:self.highlighted forKey:@"highlighted"];
}

@end
