//
//  RestoMapPoint.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoLocation.h"
#import <RestKit/RestKit.h>

#define kCoordinateScaleFactor 1000000.0

@interface RestoLocation ()

@property (nonatomic, assign) NSInteger latitude;
@property (nonatomic, assign) NSInteger longitude;

@end

@implementation RestoLocation

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.address = [coder decodeObjectForKey:@"address"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.longitude = [coder decodeIntegerForKey:@"longitude"];
        self.latitude = [coder decodeIntegerForKey:@"latitude"];
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
    [locationMapping mapAttributes:@"name", @"address", @"type", @"longitude", @"latitude", nil];

    // Register mapping
    [mappingProvider setObjectMapping:locationMapping forKeyPath:@"locations"];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeInteger:self.longitude forKey:@"longitude"];
    [coder encodeInteger:self.latitude forKey:@"latitude"];
}

#pragma mark MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude/kCoordinateScaleFactor, self.longitude/kCoordinateScaleFactor);
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
    if (![self.name isEqualToString:aPoint.name])
        return NO;
    if (self.longitude != aPoint.longitude)
        return NO;
    if (self.latitude != aPoint.latitude)
        return NO;
    return YES;
}

@end
