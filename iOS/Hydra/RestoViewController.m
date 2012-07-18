//
//  RestoViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoViewController.h"
#import "RestoStore.h"
#import "RestoMenu.h"

#define kRestoDaysShown 5

@implementation RestoViewController

- (id)init
{
    if (self = [super init]) {
        menus = [[NSMutableArray arrayWithCapacity:kRestoDaysShown] init];
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
    [self loadMenuItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    pageControl = nil;
    scrollView = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadMenuItems
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *day = [NSDate date];

    NSDateComponents *increment = [[NSDateComponents alloc] init];
    [increment setDay:1];

    // Get next 5 days to display and request them
    NSUInteger i = 0;
    while (i < kRestoDaysShown) {
        NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit|NSHourCalendarUnit fromDate:day];

        // Skip saturday and sunday
        if ([comps weekday] > 1 && [comps weekday] < 7) {
            id menu = [[RestoStore sharedStore] menuForDay:day];
            if (!menu) menu = [NSNull null];
            [menus insertObject:menu atIndex:i]; i++;
        }

        day = [calendar dateByAddingComponents:increment toDate:day options:0];
    }
}

- (void)menuUpdated:(NSNotification *)notification
{
    DLog(@"Menu updated!");
    [self loadMenuItems];
}

@end
