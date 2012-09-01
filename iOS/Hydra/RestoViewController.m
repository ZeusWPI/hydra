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

@interface RestoViewController ()
@property (nonatomic, strong) NSMutableArray *menus;
@end

@implementation RestoViewController {
    NSMutableArray *days;
    NSMutableArray *_menus;
    NSUInteger pageControlUsed;

    IBOutlet UIPageControl *pageControl;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *infoPage;

    NSInteger oldCurrentIndex;
    RestoMenuView *leftView;
    RestoMenuView *currentView;
    RestoMenuView *rightView;
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
    CGFloat contentWidth = scrollView.frame.size.width;
    NSInteger page = ((scrollView.contentOffset.x - contentWidth / 2) / contentWidth) + 1;
    return page;
}

#pragma mark Setting up the view & viewcontroller

- (id)init
{
    if (self = [super init]) {
        days = [[NSMutableArray arrayWithCapacity:kRestoDaysShown] init];
        _menus = [[NSMutableArray arrayWithCapacity:kRestoDaysShown] init];
        for(int i=0;i<kRestoDaysShown;i++) {
            [_menus addObject:[NSNull null]];
        }
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

        RestoMenuView *pageView = [[RestoMenuView alloc] initWithRestoMenu:[self.menus objectAtIndex:i] andDate:[days objectAtIndex:i]];
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

#pragma mark Days & menu's (loading)

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

    NSMutableArray *menus = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [days count]; i++) {
        NSDate *day = [days objectAtIndex:i];
        id menu = [[RestoStore sharedStore] menuForDay:day];
        if (!menu) menu = [NSNull null];
        [menus insertObject:menu atIndex:i];
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
    pageControlUsed++;
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
    view.menu = [self.menus objectAtIndex:index-1];
    view.day = [days objectAtIndex:index-1];
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
        leftView.menu = [self.menus objectAtIndex:currentIndex -2];
    }
    currentView.menu = [self.menus objectAtIndex:currentIndex -1];
    if(currentIndex < kRestoDaysShown) {
        rightView.menu = [self.menus objectAtIndex:currentIndex];
    }
}

@end
