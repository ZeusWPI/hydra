//
//  FacebookViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "FacebookViewController.h"
#import "FacebookLogin.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FBEventView.h"

@interface FacebookViewController ()
@end

@implementation FacebookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([[FBSession activeSession] isOpen]){
        // facebook is logged in
        [self loadLoggedInView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loginButtonPressed:(id)sender
{
    [self.spinner startAnimating];
    FacebookLogin *delegate = [FacebookLogin sharedLogin];
    DLog(@"Facebook login button was pushed");
    if([delegate openSessionWithAllowLoginUI:YES]){
        // yes => log in worked
        [self.logInButton setHidden:YES];
        [self.logOutButton setHidden:NO];
        [self loadLoggedInView];
    }else {
        // log in failed
    }
    [self.spinner stopAnimating];
}

-(IBAction)logoutButtonPressed:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
    [self.logInButton setHidden:NO];
    [self.logOutButton setHidden:YES];
}

- (void)loadLoggedInView
{
    FBEventView *eventView = [[FBEventView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 300)];
    [eventView configureWithEventID:@"171216039688617"];
    [self.view addSubview:eventView];
}
@end
