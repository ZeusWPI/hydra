//
//  RestoMapViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMapViewController.h"
#import "RestoLocation.h"
#import "RestoStore.h"

#define kUpdateDistance 100.0
@interface RestoMapViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSArray *restos;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) RestoLocation *selectedResto;
@property (nonatomic, strong) MKUserLocation *prevLocation;
@property (nonatomic, strong) NSMutableDictionary *distances;

@end

@implementation RestoMapViewController

#pragma mark Setting up the view & viewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Add restos to map
    [self reloadRestos];
    [worldView addAnnotations:self.restos];

    // Check for updates
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(reloadRestos) name:RestoStoreDidUpdateInfoNotification
                 object:nil];
    
    self.selectedResto = self.restos[0];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma Buttons

- (IBAction)togglePickerView:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    // Create pickerView
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [actionSheet addSubview:self.pickerView];

    // Update PickerView contents
    [self reorderLocations];

    // Create toolbar
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Gereed" style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(dismissActionSheet:)];
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.tintColor = [UIColor hydraTintColor];
    pickerToolbar.items = @[flexSpace, doneBtn];
    [actionSheet addSubview:pickerToolbar];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 320, 22)];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.text = @"Restos";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = UITextAlignmentCenter;
    title.shadowColor = [UIColor blackColor];
    title.shadowOffset = CGSizeMake(1, 1);
    title.backgroundColor = [UIColor clearColor];
    [actionSheet addSubview:title];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 500)];

    NSInteger row = [self.restos indexOfObject:self.selectedResto];
    row = row == NSNotFound? 0 : row;
    [self.pickerView selectRow:row inComponent:0 animated:NO];
}

- (IBAction)routeToClosestResto:(id)sender
{
    [self openMapWithRestoLocation:self.restos[0]];
}

- (IBAction)returnToInfoView:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Pickerview delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.restos.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *title = nil, *distance = nil;
    if (!view) {
        // Location name
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:15];

        // Distance to location
        distance = [[UILabel alloc] initWithFrame:title.bounds];
        distance.textAlignment = UITextAlignmentRight;
        distance.backgroundColor = [UIColor clearColor];
        distance.font = [UIFont systemFontOfSize:13];
        [title addSubview:distance];
    }
    else {
        title = (UILabel *)view;
        distance = (UILabel *)title.subviews[0];
    }

    RestoLocation *resto = self.restos[row];
    title.text = resto.title;

    CLLocationDistance restoDist = [self.distances[resto.title] doubleValue];
    if (restoDist < 2000) {
        distance.text = [NSString stringWithFormat:@"%.0f m", restoDist];
    }
    else {
        distance.text = [NSString stringWithFormat:@"%.1f km", restoDist/1000];
    }

    return title;
}

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{    
    RestoLocation *resto = self.restos[row];
    self.selectedResto = resto;

    [self setRegionFromUserToResto:resto];
}

- (void)setRegionFromUserToResto:(RestoLocation*)resto
{
    CLLocationCoordinate2D userLocation = worldView.userLocation.coordinate;

    // Top right corner
    CLLocationCoordinate2D topRightCoor = CLLocationCoordinate2DMake(
        fmax(resto.coordinate.latitude, userLocation.latitude),
        fmax(resto.coordinate.longitude, userLocation.longitude));
    MKMapPoint mtr = MKMapPointForCoordinate(topRightCoor);

    // Top left corner
    CLLocationCoordinate2D botLeftCoor = CLLocationCoordinate2DMake(
        fmin(resto.coordinate.latitude, userLocation.latitude),
        fmin(resto.coordinate.longitude, userLocation.longitude));
    MKMapPoint mbl = MKMapPointForCoordinate(botLeftCoor);

    // Map
    MKMapRect mapRect = MKMapRectMake(fmin(mtr.x, mbl.x), fmin(mtr.y, mbl.y), fabs(mtr.x-mbl.x)*1.2, fabs(mtr.y-mbl.y)*1.2);
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    [worldView setRegion:region animated:YES];
}

- (void)routeToSelectedResto
{
    if (self.pickerView != nil){
        NSInteger row = [self.pickerView selectedRowInComponent:0];
        RestoLocation *selResto = [self.restos objectAtIndex:row];
        [self openMapWithRestoLocation:selResto];
    }
}

- (void)openMapWithRestoLocation:(RestoLocation*)resto
{
    // Check for iOS 6
    Class mapItemClass = [MKMapItem class];
    //iOs 6
    CLLocationCoordinate2D coordinate = resto.coordinate;
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:resto.title];

        // Set the directions mode to "Walking"
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }else{
        //iOs < 6 use maps.apple.com
        NSString* url = [NSString stringWithFormat: @"http://maps.apple.com/maps?saddr=%f,%f",
                         coordinate.latitude, coordinate.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}
#pragma mark Map delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation 
{
    if ((self.prevLocation == nil) || [userLocation.location distanceFromLocation:self.prevLocation.location] > kUpdateDistance){
        self.prevLocation = userLocation;
        [self recalculateDistances];
        [self reorderLocations];
        [self setRegionFromUserToResto:self.selectedResto];
    }
}

- (void)reorderLocations
{
    if (!self.pickerView) {
        return;
    }

    self.restos = [self.restos sortedArrayUsingComparator: ^(id a, id b) {

        double aDist = [self.distances[((RestoLocation*)a).title] doubleValue];
        double bDist = [self.distances[((RestoLocation*)b).title] doubleValue];

        return [@(aDist) compare:@(bDist)];
    }];

    [self.pickerView reloadAllComponents];
}

- (void)recalculateDistances
{
    NSMutableDictionary* distances = [[NSMutableDictionary alloc] initWithCapacity:self.restos.count];
    for (RestoLocation* resto in self.restos) {
        CLLocation *restoLoc = [[CLLocation alloc] initWithLatitude:resto.coordinate.latitude
                                                    longitude:resto.coordinate.longitude];
        distances[resto.title] = [NSNumber numberWithDouble:[worldView.userLocation.location distanceFromLocation:restoLoc]];
    }
    self.distances = distances;
}

- (void)dismissActionSheet:(id)sender
{
    UIActionSheet *sheet = (UIActionSheet *)[self.pickerView superview];
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
    self.pickerView = nil;
}

- (void)reloadRestos
{
    self.restos = [RestoStore sharedStore].locations;
    [self recalculateDistances];
    [self reorderLocations];
}
@end
