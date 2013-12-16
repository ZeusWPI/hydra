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

@class RKObjectMapping;

@interface RestoLocation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (RKObjectMapping *)objectMapping;

- (NSString *)title;

@end
