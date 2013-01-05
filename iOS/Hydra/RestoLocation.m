//
//  RestoMapPoint.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoLocation.h"
#import <RestKit/RestKit.h>

@implementation RestoLocation

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t
{
    self = [super init];
    if(self){
        self.longitude = c.longitude;
        self.latitude = c.latitude;
        self.name = t;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.longitude = [coder decodeDoubleForKey:@"longitude"];
        self.latitude = [coder decodeDoubleForKey:@"latitude"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.address = [coder decodeObjectForKey:@"address"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RestoLocation '%@'>", self.name];
}

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;
{
    // Create mapping for locations
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:self];
    [locationMapping mapAttributes:@"name", @"address", @"longitude", @"latitude", nil];

    // Register mapping
    [mappingProvider setObjectMapping:locationMapping forKeyPath:@"locations"];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:self.longitude forKey:@"longitude"];
    [coder encodeDouble:self.latitude forKey:@"latitude"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.address forKey:@"address"];
}

#pragma mark MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (NSString *)title
{
    return self.name;
}

#pragma mark isEqual and hash implementation

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToRestoLocation:other];
}

- (BOOL)isEqualToRestoLocation:(RestoLocation *)aPoint {
    if (self == aPoint)
        return YES;
    if (![[self name] isEqualToString:[aPoint name]])
        return NO;
    if (![[self address] isEqualToString:[aPoint address]])
        return NO;
    double epsilon = 0.000001;
    if (!(fabs([self coordinate].latitude - [aPoint coordinate].latitude) <= epsilon &&
          fabs([self coordinate].longitude - [aPoint coordinate].longitude) <= epsilon))
        return NO;
    return YES;
}

@end
