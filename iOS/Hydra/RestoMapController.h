//
//  RestoMapController.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface RestoMapController : UIViewController <MKMapViewDelegate>
{
    IBOutlet MKMapView *worldView;
    IBOutlet UIBarButtonItem *returnToInfo;
}

- (IBAction)togglePickerView:(id)sender;

@end