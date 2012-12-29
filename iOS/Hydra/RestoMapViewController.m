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

    // Ahow location on map
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(51.053889, 3.705);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1500, 1500);
    [worldView setRegion:region animated:NO];
    [worldView setShowsUserLocation:YES];

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
    if ([pickerView isHidden]){
        // is hidden, show table
        [pickerView setHidden:NO];
        CGRect mapFrame = [worldView frame];
        CGRect tableFrame = [pickerView frame];
        
        CGRect newMapFrame = CGRectMake(mapFrame.origin.x, mapFrame.origin.y, mapFrame.size.width, mapFrame.size.height-tableFrame.size.height);
        [worldView setFrame:newMapFrame];
        
    }else {
        // is shown, hide table
        CGRect mapFrame = [worldView frame];
        CGRect tableFrame = [pickerView frame];
        
        CGRect newMapFrame = CGRectMake(mapFrame.origin.x, mapFrame.origin.y, mapFrame.size.width, mapFrame.size.height+tableFrame.size.height);
        [worldView setFrame:newMapFrame];
        [pickerView setHidden:YES];
    }
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
@end
