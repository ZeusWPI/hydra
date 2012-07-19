//
//  MasterViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "DashboardViewController.h"
#import "RestoViewController.h"
#import "SchamperViewController.h"
#import "InfoViewController.h"

@implementation DashboardViewController


// Testing
- (void)viewDidLoad
{
    [self showInfo:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)showNews:(id)sender {
    if([sender tag] == 5) {
        DLog(@"Dashboard switching to GSR");
    } else {
        DLog(@"Dashboard switching to News");
    }
}

- (IBAction)showActivities:(id)sender {
    DLog(@"Dashboard switching to Activities");
}

- (IBAction)showInfo:(id)sender {
    DLog(@"Dashboard switching to Info");
	
	NSArray *infoContent = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info-content" ofType:@"plist"]];
	InfoViewController *c = [[InfoViewController alloc] init];
	c.content = infoContent;
	[self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showResto:(id)sender {
    DLog(@"Dashboard switching to Resto");
    UIViewController *c = [[RestoViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showSchamper:(id)sender {
    DLog(@"Dashboard switching to Schamper");
    UIViewController *c = [[SchamperViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

@end
