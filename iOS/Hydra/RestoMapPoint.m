//
//  RestoMapPoint.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMapPoint.h"
#import <RestKit/RestKit.h>

@implementation RestoMapPoint

@synthesize coordinate, title;

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;
{
    // Create mapping for locations
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:self];
    //[locationMapping setForceCollectionMapping:YES];
    [locationMapping mapKeyPath:@"name" toAttribute:@"title"];
    [locationMapping mapKeyPath:@"address" toAttribute:@"address"];
    [locationMapping mapKeyPath:@"latitude" toAttribute:@"latitude"];
    [locationMapping mapKeyPath:@"longitude" toAttribute:@"longitude"];
    
    // Register mapping
    [mappingProvider setObjectMapping:locationMapping forKeyPath:@"locations"];
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)t
{
    self = [super init];
    if(self){
        coordinate = c;
        [self setTitle:t];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        double longitude = [coder decodeDoubleForKey:@"longitude"];
        double latitude = [coder decodeDoubleForKey:@"latitude"];
        self.coordinate = CLLocationCoordinate2DMake(longitude, latitude);
        self.title = [coder decodeObjectForKey:@"title"];
        self.address = [coder decodeObjectForKey:@"address"];
    }
    return self;
}

- (id)init
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(51.3, 3.42) andTitle:@"Gent Centrum"];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    [coder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.address forKey:@"address"];
}
#pragma mark isEqual and hash implementation
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToRestoMapPoint:other];
}

- (BOOL)isEqualToRestoMapPoint:(RestoMapPoint *)aPoint {
    if (self == aPoint)
        return YES;
    if (![[self title] isEqualToString:[aPoint title]])
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
