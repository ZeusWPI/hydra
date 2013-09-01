//
//  RestoMapPoint.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoLocation.h"
#import <RestKit/RestKit.h>

@interface RestoLocation ()

@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@end

@implementation RestoLocation

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.address = [coder decodeObjectForKey:@"address"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.longitude = [coder decodeDoubleForKey:@"longitude"];
        self.latitude = [coder decodeDoubleForKey:@"latitude"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<RestoLocation '%@'>", self.name];
}

+ (RKObjectMapping *)objectMapping
{
    // Create mapping for locations
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:self];
    [locationMapping addAttributeMappingsFromArray:@[@"name", @"address", @"type", @"longitude", @"latitude"]];

    return locationMapping;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeDouble:self.longitude forKey:@"longitude"];
    [coder encodeDouble:self.latitude forKey:@"latitude"];
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
    if (![self.name isEqualToString:aPoint.name])
        return NO;
    if (self.longitude != aPoint.longitude)
        return NO;
    if (self.latitude != aPoint.latitude)
        return NO;
    return YES;
}

@end
