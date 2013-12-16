//
//  RestoLegend.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoLegendItem.h"
#import <RestKit/RestKit.h>

@implementation RestoLegendItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RestoLegend for key '%@'>", self.key];
}

+ (RKObjectMapping *)objectMapping
{
    // Create mapping for locations
    RKObjectMapping *legendMapping = [RKObjectMapping mappingForClass:self];
    [legendMapping addAttributeMappingsFromArray:@[@"key", @"value", @"style"]];

    return legendMapping;
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    if (self = [super init]) {
        self.key = [aCoder decodeObjectForKey:@"key"];
        self.value = [aCoder decodeObjectForKey:@"value"];
        self.style = [aCoder decodeObjectForKey:@"style"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.style forKey:@"style"];
}

#pragma mark isEqual and hash implementation

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToRestoLegendItem:other];
}

- (BOOL)isEqualToRestoLegendItem:(RestoLegendItem *)aLegend {
    if (self == aLegend)
        return YES;
    if (![[self key] isEqualToString:[aLegend key]])
        return NO;
    if (![[self value] isEqualToString:[aLegend value]])
        return NO;
    if (![[self style] isEqualToString:[aLegend style]])
        return NO;
    return YES;
}

@end
