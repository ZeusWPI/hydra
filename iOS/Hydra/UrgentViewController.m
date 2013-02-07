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

- (id)init
{
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(playerStatusChanged:)
                       name:ASStatusChangedNotification object:nil];
        [center addObserver:self selector:@selector(songUpdated:)
                       name:UrgentPlayerDidUpdateSongNotification object:nil];
        [center addObserver:self selector:@selector(showUpdated:)
                       name:UrgentPlayerDidUpdateShowNotification object:nil];
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

    // Initialize fields
    [self songUpdated:nil];
    [self showUpdated:nil];

    // Initialize state
    [self playerStatusChanged:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Urgent");
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

- (void)songUpdated:(NSNotification *)notification
{
    self.songLabel.text = [UrgentPlayer sharedPlayer].currentSong;
    self.previousSongLabel.text = [UrgentPlayer sharedPlayer].previousSong;
}

- (void)showUpdated:(NSNotification *)notification
{
    self.showLabel.text = [UrgentPlayer sharedPlayer].currentShow;
}

@end
