//
//  AssociationActivity.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AssociationActivity.h"
#import "AssociationStore.h"
#import <RestKit/RestKit.h>
#import "NSDate+Utilities.h"
#import "FacebookEvent.h"

@interface AssociationActivity ()

@property (nonatomic, strong) NSString *associationId;
@property (nonatomic, strong) Association *association;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) FacebookEvent *facebookEvent;

@end

@implementation AssociationActivity

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:self];

    [objectMapping mapAttributes:@"title", @"location", @"start", @"end", @"url",
        @"longitude", @"latitude", @"description", @"url", @"categories",
        @"highlighted", nil];
    [objectMapping mapKeyPathsToAttributes:
        @"association", @"associationId",
        @"facebook_id", @"facebookId", nil];

    [mappingProvider registerObjectMapping:objectMapping withRootKeyPath:@""];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssociationActivity: '%@' by %@ on %@>", self.title, self.associationId, self.start];
}

- (FacebookEvent *)facebookEvent
{
    if(!_facebookEvent && self.facebookId) {
        _facebookEvent = [[FacebookEvent alloc] initWithEventID:self.facebookId];
    }
    return _facebookEvent;
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
        self.title = [coder decodeObjectForKey:@"title"];
        self.associationId = [coder decodeObjectForKey:@"associationId"];
        self.start = [coder decodeObjectForKey:@"start"];
        self.end = [coder decodeObjectForKey:@"end"];
        self.location = [coder decodeObjectForKey:@"location"];
        self.longitude = [coder decodeDoubleForKey:@"longitude"];
        self.latitude = [coder decodeDoubleForKey:@"latitude"];
        self.facebookId = [coder decodeObjectForKey:@"facebookId"];
        self.description = [coder decodeObjectForKey:@"description"];
        self.url = [coder decodeObjectForKey:@"url"];
        self.categories = [coder decodeObjectForKey:@"categories"];
        self.highlighted = [coder decodeBoolForKey:@"highlighted"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.associationId forKey:@"associationId"];
    [coder encodeObject:self.start forKey:@"start"];
    [coder encodeObject:self.end forKey:@"end"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeDouble:self.longitude forKey:@"longitude"];
    [coder encodeDouble:self.latitude forKey:@"latitude"];
    [coder encodeObject:self.facebookId forKey:@"facebookId"];
    [coder encodeObject:self.description forKey:@"description"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.categories forKey:@"categories"];
    [coder encodeBool:self.highlighted forKey:@"highlighted"];
}

@end
