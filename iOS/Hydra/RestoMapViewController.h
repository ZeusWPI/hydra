//
//  RestoMapViewController.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface RestoMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CLLocation *currentLocation;
    NSArray *restos;
    
    IBOutlet MKMapView *worldView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UITableView *tableView;
    IBOutlet UIBarButtonItem *toggleList;
    IBOutlet UIBarButtonItem *closestResto;
}

- (IBAction)toggleTableView:(id)sender;
- (IBAction)routeToClosestResto:(id)sender;

@end