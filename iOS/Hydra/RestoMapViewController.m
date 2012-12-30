//
//  RestoMapViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMapViewController.h"
#import "RestoMapPoint.h"

@implementation RestoMapViewController

- (NSArray*)generateRestoList
{
    RestoMapPoint *astrid = [[RestoMapPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(51.026952, 3.712086) andTitle:@"Resto Astrid"];

    RestoMapPoint *brug = [[RestoMapPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(51.045613, 3.727147) andTitle:@"Resto De Brug"];
    
    RestoMapPoint *coupure = [[RestoMapPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(51.053252, 3.707671) andTitle:@"Resto Coupure"];
    
    return [[NSArray alloc] initWithObjects:brug, coupure, astrid,nil];
}

#pragma mark Setting up the view & viewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Resto kaart";

    // Add restos to map
    restos = [self generateRestoList];
    [self addRestosToMap];



    // Check for updates
   /* NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(locationsUpdated:)
                   name:RestoStoreDidReceiveLocationNotification
                 object:nil];//*/
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma mark Buttons
- (IBAction)togglePickerView:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    // Create datepicker
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [actionSheet addSubview:pickerView];
        
    // Create toolbar
    UIBarButtonItem *closestResto = [[UIBarButtonItem alloc] initWithTitle:@"Route" style:UIBarButtonItemStyleBordered target:self action:@selector(routeToSelectedResto)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Gereed" style:UIBarButtonItemStyleDone
                                                               target:self action:@selector(dismissActionSheet:)];
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.tintColor = [UIColor hydraTintColor];
    pickerToolbar.items = @[closestResto, flexSpace, doneBtn];
    [actionSheet addSubview:pickerToolbar];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 250, 22)];
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
}

- (IBAction)routeToClosestResto:(id)sender
{
    // TODO implement route to closest resto
    // Check for iOS 6
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        RestoMapPoint *closestResto = [restos objectAtIndex:0];
        CLLocationCoordinate2D coordinate = closestResto.coordinate;
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
    }
}

- (IBAction)returnToInfoView:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Pickerview DataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return restos.count;
}

#pragma mark Pickerview delegate methods
#define kRestoLabelWidth 200
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //if (view == nil){
      //  view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 20)];
    //}
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
    RestoMapPoint *resto = [restos objectAtIndex:row];
    // resto naam label
    UILabel *restoNaam = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kRestoLabelWidth, 20)];
    [restoNaam setTextAlignment:UITextAlignmentLeft];
    [restoNaam setBackgroundColor:[UIColor clearColor]];
    [restoNaam setFont:[UIFont boldSystemFontOfSize:15]];
    [restoNaam setText:resto.title];
    [view addSubview:restoNaam];
    
    // resto afstand label
    UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(kRestoLabelWidth, 0, 280-kRestoLabelWidth, 20)];
    [distance setTextAlignment:UITextAlignmentLeft];
    [distance setBackgroundColor:[UIColor clearColor]];
    [distance setFont:[UIFont systemFontOfSize:13]];
    CLLocation *restoLoc = [[CLLocation alloc]initWithLatitude:resto.coordinate.latitude longitude:resto.coordinate.longitude];
    CLLocationDistance restoDist = [currentLocation distanceFromLocation:restoLoc];
    NSString *text;
    if(restoDist < 5000){
        text = [NSString stringWithFormat:@"%.0f m", restoDist];
    }else {
        text = [NSString stringWithFormat:@"%.1f km", restoDist/1000];
    }
    [distance setText:text];
    [view addSubview:distance];
    
    return view;
}

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //TODO get users location and selected resto on the map, zoom out if needed
    RestoMapPoint *resto = [restos objectAtIndex:row];
    
    //top rightCoordinate
    CLLocationCoordinate2D topRightCoor = CLLocationCoordinate2DMake(fmax(resto.coordinate.latitude, currentLocation.coordinate.latitude), fmax(resto.coordinate.longitude, currentLocation.coordinate.longitude));
    MKMapPoint mtr = MKMapPointForCoordinate(topRightCoor);
    
    //bottom left corner
    CLLocationCoordinate2D botLeftCoor = CLLocationCoordinate2DMake(fmin(resto.coordinate.latitude, currentLocation.coordinate.latitude), fmin(resto.coordinate.longitude, currentLocation.coordinate.longitude));
    MKMapPoint mbl = MKMapPointForCoordinate(botLeftCoor);

    //Map
    MKMapRect mapRect = MKMapRectMake(fmin(mtr.x, mbl.x), fmin(mtr.y, mbl.y), fabs(mtr.x-mbl.x)*1.2, fabs(mtr.y-mbl.y)*1.2);
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    [worldView setRegion:region animated:YES];
}

- (void)routeToSelectedResto
{
    if (pickerView != nil){
        NSInteger row = [pickerView selectedRowInComponent:0];
        // Check for iOS 6
        Class mapItemClass = [MKMapItem class];
        //iOs 6
        RestoMapPoint *closestResto = [restos objectAtIndex:row];
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
            //iOs < 6 use maps.apple.com?
        }
    }
}

#pragma mark Map delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1000, 1000);
    [worldView setRegion:region animated:YES];

    currentLocation = userLocation.location;
    [self sortRestos];
}

- (void)addRestosToMap
{
    [worldView addAnnotations:restos];
}

- (void)sortRestos
{
    restos = [restos sortedArrayUsingComparator: ^(id a, id b) {
        if (![a isKindOfClass:[RestoMapPoint class]] && ![b isKindOfClass:[RestoMapPoint class]]){
            return (NSComparisonResult)NSOrderedSame;
        }
        
        CLLocation *aa = [[CLLocation alloc]initWithLatitude:((RestoMapPoint*)a).coordinate.latitude longitude:((RestoMapPoint*)a).coordinate.longitude];
        CLLocation *bb = [[CLLocation alloc]initWithLatitude:((RestoMapPoint*)b).coordinate.latitude longitude:((RestoMapPoint*)b).coordinate.longitude];
        
        CLLocationDistance aDist = [currentLocation distanceFromLocation:aa];
        CLLocationDistance bDist = [currentLocation distanceFromLocation:bb];
        DLog(@"Distance a: %f and distance b: %f", aDist, bDist);
        if(aDist < bDist){
            return (NSComparisonResult)NSOrderedAscending;
        }else if (aDist > bDist){
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    [pickerView reloadAllComponents];
}

- (void)dismissActionSheet:(id)sender
{
    UIActionSheet *sheet = (UIActionSheet *)[pickerView superview];
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
    pickerView = nil;
}
@end
