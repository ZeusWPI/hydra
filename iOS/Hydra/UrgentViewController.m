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

- (id)init
{
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(playerStatusChanged:)
                       name:ASStatusChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    // Set state for highlighted|selected
    UIImage *selectedImage = [self.playButton imageForState:UIControlStateSelected];
    [self.playButton setImage:selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];

    // Initialize state
    [self playerStatusChanged:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UrgentInfo sharedInfo] startUpdating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Urgent");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UrgentInfo sharedInfo] stopUpdating];
}

- (void)playButtonTapped:(id)sender
{
    UrgentPlayer *player = [UrgentPlayer sharedPlayer];
    if ([player isPlaying]) {
        [player pause];
    }
    else {
        [player start];
    }
}

- (void)playerStatusChanged:(NSNotification *)notification
{
    // Update play button
    self.playButton.selected = [[UrgentPlayer sharedPlayer] isPlaying];
}

@end
