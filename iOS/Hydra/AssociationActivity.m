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
#import "NSString+Utilities.h"
#import "NSDate+Utilities.h"

@interface AssociationActivity ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) Association *association;

@end

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
    [objectMapping setDateFormatters:@[ timeFormatter, dayFormatter ]];

    [mappingProvider registerObjectMapping:objectMapping withRootKeyPath:@"activity"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AssociationActivity: '%@' by %@>", self.title, self.associationId];
}

- (void)setStart:(NSDate *)startTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    _start = [calendar dateByAddingComponents:startTime.timeComponents toDate:self.date options:0];
}

- (void)setEnd:(NSDate *)endTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    _end = [calendar dateByAddingComponents:endTime.timeComponents toDate:self.date options:0];
    if ([self.end isEarlierThanDate:self.start]) {
        _end = [self.end dateByAddingDays:1];
    }
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
        self.location = [coder decodeObjectForKey:@"location"];
        _start = [coder decodeObjectForKey:@"start"];
        _end = [coder decodeObjectForKey:@"end"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.associationId forKey:@"associationId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.start forKey:@"start"];
    [coder encodeObject:self.end forKey:@"end"];
}

@end
