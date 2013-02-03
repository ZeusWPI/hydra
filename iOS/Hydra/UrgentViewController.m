//
//  UrgentViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 05/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "UrgentViewController.h"
#import "UrgentPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation UrgentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Urgent");
}

-(IBAction)streamPlay:(id)sender
{
    [[UrgentPlayer sharedPlayer] start];
}

-(IBAction)streamPause:(id)sender
{
    [[UrgentPlayer sharedPlayer] pause];
}

@end
