//
//  RestoMapPoint.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class RKObjectMappingProvider;

@interface RestoLocation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, assign) NSInteger latitude;
@property (nonatomic, assign) NSInteger longitude;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;

- (id) initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString*)t;
+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;

@end
