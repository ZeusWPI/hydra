//
//  MapViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 27/08/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "MapViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, unsafe_unretained) UIButton *trackButton;
@property (nonatomic, assign) BOOL locationInitialized;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *previousLocation;

@end

@implementation MapViewController

- (void)loadView
{
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect bounds = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;

    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // Map view
    CGRect mapFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:mapFrame];
    mapView.autoresizingMask = self.view.autoresizingMask;
    mapView.delegate = self;

    [self.view addSubview:mapView];
    self.mapView = mapView;

    // Tracking button
    UIButton *trackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    trackButton.frame = CGRectMake(bounds.size.width - 50, bounds.size.height - 40, 42, 34);
    trackButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    trackButton.hidden = ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized);
    [trackButton setBackgroundImage:[UIImage imageNamed:@"button-track"]
                           forState:UIControlStateNormal];
    [trackButton setBackgroundImage:[UIImage imageNamed:@"button-track-highlighted"]
                           forState:UIControlStateHighlighted];
    [trackButton setBackgroundImage:[UIImage imageNamed:@"button-track-selected"]
                           forState:UIControlStateSelected];
    [trackButton setBackgroundImage:[UIImage imageNamed:@"button-track-selected-highlighted"]
                           forState:UIControlStateSelected|UIControlStateHighlighted];
    [trackButton addTarget:self action:@selector(trackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:trackButton];
    self.trackButton = trackButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load map information and set initial map view
    [self loadMapItems];
    [self resetMapViewRect];

    // Only do this after the annotations have been added
    self.mapView.showsUserLocation = YES;
    //[self trackUser:YES];
}

- (void)dealloc
{
    // Make sure no reference is left
    self.mapView.delegate = nil;
}

- (void)loadMapItems
{
    // Should be overriden in subclasses
}

- (void)mapLocationUpdated
{
    // Should be overriden in subclasses
}

#pragma mark - MapView delegate

#define kUpdateDistance 50.0
#define kRectOfInterestMargin 2000.0

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // Ignore old timestamps
    if (!userLocation.location) {
        return;
    }

    // Location updates are enabled, show the tracking button
    self.trackButton.hidden = NO;

    // Default to user tracking when the user is a relevant area
    if (!self.locationInitialized) {
        MKMapPoint userPoint = MKMapPointForCoordinate(userLocation.coordinate);
        MKMapRect regionOfInterest = [self mapRectOfInterest];
        if (!MKMapRectContainsPoint(regionOfInterest, userPoint)) {
            [self trackUser:NO];
        }
        else {
            [self trackUser:YES];
        }

        self.locationInitialized = YES;
    }
    
    if ([self shouldUpdateLocation:userLocation.location withPreviousLocation:self.previousLocation]) {
        [self mapLocationUpdated];
        self.previousLocation = userLocation.location;
    }
}

- (MKMapRect)mapRectOfInterest
{
    // TODO: allow the mapRectOfInterest to also contain the user's position

    MKMapRect rect = MKMapRectNull;
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        // Because we decide to track on the distance of the user location
        if ([annotation isKindOfClass:[MKUserLocation class]]){
            continue;
        }
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(rect)) {
            rect = pointRect;
        }
        else {
            rect = MKMapRectUnion(rect, pointRect);
        }
    }
   return MKMapRectInset(rect, -kRectOfInterestMargin, -kRectOfInterestMargin);
}

- (void)resetMapViewRect
{
    MKMapRect defaultRect = [self mapRectOfInterest];
    [self.mapView setVisibleMapRect:defaultRect animated:NO];
}

- (BOOL)shouldUpdateLocation:(CLLocation *)userLocation withPreviousLocation:(CLLocation *)previousLocation
{
    if (!previousLocation) {
        return YES;
    }
    
    CLLocationDistance distance = [previousLocation distanceFromLocation:userLocation];
    if (distance > kUpdateDistance) {
        return YES;
    }
    
    return NO;
}
#pragma mark - Annotations

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    static NSString *pinIdentifier = @"MapViewControllerPin";
    MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:@"MapViewControllerPin"];
        view.canShowCallout = YES;

        UIButton *routeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        routeButton.frame = CGRectMake(0, 0, 24, 24);
        [routeButton setImage:[UIImage imageNamed:@"button-route"] forState:UIControlStateNormal];
        [routeButton addTarget:self action:@selector(routeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        view.leftCalloutAccessoryView = routeButton;
    }
    return view;
}

- (void)routeButtonTapped:(UIButton *)sender
{
    // Find annotationview in view hierarchy
    UIView *view = sender;
    while (![view isKindOfClass:[MKAnnotationView class]]) {
        view = view.superview;
    }

    id<MKAnnotation> annotation = [(MKAnnotationView *)view annotation];
    CLLocationCoordinate2D coordinates = [annotation coordinate];

    // Check for iOS 6
    Class mapItemClass = [MKMapItem class];
    // Create an MKMapItem to pass to the Maps app
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinates
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:annotation.title];

    // Route between the current location and the mapitem
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                   launchOptions:@{
      MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking
    }];
}

#pragma mark - User tracking

- (void)trackButtonTapped:(UIButton *)sender
{
    BOOL currentlyTracking = (self.mapView.userTrackingMode != MKUserTrackingModeNone);
    [self trackUser:!currentlyTracking];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    self.trackButton.selected = (mode != MKUserTrackingModeNone);
}

- (void)trackUser:(BOOL)track
{
    MKUserTrackingMode newMode = track ? MKUserTrackingModeFollow : MKUserTrackingModeNone;
    [self.mapView setUserTrackingMode:newMode animated:YES];
    self.trackButton.selected = track;
}

@end
