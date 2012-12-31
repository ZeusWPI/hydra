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

@interface RestoMapViewController : UIViewController <MKMapViewDelegate>
{
    IBOutlet MKMapView *worldView;
    IBOutlet UIBarButtonItem *returnToInfo;
}

- (IBAction)togglePickerView:(id)sender;
- (IBAction)returnToInfoView:(id)sender;

@end