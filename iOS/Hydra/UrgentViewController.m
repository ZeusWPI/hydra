//
//  UrgentViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 05/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "UrgentViewController.h"
#import "UrgentPlayer.h"
#import "URGentInfo.h"
#import <AVFoundation/AVFoundation.h>

@implementation UrgentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [[UrgentPlayer sharedPlayer] start];

    [[URGentInfo sharedInfo] startUpdating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[URGentInfo sharedInfo] startUpdating];

    GAI_Track(@"Urgent");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [[URGentInfo sharedInfo] stopUpdating];
}

-(IBAction)streamPlay:(id)sender
{
    [[UrgentPlayer sharedPlayer] start];
}

-(IBAction)streamPause:(id)sender
{
    [[UrgentPlayer sharedPlayer] pause];
}

-(IBAction)nowPlaying:(id)sender
{
    VLog([[URGentInfo sharedInfo] nowPlaying]);
}

-(IBAction)prevPlaying:(id)sender
{
    VLog([[URGentInfo sharedInfo] prevPlaying]);
}

@end
