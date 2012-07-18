//
//  RestoViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoViewController.h"
#import "RestoStore.h"

@implementation RestoViewController

@synthesize pageControl, scrollView;

- (id)init
{
    if (self = [super init]) {
        menuItems = [[RestoStore sharedStore] menuItems];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    [[self navigationItem] setTitle:@"Resto Menu"];

    // Check for updates
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(menuUpdated:)
                   name:RestoStoreDidReceiveMenuNotification
                 object:nil];
    [[RestoStore sharedStore] updateMenu];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    pageControl = nil;
    scrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)menuUpdated:(NSNotification *)notification
{
    DLog(@"Menu updated!");
}

@end
