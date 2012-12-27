//
//  RestoMapViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMapViewController.h"

@implementation RestoMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Create Location Manager
        locationManager = [[CLLocationManager alloc] init];
        
        // delegate to self
        [locationManager setDelegate:self];
        
        // set accuracy of location manager
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        // start looking for location now
        [locationManager startUpdatingLocation];
        
    }
    return self;
}

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"%@", newLocation);
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError *)error{
    NSLog(@"Could not find location: %@", error);
}

@end
