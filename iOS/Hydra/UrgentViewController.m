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
#import <ShareKit/ShareKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>

#define UrgentSocialEnabled 0

@interface UrgentViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, unsafe_unretained) MarqueeLabel *showLabel;

@end

@implementation UrgentViewController

- (id)init
{
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(playerStatusChanged:)
                       name:UrgentPlayerDidChangeStateNotification object:nil];
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

#ifdef __IPHONE_7_0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif

    // Set state for highlighted|selected
    UIImage *selectedImage = [self.playButton imageForState:UIControlStateSelected];
    [self.playButton setImage:selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];

    // Set up showLabel
    CGRect showLabelFrame = CGRectMake(33, 70, 170, 17);
    MarqueeLabel *showLabel = [[MarqueeLabel alloc] initWithFrame:showLabelFrame
                                                             rate:40.0f
                                                    andFadeLength:10.0f];
    showLabel.font = [UIFont fontWithName:@"GillSans" size:14];
    showLabel.textColor = [UIColor colorWithWhite:0.533 alpha:1.000];
    showLabel.marqueeType = MLContinuous;
    showLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:showLabel];
    self.showLabel = showLabel;

    // Initialize state
    [self playerStatusChanged:nil];

#if UrgentSocialEnabled
    // Add share button
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                         target:self action:@selector(shareButtonTapped:)];
    self.navigationItem.rightBarButtonItem = btn;
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Urgent");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Setup info fields
    [self updateSongAnimated:NO];
    [self showUpdated:nil];

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
        [player play];
    }
}

- (void)openUrl:(NSString *)url fallbackUrl:(NSString *)fallbackUrl
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *resultUrl = [NSURL URLWithString:url];
    if (![app canOpenURL:resultUrl]) {
        resultUrl = [NSURL URLWithString:fallbackUrl];
    }
    [app openURL:resultUrl];
}

- (IBAction)homeButtonTapped:(id)sender
{
    [self openUrl:@"http://urgent.fm" fallbackUrl:nil];
}

- (IBAction)facebookButtonTapped:(id)sender
{
    [self openUrl:@"fb://profile/28367168655"
      fallbackUrl:@"https://www.facebook.com/pages/Urgentfm/28367168655"];
}

- (IBAction)twitterButtonTapped:(id)sender
{
    [self openUrl:@"twitter://user?screen_name=UrgentFM"
      fallbackUrl:@"https://mobile.twitter.com/urgentfm"];
}

- (IBAction)soundcloudButtonTapped:(id)sender
{
    [self openUrl:@"http://m.soundcloud.com/urgent-fm-official" fallbackUrl:nil];
}

- (IBAction)mailButtonTapped:(id)sender
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:@[@"contact@urgent.fm"]];
    [controller setSubject:@"Bericht via Hydra"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#if UrgentSocialEnabled
- (void)shareButtonTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://www.urgent.fm"];
    NSString *message =[self createShareMessage];
    // Available since iOS6
    if ([UIActivityViewController class]) {
        NSArray *items = @[ message, url ];

        UIActivityViewController *c = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                        applicationActivities:@[]];
        [self presentViewController:c animated:YES completion:NULL];
    }
    else {
        // Create the item to share
        SHKItem *item = [SHKItem URL:url title:message contentType:SHKURLContentTypeUndefined];

        // Get the ShareKit action sheet
        SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];

        // Display the action sheet
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (NSString*)createShareMessage
{
    NSString *string = @"Beluister urgent.fm";
    if ([[UrgentPlayer sharedPlayer] isPlaying]){
        NSString *show = [[UrgentPlayer sharedPlayer] currentShow];
        NSString *song = [[UrgentPlayer sharedPlayer] currentSong];
        if (show.length > 0){
            if (song.length){
                string = [NSString stringWithFormat:@"Aan het luisteren naar %@ op %@", song, show];
            }
            else {
                string = [NSString stringWithFormat:@"Aan het luisteren naar %@", show];
            }
        }else if (song.length > 0){
            string = [NSString stringWithFormat:@"Aan het luisteren naar %@", song];
        }
    }
    return string;
}
#endif

#pragma mark - Listeners

- (void)playerStatusChanged:(NSNotification *)notification
{
    // Update play button
    self.playButton.selected = [[UrgentPlayer sharedPlayer] isPlaying];
}

- (void)songUpdated:(NSNotification *)notification
{
    [self updateSongAnimated:YES];
}

- (void)updateSongAnimated:(BOOL)animated
{
    NSString *currentSong = [UrgentPlayer sharedPlayer].currentSong;
    NSString *previousSong = [UrgentPlayer sharedPlayer].previousSong;

    // Check if anything has changed
    if ([currentSong isEqualToString:self.songLabel.text]) {
        return;
    }

    self.songWrapper.hidden = currentSong.length == 0;
    self.previousSongWrapper.hidden = previousSong.length == 0;

    if (!animated) {
        self.songLabel.text = currentSong;
        self.previousSongLabel.text = previousSong;
    }
    else {
        [self animatePreviousWrapperWithCompletion:^{
            self.previousSongLabel.text = previousSong;
            self.songLabel.text = currentSong;

            // Animate the appearance of previousSong
            if (previousSong.length > 0) {
                CGRect originalPreviousFrame = self.previousSongWrapper.frame;
                self.previousSongWrapper.frame = self.songWrapper.frame;
                [UIView animateWithDuration:0.8 animations:^{
                    self.previousSongWrapper.frame = originalPreviousFrame;
                }];
            }

            // Animate the appearance of currentSong
            CGRect originalFrame = self.songWrapper.frame;
            self.songWrapper.frame = CGRectOffset(originalFrame, 0, originalFrame.size.height);
            self.songWrapper.alpha = 0;
            [UIView animateWithDuration:0.8 animations:^{
                self.songWrapper.frame = originalFrame;
                self.songWrapper.alpha = 1;
            }];
        }];
    }
}

- (void)animatePreviousWrapperWithCompletion:(void (^)())completion
{
    // If there currently is a previousSong we will fade it out quickly
    // and then start the next animation. If it's not we can start
    // the next animation immediately.
    if (self.previousSongLabel.text.length > 0) {
        [UIView animateWithDuration:0.15 animations:^{
            self.previousSongWrapper.alpha = 0;
        } completion:^(BOOL finished) {
            self.previousSongWrapper.alpha = 1;
            completion();
        }];
    }
    else {
        completion();
    }
}

- (void)showUpdated:(NSNotification *)notification
{
    NSString *showText = @"";
    NSString *currentShow = [UrgentPlayer sharedPlayer].currentShow;
    if (currentShow) {
        showText = [NSString stringWithFormat:@"U LUISTERT NAAR %@", currentShow];
    }
    self.showLabel.text = [showText uppercaseString];
}

@end
