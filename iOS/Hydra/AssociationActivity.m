//
//  AssociationActivity.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AssociationActivity.h"
#import "Association.h"
#import "NSDate+Utilities.h"
#import "FacebookEvent.h"
#import <RestKit/RestKit.h>

@interface AssociationActivity ()

@end

@implementation AssociationActivity

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:self];

    [objectMapping mapAttributes:@"title", @"location", @"start", @"end", @"url",
        @"latitude", @"longitude", @"url", @"categories", @"highlighted", nil];
    [objectMapping mapKeyPathsToAttributes:@"facebook_id", @"facebookId",
        @"description", @"descriptionText", nil];
    [objectMapping mapRelationship:@"association" withMapping:[Association objectMapping]];

    return objectMapping;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssociationActivity: '%@' by %@ on %@>",
            self.title, self.association.displayName, self.start];
}

- (FacebookEvent *)facebookEvent
{
    if(!_facebookEvent && [self.facebookId length] > 0) {
        _facebookEvent = [[FacebookEvent alloc] initWithEventId:self.facebookId];
    }
    return _facebookEvent;
}

- (BOOL)hasCoordinates
{
    return self.latitude != 0 && self.longitude != 0;
}

- (BOOL)hasFacebookEvent
{
    if (_facebookEvent) {
        return _facebookEvent.valid;
    }
    return NO;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.title = [coder decodeObjectForKey:@"title"];
        self.association = [coder decodeObjectForKey:@"association"];
        self.start = [coder decodeObjectForKey:@"start"];
        self.end = [coder decodeObjectForKey:@"end"];
        self.location = [coder decodeObjectForKey:@"location"];
        self.longitude = [coder decodeDoubleForKey:@"longitude"];
        self.latitude = [coder decodeDoubleForKey:@"latitude"];
        self.facebookId = [coder decodeObjectForKey:@"facebookId"];
        self.descriptionText = [coder decodeObjectForKey:@"descriptionText"];
        self.url = [coder decodeObjectForKey:@"url"];
        self.categories = [coder decodeObjectForKey:@"categories"];
        self.highlighted = [coder decodeBoolForKey:@"highlighted"];
        self.facebookEvent = [coder decodeObjectForKey:@"facebookEvent"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.association forKey:@"association"];
    [coder encodeObject:self.start forKey:@"start"];
    [coder encodeObject:self.end forKey:@"end"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeDouble:self.longitude forKey:@"longitude"];
    [coder encodeDouble:self.latitude forKey:@"latitude"];
    [coder encodeObject:self.facebookId forKey:@"facebookId"];
    [coder encodeObject:self.descriptionText forKey:@"descriptionText"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.categories forKey:@"categories"];
    [coder encodeBool:self.highlighted forKey:@"highlighted"];
    [coder encodeObject:_facebookEvent forKey:@"facebookEvent"];
}

@end
