//
//  MapViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 27/08/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

@property (nonatomic, unsafe_unretained) MKMapView *mapView;

- (void)trackUser:(BOOL)track;
- (void)loadMapItems;

@end
