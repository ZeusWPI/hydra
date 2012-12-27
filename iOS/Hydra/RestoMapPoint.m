//
//  RestoMapPoint.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMapPoint.h"

@implementation RestoMapPoint

@synthesize coordinate, title;

- (id) initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)t
{
    self = [super init];
    if(self){
        coordinate = c;
        [self setTitle:t];
    }
    return self;
}

- (id)init
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(51.3, 3.42) andTitle:@"Gent Centrum"];
}

@end
