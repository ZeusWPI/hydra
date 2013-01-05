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

@interface RestoMapViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSArray *restos;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic) NSInteger selectedRow;

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
    
    self.selectedRow = 0;
    
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
    
    [self.pickerView selectRow:self.selectedRow inComponent:0 animated:NO];
}

- (IBAction)routeToClosestResto:(id)sender
{
    // Check for iOS 6
    Class mapItemClass = [MKMapItem class];
    RestoLocation *closestResto = self.restos[0];
    CLLocationCoordinate2D coordinate = closestResto.coordinate;
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:closestResto.title];
        
        // Set the directions mode to "Walking"
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }else {
        //iOs < 6 use maps.apple.com
        NSString* url = [NSString stringWithFormat: @"http://maps.apple.com/maps?saddr=%f,%f",
                         coordinate.latitude, coordinate.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
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
    
    CLLocation *restoLoc = [[CLLocation alloc] initWithLatitude:resto.coordinate.latitude
                                                      longitude:resto.coordinate.longitude];
    CLLocationDistance restoDist = [worldView.userLocation.location distanceFromLocation:restoLoc];
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
    self.selectedRow = row;
    
    RestoLocation *resto = self.restos[row];
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
        // Check for iOS 6
        Class mapItemClass = [MKMapItem class];
        //iOs 6
        RestoLocation *closestResto = [self.restos objectAtIndex:row];
        CLLocationCoordinate2D coordinate = closestResto.coordinate;
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            // Create an MKMapItem to pass to the Maps app
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                           addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:closestResto.title];
            
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
}

#pragma mark Map delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1000, 1000);
    [worldView setRegion:region animated:YES];

    [self reorderLocations];
}

- (void)reorderLocations
{
    if (!self.pickerView) {
        return;
    }

    // TODO: perhaps cache the distances?
    self.restos = [self.restos sortedArrayUsingComparator: ^(id a, id b) {
        CLLocation *aa = [[CLLocation alloc] initWithLatitude:((RestoLocation*)a).coordinate.latitude
                                                    longitude:((RestoLocation*)a).coordinate.longitude];
        CLLocation *bb = [[CLLocation alloc] initWithLatitude:((RestoLocation*)b).coordinate.latitude
                                                    longitude:((RestoLocation*)b).coordinate.longitude];

        CLLocationDistance aDist = [worldView.userLocation.location distanceFromLocation:aa];
        CLLocationDistance bDist = [worldView.userLocation.location distanceFromLocation:bb];

        return [@(aDist) compare:@(bDist)];
    }];

    [self.pickerView reloadAllComponents];
}

- (void)dismissActionSheet:(id)sender
{
    UIActionSheet *sheet = (UIActionSheet *)[self.pickerView superview];
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
    self.pickerView = nil;
}

- (void)reloadRestos
{
    _restos = [[RestoStore sharedStore] locations];
}
@end
