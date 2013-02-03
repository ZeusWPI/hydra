//
//  UrgentViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 05/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "UrgentViewController.h"
#import "UrgentPlayer.h"
#import "UrgentInfo.h"
#import <AVFoundation/AVFoundation.h>

@implementation UrgentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [[UrgentInfo sharedInfo] startUpdating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UrgentInfo sharedInfo] startUpdating];

    GAI_Track(@"Urgent");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [[UrgentInfo sharedInfo] stopUpdating];
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
    VLog([[UrgentInfo sharedInfo] nowPlaying]);
}

-(IBAction)prevPlaying:(id)sender
{
    VLog([[UrgentInfo sharedInfo] prevPlaying]);
}

@end
