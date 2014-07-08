//
//  MenuViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 8/07/14.
//  Copyright (c) 2014 Zeus WPI. All rights reserved.
//

#import "MenuViewController.h"

#import <MessageUI/MessageUI.h>

#import "DashboardViewController.h"
#import "ActivitiesController.h"
#import "InfoViewController.h"
#import "NewsViewController.h"
#import "PreferencesController.h"
#import "RestoMenuController.h"
#import "SchamperViewController.h"
#import "UrgentViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button actions
- (IBAction)showDashboard:(id)sender
{
    DLog(@"Menu switching to Dashboard");
    DashboardViewController *c = [[DashboardViewController alloc] init];
    [self showViewController:c];
}

- (IBAction)showNews:(id)sender
{
    DLog(@"Menu switching to News");
    
    NewsViewController *c = [[NewsViewController alloc] init];
    [self showViewController:c];
}

- (IBAction)showActivities:(id)sender
{
    DLog(@"Menu switching to Activities");
    ActivitiesController *c = [[ActivitiesController alloc] init];
    [self showViewController:c];
}

- (IBAction)showInfo:(id)sender
{
    DLog(@"Menu switching to Info");
	InfoViewController *c = [[InfoViewController alloc] init];
    [self showViewController:c];
}

- (IBAction)showResto:(id)sender
{
    DLog(@"Menu switching to Resto");
    RestoMenuController *c = [[RestoMenuController alloc] init];
    [self showViewController:c];
}

- (IBAction)showUrgent:(id)sender
{
    DLog(@"Menu switching to Urgent");
    UrgentViewController *c = [[UrgentViewController alloc] init];
    [self showViewController:c];
}

- (IBAction)showSchamper:(id)sender
{
    DLog(@"Menu switching to Schamper");
    SchamperViewController *c = [[SchamperViewController alloc] init];
    [self showViewController:c];
}

- (IBAction)showFeedbackView:(id)sender
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:@[@"hydra@zeus.ugent.be"]];
    [controller setSubject:@"Bericht via Hydra"];
    [self presentModalViewController:controller animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)showPreferences:(id)sender
{
    DLog(@"Menu switching to Preferences");
    PreferencesController *c = [[PreferencesController alloc] init];
    [self showViewController:c];
}

-(void)showViewController:(UIViewController *)controller
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.revealController setFrontViewController:nav];
    [self.revealController resignPresentationModeEntirely:NO animated:YES completion:nil];
}

@end
