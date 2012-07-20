//
//  RestoViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RestoViewController.h"
#import "RestoStore.h"
#import "RestoMenu.h"
#import "UIColor+AppColors.h"
#import "NSDate+Utilities.h"

#define kRestoDaysShown 5

@implementation RestoViewController

- (id)init
{
    if (self = [super init]) {
        days = [[NSMutableArray arrayWithCapacity:kRestoDaysShown] init];
        menus = [[NSMutableArray arrayWithCapacity:kRestoDaysShown] init];
        pageControlUsed = 0;
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

    // Setup scrollview
    CGSize viewSize = [scrollView frame].size;
    [scrollView setContentSize:CGSizeMake(viewSize.width * ([days count] + 1),
                                          viewSize.height)];

    // Pages
    [self setupPageStyle:infoPage];

    // TODO: reuse views
    // see http://cocoawithlove.com/2009/01/multiple-virtual-pages-in-uiscrollview.html
    for (NSUInteger i = 0; i < [days count]; i++) {
        // 20 pixels padding on each edge
        CGRect frame = CGRectMake(viewSize.width * (i + 1) + 20, 20,
                                  viewSize.width - 40, viewSize.height - 60);

        UIView *pageViewHolder = [[UIView alloc] initWithFrame:frame];
        [scrollView addSubview:pageViewHolder];

        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RestoMenuView" owner:nil options:nil];
        UIView *pageView = [nib objectAtIndex:0];
        [pageViewHolder addSubview:pageView];

        [self setupPageStyle:pageViewHolder];
        [self setupView:pageView forDay:[days objectAtIndex:i] withMenu:[menus objectAtIndex:i]];
    }

    // Setup pageControl
    [pageControl setNumberOfPages:[days count] + 1];
    [pageControl setCurrentPage:2];
    [scrollView setContentOffset:CGPointMake(viewSize.width, 0) animated:NO];
}

- (void)setupPageStyle:(UIView *)pageHolder ;
{
    CALayer *layer = [pageHolder layer];
    [layer setCornerRadius:10];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.3];
    [layer setShadowRadius:5];
    [layer setShadowOffset:CGSizeMake(3.0, 3.0)];
    
    UIView *contentView = [[pageHolder subviews] objectAtIndex:0];
    [[contentView layer] setCornerRadius:10];
    [[contentView layer] setMasksToBounds:YES];
}

#define kTitleLabelTag 1
#define KClosedViewTag 2

- (void)setupView:(UIView *)view forDay:(NSDate *)day withMenu:(id)menuValue
{
    NSString *dateString;
    if ([day isToday]) dateString = @"Vandaag";
    else if ([day isTomorrow]) dateString = @"Morgen";
    else {
        // Create capitalized, formatted string
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE d MMMM"];
        dateString = [formatter stringFromDate:day];
        dateString = [dateString stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                      withString:[[dateString substringToIndex:1] capitalizedString]];
    }

    UILabel *label = (UILabel *)[view viewWithTag:kTitleLabelTag];
    [label setText:dateString];

    if (menuValue != [NSNull null]) {
        RestoMenu *menu = menuValue;
        [[view viewWithTag:KClosedViewTag] setHidden:[menu open]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    pageControl = nil;
    scrollView = nil;
    pageControlUsed = 0;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)calculateDays
{
    NSDate *day = [NSDate date];

    // Find the next 5 days to display
    while ([days count] < kRestoDaysShown) {
        if ([day isTypicallyWorkday]) {
            [days addObject:day];
        }
        day = [day dateByAddingDays:1];
    }
}

- (void)loadMenuItems
{
    if ([days count] == 0) [self calculateDays];

    for (NSUInteger i = 0; i < [days count]; i++) {
        NSDate *day = [days objectAtIndex:i];
        id menu = [[RestoStore sharedStore] menuForDay:day];
        if (!menu) menu = [NSNull null];
        [menus insertObject:menu atIndex:i];
    }
}

- (void)menuUpdated:(NSNotification *)notification
{
    DLog(@"Menu updated!");
    [self loadMenuItems];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (pageControlUsed > 0) return;
    CGFloat contentWidth = [sender frame].size.width;
    NSInteger page = floor(([sender contentOffset].x - contentWidth / 2) / contentWidth) + 1;
    [pageControl setCurrentPage:page];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)sender
{
    pageControlUsed--;
}

- (void)pageChanged:(UIPageControl *)sender
{
    DLog(@"UIPageControl requesting page %d", [pageControl currentPage]);
    CGSize viewSize = [scrollView frame].size;
    CGRect newPage = CGRectMake(viewSize.width * [pageControl currentPage], 0,
                                viewSize.width, viewSize.height);
    [scrollView scrollRectToVisible:newPage animated:YES];
    pageControlUsed += 1;
}

@end
