//
//  Assocation.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "Association.h"
#import "NSDate+Utilities.h"

NSString *const AssociationsLastUpdatedPref = @"AssociationsLastUpdated";

@implementation Association

+ (NSArray *)updateAssociations:(NSArray *)associations
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

+ (NSArray *)loadFromPlist
{
    NSArray *bundled = [NSArray arrayWithContentsOfFile:[self initializationPath]];
    NSMutableArray *associations = [[NSMutableArray alloc] initWithCapacity:[bundled count]];
    for (NSUInteger i = 0; i < [bundled count]; i++) {
        NSDictionary *props = bundled[i];

        Association *assoc = [[Association alloc] init];
        assoc.displayName = props[@"displayName"];
        assoc.fullName = props[@"fullName"];
        assoc.internalName = props[@"internalName"];

        [associations insertObject:assoc atIndex:i];
    }
    return associations;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Association: %@>", self.displayName];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.displayName = [coder decodeObjectForKey:@"displayName"];
        self.fullName = [coder decodeObjectForKey:@"fullName"];
        self.internalName = [coder decodeObjectForKey:@"internalName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.displayName forKey:@"displayName"];
    [coder encodeObject:self.fullName forKey:@"fullName"];
    [coder encodeObject:self.internalName forKey:@"internalName"];
}

#pragma mark - NSCopying

- (NSUInteger)hash
{
    return [[self internalName] hash];
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
