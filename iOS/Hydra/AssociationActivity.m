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

@synthesize associationId, title, location, date, start, end;

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
    [objectMapping setDateFormatters:[NSArray arrayWithObjects:dayFormatter, timeFormatter, nil]];

    [mappingProvider registerObjectMapping:objectMapping withRootKeyPath:@"activities.activity"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssociationActivity: '%@' by %@>", title, associationId];
}

- (void)setStart:(NSDate *)startTime
{
    // TODO: cleaner solution?
    start = [date dateByAddingHours:[startTime hour]];
    start = [start dateByAddingMinutes:[startTime minute]];
}

- (void)setEnd:(NSDate *)endTime
{
    end = [date dateByAddingHours:[endTime hour]];
    end = [end dateByAddingMinutes:[endTime minute]];
}

- (void)setTitle:(NSString *)newTitle
{
    title = [newTitle stringByStrippingCDATA];
}

- (void)setLocation:(NSString *)newLocation
{
    location = [newLocation stringByStrippingCDATA];
}

@end
