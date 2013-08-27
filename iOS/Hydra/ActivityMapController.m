//
//  ActivityMapViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 27/08/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "ActivityMapController.h"

@interface SimpleMapAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end

@interface ActivityMapController ()

@property (nonatomic, strong) AssociationActivity *activity;

@end

@implementation ActivityMapController

- (id)initWithActivity:(AssociationActivity *)activity
{
    if (self = [super init]) {
        self.activity = activity;
    }
    return self;
}

- (void)loadMapItems
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.activity.latitude,
                                                                   self.activity.longitude);
    SimpleMapAnnotation *mapItem = [[SimpleMapAnnotation alloc] initWithCoordinate:coordinate
                                                                             title:self.activity.location];
    [self.mapView addAnnotation:mapItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Kaart";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Activiteit > ... > Kaart");
}

@end

@implementation SimpleMapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
    if (self = [super init]) {
        _coordinate = coordinate;
        _title = title;
    }
    return self;
}

@end
