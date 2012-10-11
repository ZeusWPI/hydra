//
//  AssociationActivity.m
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AssociationActivity.h"
#import <RestKit/RestKit.h>
#import "NSString+Utilities.h"
#import "NSDate+Utilities.h"

@implementation AssociationActivity

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider
{
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:self];
    [objectMapping mapAttributes:@"title", @"location", @"date", nil];
    [objectMapping mapKeyPathsToAttributes:@"from", @"start",
        @"to", @"end", @"association_id", @"associationId", nil];

    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"H:m"];
    [objectMapping setDateFormatters:@[ dayFormatter, timeFormatter ]];

    [mappingProvider registerObjectMapping:objectMapping withRootKeyPath:@"activities.activity"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssociationActivity: '%@' by %@>", self.title, self.associationId];
}

- (void)setStart:(NSDate *)startTime
{
    _start = [self.date dateByAddingTimeInterval:[startTime timeIntervalSince1970]];
}

- (void)setEnd:(NSDate *)endTime
{
    _end = [self.date dateByAddingTimeInterval:[endTime timeIntervalSince1970]];
    if ([self.end isEarlierThanDate:self.start]) {
        _end = [self.end dateByAddingDays:1];
    }
}

- (void)setTitle:(NSString *)newTitle
{
    _title = [newTitle stringByStrippingCDATA];
}

- (void)setLocation:(NSString *)newLocation
{
    _location = [newLocation stringByStrippingCDATA];
}

@end
