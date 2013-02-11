//
//  Assocation.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "Association.h"
#import "NSDate+Utilities.h"
#import <RestKit/RestKit.h>

NSString *const AssociationsLastUpdatedPref = @"AssociationsLastUpdated";

@implementation Association

+ (NSDictionary *)updateAssociations:(NSDictionary *)associations
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastModified = [userDefaults valueForKey:AssociationsLastUpdatedPref];
    NSDate *currentVersion = [self currentVersion];
    
    if (!associations || [currentVersion isLaterThanDate:lastModified]) {
        associations = [self loadFromPlist];
        [userDefaults setObject:currentVersion forKey:AssociationsLastUpdatedPref];
    }
    return associations;
}

+ (NSString *)initializationPath
{
    return [[NSBundle mainBundle] pathForResource:@"Associations" ofType:@"plist"];
}

+ (NSDate *)currentVersion
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [self initializationPath];

    NSDictionary *attributes = [manager attributesOfItemAtPath:filePath error:nil];
    return attributes[NSFileModificationDate];
}

+ (NSDictionary *)loadFromPlist
{
    NSArray *bundled = [NSArray arrayWithContentsOfFile:[self initializationPath]];

    NSMutableDictionary *associations = [NSMutableDictionary dictionaryWithCapacity:bundled.count];
    for (NSUInteger i = 0; i < bundled.count; i++) {
        NSDictionary *props = bundled[i];

        Association *assoc = [[Association alloc] init];
        assoc.displayName = props[@"displayName"];
        assoc.fullName = props[@"fullName"];
        assoc.internalName = props[@"internalName"];
        assoc.parentAssociation = props[@"parentAssociation"];

        associations[assoc.internalName] = assoc;
    }
    return associations;
}

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

+ (RKObjectMapping *)objectMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping mapKeyPathsToAttributes:
        @"internal_name", @"internalName",
        @"full_name", @"fullName",
        @"display_name", @"displayName", nil];
    return mapping;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.displayName = [coder decodeObjectForKey:@"displayName"];
        self.fullName = [coder decodeObjectForKey:@"fullName"];
        self.internalName = [coder decodeObjectForKey:@"internalName"];
        self.parentAssociation = [coder decodeObjectForKey:@"parentAssociation"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.displayName forKey:@"displayName"];
    [coder encodeObject:self.fullName forKey:@"fullName"];
    [coder encodeObject:self.internalName forKey:@"internalName"];
    [coder encodeObject:self.parentAssociation forKey:@"parentAssociation"];
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
