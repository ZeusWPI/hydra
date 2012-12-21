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

@property (nonatomic, strong) Association *association;

@end

@implementation AssociationNewsItem

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:self];
    [objectMapping mapAttributes:@"title", @"date", nil];
    [objectMapping mapKeyPath:@"description" toAttribute:@"body"];
    [objectMapping mapKeyPath:@"association_id" toAttribute:@"associationId"];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"dd/MM/yyyy"];
    [objectMapping setDateFormatters:@[ dayFormatter ]];
    
    [mappingProvider registerObjectMapping:objectMapping withRootKeyPath:@"newsItem"];
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
        self.body = [coder decodeObjectForKey:@"body"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.associationId forKey:@"associationId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.body forKey:@"body"];
}

@end
