//
//  Assocation.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "Association.h"
#import "NSDate+Utilities.h"

@implementation Association

@synthesize displayName, fullName, internalName;

+ (NSArray *)updateAssociations:(NSArray *)associations lastModified:(NSDate *)date
{
    if (!associations || [self updateRequired:date]) {
        associations = [self loadFromPlist];
    }
    return associations;
}

+ (NSString *)initializationPath
{
    return [[NSBundle mainBundle] pathForResource:@"Associations" ofType:@"plist"];
}

+ (BOOL)updateRequired:(NSDate *)currentVersion
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [self initializationPath];
    
    NSDictionary *attributes = [manager attributesOfItemAtPath:filePath error:nil];
    NSDate *lastUpdated = [attributes objectForKey:NSFileModificationDate];
    return (!currentVersion || [lastUpdated isLaterThanDate:currentVersion]);
}

+ (NSArray *)loadFromPlist
{
    NSArray *bundled = [NSArray arrayWithContentsOfFile:[self initializationPath]];
    NSMutableArray *associations = [[NSMutableArray alloc] initWithCapacity:[bundled count]];
    for (NSUInteger i = 0; i < [bundled count]; i++) {
        NSDictionary *props = [bundled objectAtIndex:i];

        Association *assoc = [[Association alloc] init];
        [assoc setDisplayName:[props objectForKey:@"displayName"]];
        [assoc setFullName:[props objectForKey:@"fullName"]];
        [assoc setInternalName:[props objectForKey:@"internalName"]];

        [associations insertObject:assoc atIndex:i];
    }
    return associations;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Association: %@>", displayName];
}

- (NSUInteger)hash
{
    return [[self internalName] hash];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[self class]] && [internalName isEqual:[object internalName]];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
