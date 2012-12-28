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
#import "RestoInfoView.h"
#import "RestoMapViewController.h"

#define kRestoDaysShown 5

@interface RestoViewController () <UIScrollViewDelegate>

@property (nonatomic, unsafe_unretained) UIScrollView *scrollView;
@property (nonatomic, unsafe_unretained) UIPageControl *pageControl;

@property (nonatomic, strong) NSArray *days;
@property (nonatomic, strong) NSMutableArray *menus;

@property (nonatomic, assign) NSUInteger pageControlUsed;
@property (nonatomic, readonly) NSInteger currentPage;

@end

@implementation RestoViewController {
    NSInteger oldCurrentIndex;
    RestoMenuView *leftView;
    RestoMenuView *currentView;
    RestoMenuView *rightView;
    RestoInfoView *infoView;
}

#pragma mark Properties

@synthesize menus = _menus;
- (void)setMenus:(NSMutableArray *)menus
{
    if(_menus != menus) {
        _menus = menus;
        [self updateMenusOntoViews];
    }
}

- (NSInteger)currentPage
{
    CGFloat contentWidth = self.scrollView.frame.size.width;
    NSInteger page = ((self.scrollView.contentOffset.x - contentWidth / 2) / contentWidth) + 1;
    return page;
}

#pragma mark Setting up the view & viewcontroller

- (void)loadView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor hydraBackgroundColor];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;

    CGRect pageControlFrame = CGRectMake(0, bounds.size.height - 36, bounds.size.width, 36);
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:pageControlFrame];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [pageControl addTarget:self action:@selector(pageChanged:)
          forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;

    // Pages
    CGSize viewSize = self.scrollView.frame.size;
    for (NSUInteger i = 0; i < 3; i++) {
        // 20 pixels padding on each edge
        CGRect frame = CGRectMake(viewSize.width * (i + 1) + 20, 20,
                                  viewSize.width - 40, viewSize.height - 60);

        // Use the outer view for shadows, the contentView uses maskToBounds for rounded corners
        UIView *holderView = [[UIView alloc] initWithFrame:frame];
        holderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.scrollView addSubview:holderView];

        RestoMenuView *pageView = [[RestoMenuView alloc] initWithFrame:holderView.bounds];
        //[pageView configureWithDay:self.days[i] andMenu:self.menus[i]];
        [holderView addSubview:pageView];

        if(i == 0) {
            currentView = pageView;
        } else if(i == 1) {
            rightView = pageView;
        } else if(i == 2) {
            leftView = pageView;
        }
    }

    {
        // 20 pixels padding on each edge
        CGRect frame = CGRectMake(20, 20, viewSize.width - 40, viewSize.height - 60);

        // Use the outer view for shadows, the contentView uses maskToBounds for rounded corners
        UIView *holderView = [[UIView alloc] initWithFrame:frame];
        holderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.scrollView addSubview:holderView];
        infoView = [[RestoInfoView alloc] initWithFrame:holderView.bounds];
        [holderView addSubview:infoView];


        [infoView.legendButton addTarget:self action:@selector(legendButtonTouched:)
                        forControlEvents:UIControlEventTouchUpInside];
        [infoView.mapButton addTarget:self action:@selector(mapButtonTouched:)
                     forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Resto Menu";

    // Check for updates
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(menuUpdated:)
                   name:RestoStoreDidReceiveMenuNotification
                 object:nil];
    [self loadMenuItems];

    // Setup scrollview
    NSLog(@"viewSize: %@", NSStringFromCGRect(leftView.frame));
    CGSize viewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(viewSize.width * (self.days.count + 1), 0);
    self.scrollView.contentOffset = CGPointMake(viewSize.width, 0);

    // Setup pageControl
    self.pageControlUsed = 0;
    self.pageControl.numberOfPages = self.days.count + 1;
    self.pageControl.currentPage = 1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view

    // Nil weak references
    self.scrollView = nil;
    self.pageControl = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [self setupSheetStyle:leftView.superview];
    [self setupSheetStyle:currentView.superview];
    [self setupSheetStyle:rightView.superview];
    [self setupSheetStyle:infoView.superview];
}

#define kPageCornerRadius 10

- (void)setupSheetStyle:(UIView *)pageHolder ;
{
    CALayer *layer = pageHolder.layer;
    layer.cornerRadius = kPageCornerRadius;

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:layer.bounds
                                                          cornerRadius:kPageCornerRadius];
    layer.shadowPath = shadowPath.CGPath;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.3;
    layer.shadowOffset = CGSizeMake(1.5, 3.0);

    UIView *contentView = pageHolder.subviews[0];
    contentView.layer.cornerRadius = kPageCornerRadius;
    contentView.layer.masksToBounds = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Buttons

- (void)legendButtonTouched:(UIButton *)sender
{
    // TODO
}

- (void)mapButtonTouched:(UIButton *)sender
{
    UIViewController *c = [[RestoMapViewController alloc] init];
    [self presentModalViewController:c animated:YES];
}

#pragma mark Loading days & menu's

- (void)calculateDays
{
    NSDate *day = [NSDate date];
    NSMutableArray *days = [NSMutableArray arrayWithCapacity:kRestoDaysShown];

    // Find the next 5 days to display
    while (days.count < kRestoDaysShown) {
        if ([day isTypicallyWorkday]) {
            [days addObject:day];
        }
        day = [day dateByAddingDays:1];
    }
    self.days = days;
}

- (void)loadMenuItems
{
    if (!self.days.count) [self calculateDays];

    NSMutableArray *menus = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < self.days.count; i++) {
        id menu = [[RestoStore sharedStore] menuForDay:self.days[i]];
        if (!menu) menu = [NSNull null];
        menus[i] = menu;
    }
    self.menus = menus;
}

- (void)menuUpdated:(NSNotification *)notification
{
    DLog(@"Menu updated!");
    [self loadMenuItems];
    [self resetViews];
}

#pragma mark Page changing

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if(oldCurrentIndex != self.currentPage) {
        [self changeViewsToPageIndex:self.currentPage];
    }
    if (self.pageControlUsed > 0) return;

    self.pageControl.currentPage = self.currentPage;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)sender
{
    self.pageControlUsed--;
}

- (void)pageChanged:(UIPageControl *)sender
{
    DLog(@"UIPageControl requesting page %d", self.pageControl.currentPage);
    CGRect newPage = self.scrollView.bounds;
    newPage.origin.x = newPage.size.width * self.pageControl.currentPage;
    [self.scrollView scrollRectToVisible:newPage animated:YES];
    self.pageControlUsed++;
}

#pragma mark Configuring views after scrolling

- (void)changeViewsToPageIndex:(NSInteger)currentIndex
{
    if(oldCurrentIndex == currentIndex-1) {
        RestoMenuView *left = currentView;
        RestoMenuView *current = rightView;
        RestoMenuView *right = leftView;
        if(oldCurrentIndex > 0 && currentIndex+1 < kRestoDaysShown+1) {
            [self updateView:right toIndex:currentIndex+1];
        }
        leftView = left;
        currentView = current;
        rightView = right;
    } else if(oldCurrentIndex == currentIndex+1) {
        RestoMenuView *left = rightView;
        RestoMenuView *current = leftView;
        RestoMenuView *right = currentView;
        if(currentIndex-1 >= 1) {
            [self updateView:left toIndex:currentIndex-1];
        }
        leftView = left;
        currentView = current;
        rightView = right;
    } else {
        [self resetViews];
    }
    oldCurrentIndex = currentIndex;
}

- (void)updateView:(RestoMenuView *)view toIndex:(NSInteger)index
{
    CGSize viewSize = self.view.bounds.size;
    CGRect frame = CGRectMake(viewSize.width * index + 20, 20,
                              viewSize.width - 40, viewSize.height - 60);
    view.superview.frame = frame;
    [view configureWithDay:self.days[index-1] andMenu:self.menus[index -1]];
}

- (void)resetViews
{
    NSInteger currentIndex = self.currentPage;
    if(0 < currentIndex) {
        [self updateView:currentView toIndex:currentIndex];
        if(0 < currentIndex-1) {
            [self updateView:leftView toIndex:currentIndex-1];
        }
        if(currentIndex+1 < kRestoDaysShown+1) {
            [self updateView:rightView toIndex:currentIndex+1];
        }
    }
}

- (void)updateMenusOntoViews
{
    NSInteger currentIndex = MAX(1, self.currentPage);
    if(currentIndex > 1) {
        [leftView configureWithDay:self.days[currentIndex-2] andMenu:self.menus[currentIndex-2]];
    }
    [currentView configureWithDay:self.days[currentIndex-1] andMenu:self.menus[currentIndex-1]];
    if(currentIndex < kRestoDaysShown) {
        [rightView configureWithDay:self.days[currentIndex] andMenu:self.menus[currentIndex]];
    }
}

@end
