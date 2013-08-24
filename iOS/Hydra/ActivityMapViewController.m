//
//  ActivityMapViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/08/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "ActivityMapViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ActivityMapViewController () <MKMapViewDelegate>

@property (nonatomic, unsafe_unretained) MKMapView *mapView;
@property (nonatomic, unsafe_unretained) UIButton *trackButton;

@property (nonatomic, strong) MKMapItem *activityLocation;

@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, assign) BOOL locationInitialized;

@end

@interface ActivityMapPin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *title;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName;

@end

@implementation ActivityMapViewController

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (ActivityMapViewController*)initWithMapItem:(MKMapItem*)mapItem;
{
    self = [self init];
    self.activityLocation = mapItem;
    return self;
}

- (void)loadView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;

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
    self.title = @"Activiteit";

    // Add button to navigation bar
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(menuButtonTapped:)];
    self.navigationItem.rightBarButtonItem = menuButton;

    // Load map information and set initial map view
    [self resetMapViewRect];

    //Add annotation
    ActivityMapPin *pin = [[ActivityMapPin alloc]initWithCoordinates:self.activityLocation.placemark.coordinate placeName:self.activityLocation.name];
    [self.mapView addAnnotation:pin];
    
    // Only do this after the annotations have been added
    self.mapView.showsUserLocation = YES;
    [self trackUser:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Activiteit Kaart");
}

- (void)dealloc
{
    // Make sure no reference is left
    self.mapView.delegate = nil;
}

- (void)menuButtonTapped:(id)sender
{
    // Use native maps on iOS6 or open Google Maps on iOS5
    if ([self.activityLocation respondsToSelector:@selector(openInMapsWithLaunchOptions:)]) {
        [self.activityLocation openInMapsWithLaunchOptions:nil];
    }
    else {
        NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?ll=%f,%f",
                         self.activityLocation.placemark.coordinate.latitude,
                         self.activityLocation.placemark.coordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }

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
            [self resetMapViewRect];
        }

        self.locationInitialized = YES;
    }
    if (!self.lastLocation || [userLocation.location distanceFromLocation:self.lastLocation] < kUpdateDistance) {
        self.lastLocation = userLocation.location;
        [self resetMapViewRect];
    }
}

- (MKMapRect)mapRectOfInterest
{
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
        } else {
            rect = MKMapRectUnion(rect, pointRect);
        }
    }
   return MKMapRectInset(rect, -kRectOfInterestMargin, -kRectOfInterestMargin);
}

- (void)resetMapViewRect
{
    // Center again arround the venue location
    MKMapRect defaultRect = MKMapRectInset([self mapRectOfInterest], 0,0);

    MKMapRect userRect;
    if ([CLLocationManager locationServicesEnabled]){
        MKMapPoint userPoint = MKMapPointForCoordinate(self.lastLocation.coordinate);
        userRect = MKMapRectMake(userPoint.x, userPoint.y, 0, 0);
        NSLog(@"Userrect is null");
        CLLocationCoordinate2D ghent = CLLocationCoordinate2DMake(51.0500, 3.7333);
        MKMapPoint ghentPoint = MKMapPointForCoordinate(ghent);
        userRect = MKMapRectMake(ghentPoint.x, ghentPoint.y, 2*kRectOfInterestMargin, 2*kRectOfInterestMargin);
    }
    defaultRect = MKMapRectUnion(defaultRect, userRect);
    [self.mapView setVisibleMapRect:defaultRect animated:NO];
}

#pragma mark - Annotations

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    static NSString *pinIdentifier = @"ActivityMapPin";
    MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:@"ActivityMapPin"];
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
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
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
    // iOS < 6 use maps.apple.com
    else {
        CLLocationCoordinate2D user = self.mapView.userLocation.coordinate;
        NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",
                         user.latitude, user.longitude, coordinates.latitude, coordinates.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
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
    NSLog(@"%@ tracking user",track?@"Start":@"Stop");
    if ([self.mapView respondsToSelector:@selector(setUserTrackingMode:)]) {
        MKUserTrackingMode newMode = track ? MKUserTrackingModeFollow : MKUserTrackingModeNone;
        [self.mapView setUserTrackingMode:newMode animated:YES];
        self.trackButton.selected = track;
    }
    // if you stop tracking reset map
    if (!track){
        [self resetMapViewRect];
    }
}

@end

@implementation ActivityMapPin

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName {
    self = [super init];
    if (self != nil) {
        _coordinate = location;
        _title = placeName;
    }
    return self;
}

@end
