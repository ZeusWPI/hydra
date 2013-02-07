//
//  UrgentViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 05/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "UrgentViewController.h"
#import "UrgentPlayer.h"
#import "MarqueeLabel.h"
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>

@interface UrgentViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, unsafe_unretained) MarqueeLabel *showLabel;

@end

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
    [super viewDidLoad];

    // Set state for highlighted|selected
    UIImage *selectedImage = [self.playButton imageForState:UIControlStateSelected];
    [self.playButton setImage:selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];

    // Set up showLabel
    CGRect showLabelFrame = CGRectMake(33, 83, 170, 17);
    MarqueeLabel *showLabel = [[MarqueeLabel alloc] initWithFrame:showLabelFrame
                                                             rate:40.0f
                                                    andFadeLength:10.0f];
    showLabel.font = [UIFont fontWithName:@"GillSans" size:14];
    showLabel.textColor = [UIColor colorWithWhite:0.533 alpha:1.000];
    showLabel.marqueeType = MLContinuous;
    [self.view addSubview:showLabel];
    self.showLabel = showLabel;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MarqueeLabel controllerViewAppearing:self];
}

#pragma mark - Buttons

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

- (IBAction)homeButtonTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://urgent.fm"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)facebookButtonTapped:(id)sender
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"fb://profile/28367168655"];
    if (![app canOpenURL:url]) {
        url = [NSURL URLWithString:@"https://www.facebook.com/pages/Urgentfm/28367168655"];
    }
    [app openURL:url];
}

- (IBAction)twitterButtonTapped:(id)sender
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"twitter://user?screen_name=UrgentFM"];
    if (![app canOpenURL:url]) {
        url = [NSURL URLWithString:@"https://mobile.twitter.com/urgentfm"];
    }
    [app openURL:url];
}

- (IBAction)soundcloudButtonTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://m.soundcloud.com/urgent-fm-official"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)mailButtonTapped:(id)sender
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:@[@"contact@urgent.fm"]];
    [controller setSubject:@"Bericht via Hydra"];
    [self presentModalViewController:controller animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Listeners

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
    NSString *showText = @"";
    NSString *currentShow = [UrgentPlayer sharedPlayer].currentShow;
    if (currentShow) {
        showText = [NSString stringWithFormat:@"u luistert naar %@", currentShow];
    }
    self.showLabel.text = [showText uppercaseString];
}

@end
