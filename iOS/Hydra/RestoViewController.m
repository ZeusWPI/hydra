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
#import "RestoMenuView.h"

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
        
        RestoMenuView *pageView = [[RestoMenuView alloc] initWithRestoMenu:[menus objectAtIndex:i] andDate:[days objectAtIndex:i]];
        [pageViewHolder addSubview:pageView];
        [self setupPageStyle:pageViewHolder];
    }

    // Setup pageControl
    [pageControl setNumberOfPages:[days count] + 1];
    [pageControl setCurrentPage:2];
    [scrollView setContentOffset:CGPointMake(viewSize.width, 0) animated:NO];
}

#define kPageCornerRadius 10

- (void)setupPageStyle:(UIView *)pageHolder ;
{
    CALayer *layer = [pageHolder layer];
    layer.cornerRadius = kPageCornerRadius;
    layer.masksToBounds = YES;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:layer.bounds
                                                          cornerRadius:kPageCornerRadius];
    [layer setShadowPath:[shadowPath CGPath]];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.3];
    [layer setShadowOffset:CGSizeMake(1.5, 3.0)];
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
    
    /*
     TODO
     set menu to activePage:
     RestoMenuView *pageView = ...
     pageView.menu = [menus objectAtIndex:page];
     */
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
