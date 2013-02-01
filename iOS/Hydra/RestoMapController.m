//
//  RestoMapController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMapController.h"
#import "RestoMenuController.h"
#import "RestoLocation.h"
#import "RestoStore.h"
#import "UINavigationController+ReplaceController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface RestoMapController () <MKMapViewDelegate, UISearchDisplayDelegate,
    UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, unsafe_unretained) MKMapView *mapView;
@property (nonatomic, unsafe_unretained) UIButton *trackButton;

@property (nonatomic, strong) NSArray *mapItems;
@property (nonatomic, strong) NSArray *filteredMapItems;
@property (nonatomic, strong) NSMutableDictionary *distances;

@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, assign) BOOL locationInitialized;

@end

@implementation RestoMapController

#pragma mark Setting up the view & viewcontroller

- (id)init
{
    if (self = [super init]) {
        // Register for updates
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(reloadData)
                       name:RestoStoreDidUpdateInfoNotification object:nil];
    }
    return self;
}

- (void)loadView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth
                               | UIViewAutoresizingFlexibleHeight;

    // Search field
    CGRect searchBarFrame = CGRectMake(0, 0, bounds.size.width, 44);
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    searchBar.placeholder = @"Zoek een resto";
    [self.view addSubview:searchBar];

    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                              contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;

    // Performance hack: already load the tableview
    [self.view addSubview:self.searchController.searchResultsTableView];

    // Map view
    CGRect mapFrame = CGRectMake(0, 44, bounds.size.width, bounds.size.height - 44);
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
    self.title = @"Resto Kaart";

    // Add button to navigation bar
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(menuButtonTapped:)];
    self.navigationItem.rightBarButtonItem = menuButton;

    // Load map information and set initial map view
    [self reloadMapItems];
    [self resetMapViewRect];

    // Only do this after the annotations have been added
    self.mapView.showsUserLocation = YES;
    [self trackUser:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Resto Kaart");
}

- (void)dealloc
{
    // Make sure no reference is left
    self.mapView.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)menuButtonTapped:(id)sender
{
    RestoMenuController *menuController = [[RestoMenuController alloc] init];
    [self.navigationController H_replaceViewControllerWith:menuController
                                                   options:UIViewAnimationOptionTransitionFlipFromLeft];
}

#pragma mark - Data

- (void)reloadMapItems
{
    [self.mapView removeAnnotations:self.mapItems];
    self.mapItems = [RestoStore sharedStore].locations;
    [self.mapView addAnnotations:self.mapItems];

    [self filterMapItems];
}

- (void)calculateDistances
{
    CLLocation *user = self.mapView.userLocation.location;
    NSMutableDictionary *distances = [NSMutableDictionary dictionaryWithCapacity:self.mapItems.count];
    for (RestoLocation *resto in self.mapItems) {
        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:resto.coordinate.latitude
                                                           longitude:resto.coordinate.longitude];
        CLLocationDistance distance = [user distanceFromLocation:coordinate];
        distances[resto.title] = @(distance);
    }
    self.distances = distances;

    [self reorderMapItems];
}

- (void)filterMapItems
{
    NSString *searchString = self.searchController.searchBar.text;
    if (searchString.length == 0) {
        self.filteredMapItems = self.mapItems;
    }
    else {
        NSMutableArray *filteredItems = [[NSMutableArray alloc] init];
        for (RestoLocation *resto in self.mapItems) {
            NSRange r = [resto.title rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if (r.location != NSNotFound) {
                [filteredItems addObject:resto];
            }
        }
        self.filteredMapItems = filteredItems;
    }

    [self reorderMapItems];
}

- (void)reorderMapItems
{
    self.filteredMapItems = [self.filteredMapItems sortedArrayUsingComparator:^(id a, id b) {
        NSNumber *distA = self.distances[[a title]];
        NSNumber *distB = self.distances[[b title]];
        return [distA compare:distB];
    }];
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

    if (!self.searchController.active) return;
    if (self.lastLocation && [userLocation.location distanceFromLocation:self.lastLocation] < kUpdateDistance) {
        [self calculateDistances];
        self.lastLocation = userLocation.location;
    }
}

- (MKMapRect)mapRectOfInterest
{
    MKMapRect rect = MKMapRectNull;
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
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
    // Hardcoded rectangle for the central resto's
    MKMapRect defaultRect = MKMapRectMake(13.6974e+7, 8.9796e+7, 30e3, 45e3);
    [self.mapView setVisibleMapRect:defaultRect animated:NO];
}

#pragma mark - Annotations

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    static NSString *pinIdentifier = @"RestoMapPin";
    MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:@"RestoMapPin"];
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
    if ([self.mapView respondsToSelector:@selector(setUserTrackingMode:)]) {
        MKUserTrackingMode newMode = track ? MKUserTrackingModeFollow : MKUserTrackingModeNone;
        [self.mapView setUserTrackingMode:newMode animated:YES];
        self.trackButton.selected = track;
    }
}

#pragma mark - SearchController delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    // Just by accessing the property here, the searchResultsTableView will
    // be initialized with the correct frame. Crazy shit.
    [controller searchResultsTableView];

    // After this method the searchcontroller will start its animation, which we
    // want in on so we execute our hook in the next run loop.
    dispatch_async(dispatch_get_main_queue(), ^{
        [controller.searchResultsTableView.layer removeAllAnimations];
        [self.view addSubview:controller.searchResultsTableView];

        // Smooth appearance
        controller.searchResultsTableView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            controller.searchResultsTableView.alpha = 1;
        }];
    });

    [self calculateDistances];
    [self filterMapItems];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    // Prevent results from disappearing
    [self.view addSubview:controller.searchResultsTableView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterMapItems];
    return YES;
}

#pragma mark - SearchController tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredMapItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RestoMapViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }

    RestoLocation *resto = self.filteredMapItems[indexPath.row];
    cell.textLabel.text = resto.name;

    double distance = [self.distances[resto.name] doubleValue];
    if (distance == 0) {
        cell.detailTextLabel.text = @"";
    }
    else if (distance < 2000) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f m", distance];
    }
    else {
        distance /= 1000;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f km", distance];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Keep the search string
    NSString *search = self.searchDisplayController.searchBar.text;
    [self.searchDisplayController setActive:NO animated:YES];
    self.searchDisplayController.searchBar.text = search;

    // Highlight the selected item
    RestoLocation *selected = self.filteredMapItems[indexPath.row];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.012, 0.012);
    MKCoordinateRegion region = MKCoordinateRegionMake(selected.coordinate, span);
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:selected animated:YES];
}

@end
