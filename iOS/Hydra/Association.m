//
//  Association.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "Association.h"
#import "NSDate+Utilities.h"
#import <RestKit/RestKit.h>

@implementation Association

- (NSString *)displayedFullName
{
    if (_fullName) {
        return [NSString stringWithFormat:@"%@ (%@)", _displayName, _fullName];
    }
    else {
        return _displayName;
    }
}

- (NSString *)fullName
{
    if (_fullName) {
        return _fullName;
    }
    else {
        return _displayName;
    }
}

- (BOOL)matches:(NSString *)query
{
    NSStringCompareOptions opts = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    return (_internalName && [_internalName rangeOfString:query options:opts].location != NSNotFound) ||
    (_displayName && [_displayName rangeOfString:query options:opts].location != NSNotFound) ||
    (_fullName && [_fullName rangeOfString:query options:opts].location != NSNotFound);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Association: %@>", self.displayName];
}

+ (RKObjectMapping *)objectMappingActivities
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"internal_name": @"internalName",
                                                  @"full_name": @"fullName",
                                                  @"display_name": @"displayName"
                                                  }];
    return mapping;
}

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[
                                             @"displayName", @"fullName", @"internalName", @"parentAssociation"
                                             ]];
    return mapping;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        _displayName = [coder decodeObjectForKey:@"displayName"];
        _fullName = [coder decodeObjectForKey:@"fullName"];
        _internalName = [coder decodeObjectForKey:@"internalName"];
        _parentAssociation = [coder decodeObjectForKey:@"parentAssociation"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_displayName forKey:@"displayName"];
    [coder encodeObject:_fullName forKey:@"fullName"];
    [coder encodeObject:_internalName forKey:@"internalName"];
    [coder encodeObject:_parentAssociation forKey:@"parentAssociation"];
}

#pragma mark - NSCopying

- (NSUInteger)hash
{
    return [self.internalName hash];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[self class]] && [self.internalName isEqual:[object internalName]];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end