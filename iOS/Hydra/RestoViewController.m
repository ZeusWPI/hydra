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

@implementation RestoViewController {
    NSMutableArray *days;
    NSMutableArray *menus;
    NSUInteger pageControlUsed;
    
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *infoPage;
    
    NSInteger oldCurrentIndex;
    RestoMenuView *leftView;
    RestoMenuView *currentView;
    RestoMenuView *rightView;
}

- (NSInteger)currentPage {
    
    CGFloat contentWidth = scrollView.frame.size.width;
    NSInteger page = ((scrollView.contentOffset.x - contentWidth / 2) / contentWidth) + 1;
    return page;
}

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

    // Setup pageControl
    [pageControl setNumberOfPages:[days count] + 1];
    [pageControl setCurrentPage:2];
    [scrollView setContentOffset:CGPointMake(viewSize.width, 0) animated:NO];
    
    // Pages
    [self setupPageStyle:infoPage];

    for (NSUInteger i = 0; i < 3; i++) {
        // 20 pixels padding on each edge
        
        CGRect frame = CGRectMake(viewSize.width * (i + 1) + 20, 20,
                                  viewSize.width - 40, viewSize.height - 60);
        
        UIView *pageViewHolder = [[UIView alloc] initWithFrame:frame];
        [scrollView addSubview:pageViewHolder];
        
        RestoMenuView *pageView = [[RestoMenuView alloc] initWithRestoMenu:[menus objectAtIndex:i] andDate:[days objectAtIndex:i]];
        if(i == 0) {
            currentView = pageView;
        } else if(i == 1) {
            rightView = pageView;
        } else if(i == 2) {
            leftView = pageView;
        }
        [pageViewHolder addSubview:pageView];
        //superview necessary to draw shadows, view itself uses maskToBounds for rounded corners
        [self setupPageStyle:pageViewHolder];
    }
}

#define kPageCornerRadius 10

- (void)setupPageStyle:(UIView *)pageHolder ;
{
    CALayer *layer = [pageHolder layer];
    [layer setCornerRadius:kPageCornerRadius];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:layer.bounds
                                                          cornerRadius:kPageCornerRadius];
    [layer setShadowPath:[shadowPath CGPath]];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.3];
    [layer setShadowOffset:CGSizeMake(1.5, 3.0)];
    
    UIView *contentView = [[pageHolder subviews] objectAtIndex:0];
    [[contentView layer] setCornerRadius:kPageCornerRadius];
    [[contentView layer] setMasksToBounds:YES];
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

#pragma mark Page changing

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if(oldCurrentIndex != self.currentPage) {
        [self didChangePage];
    }
    if (pageControlUsed > 0) return;
    [pageControl setCurrentPage:self.currentPage];
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

#pragma mark Configuring view after scrolling

- (void)didChangePage {
    
    NSInteger currentIndex = self.currentPage;
    if(oldCurrentIndex > 0 && oldCurrentIndex == currentIndex-1) {
        RestoMenuView *left = currentView;
        RestoMenuView *current = rightView;
        RestoMenuView *right = leftView;
        if(oldCurrentIndex > 1 && currentIndex+1 < kRestoDaysShown+1) {
            [self changeView:right toIndex:currentIndex+1];
        }
        leftView = left;
        currentView = current;
        rightView = right;
    } else if(currentIndex > 0 && oldCurrentIndex == currentIndex+1) {
        RestoMenuView *left = rightView;
        RestoMenuView *current = leftView;
        RestoMenuView *right = currentView;
        if(currentIndex-1 >= 1) {
            [self changeView:left toIndex:currentIndex-1];
        }
        leftView = left;
        currentView = current;
        rightView = right;
    }
    oldCurrentIndex = currentIndex;
}

- (void)changeView:(RestoMenuView *)view toIndex:(NSInteger)index {
    
    CGSize viewSize = self.view.bounds.size;
    CGRect frame = CGRectMake(viewSize.width * index + 20, 20,
                              viewSize.width - 40, viewSize.height - 60);
    view.superview.frame = frame;
    view.menu = [menus objectAtIndex:index-1];
    view.day = [days objectAtIndex:index-1];
}

@end
