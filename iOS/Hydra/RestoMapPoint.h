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

@interface RestoMapPoint : NSObject <MKAnnotation>
{
    
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString*)t;

@property(nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic,copy) NSString *title;

@end
