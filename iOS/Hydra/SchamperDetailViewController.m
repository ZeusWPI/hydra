//
//  SchamperDetailViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperDetailViewController.h"
#import "NSDateFormatter+AppLocale.h"
#import <ShareKit/ShareKit.h>
#import <TUSafariActivity.h>

@interface SchamperDetailViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) SchamperArticle *article;

@property (nonatomic, assign) BOOL animationActive;
@property (nonatomic, assign) CGFloat startContentOffset;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation SchamperDetailViewController

- (id)initWithArticle:(SchamperArticle *)article
{
    if (self = [super init]) {
        self.article = article;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    // Set tracked name
    self.trackedViewName = [@"Schamper > " stringByAppendingString:self.article.title];

    NSDateFormatter *dateFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
    dateFormatter.dateFormat = @"dd MMMM YYYY 'om' hh.mm 'uur'";

    NSString *html = [NSString stringWithFormat:
        @"<head>"
            @"<link rel='stylesheet' type='text/css' href='schamper.css' />"
        @"</head>"
        @"<body>"
            @"<header><h1>%@</h1><p class='meta'>%@<br />door %@</div></header>"
            @"<div class='content'>%@</div>"
        @"</body>",
        self.article.title, [dateFormatter stringFromDate:self.article.date],
        self.article.author, self.article.body];

    NSURL *bundeUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.webView loadHTMLString:html baseURL:bundeUrl];

    UIScrollView *scrollView = self.webView.scrollView;
    scrollView.delegate = self;
    CGFloat scrollOffset = IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 64 : 44;
    scrollView.contentInset = UIEdgeInsetsMake(scrollOffset, 0, 0, 0);
    scrollView.scrollIndicatorInsets = scrollView.contentInset;

    // Recognize taps
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    [tapRecognizer addTarget:self action:@selector(didRecognizeTap:)];
    [self.webView addGestureRecognizer:tapRecognizer];

    // Add share button
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                           target:self action:@selector(shareButtonTapped:)];
    self.navigationItem.rightBarButtonItem = btn;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if ([url.scheme isEqualToString:@"hydra"]) {
        if ([url.host isEqualToString:@"back"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return NO;
    }

    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)shareButtonTapped:(id)sender
{
    // Available since iOS6
    if ([UIActivityViewController class]) {
        NSArray *items = @[ self.article.title, [NSURL URLWithString:self.article.link] ];
        NSArray *activities = @[ [[TUSafariActivity alloc] init] ];

        UIActivityViewController *c = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                        applicationActivities:activities];
        [self presentViewController:c animated:YES completion:NULL];
    }
    else {
        // Create the item to share
        NSURL *link = [NSURL URLWithString:self.article.link];
        SHKItem *item = [SHKItem URL:link title:self.article.title contentType:SHKShareTypeURL];

        // Get the ShareKit action sheet
        SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];

        // Display the action sheet
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

#pragma mark - Gesture recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didRecognizeTap:(UIEvent *)event
{
    [self setNavigationBarHidden:NO];
}

#pragma mark - Navigation bar

- (void)setNavigationBarHidden:(BOOL)hide
{
    if (self.animationActive) {
        return;
    }

    BOOL current = self.navigationController.navigationBarHidden;
    if (current == hide) return;

    self.animationActive = true;

    // Don't do anything if the content's not big enough
    UIScrollView *scrollView = self.webView.scrollView;
    CGSize contentSize = scrollView.contentSize;
    if (contentSize.height <= self.view.frame.size.height) return;

    // This will cause a recursive call in this method
    [self.navigationController setNavigationBarHidden:hide animated:YES];

    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:UIStatusBarAnimationSlide];
        scrollView.contentInset = UIEdgeInsetsMake(hide ? 0 : 64, 0, 0, 0);
    }
    else {
        scrollView.contentInset = UIEdgeInsetsMake(hide ? 0 : 44, 0, 0, 0);
    }
    scrollView.scrollIndicatorInsets = scrollView.contentInset;

    self.animationActive = false;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.startContentOffset = self.lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = self.startContentOffset - currentOffset;
    CGFloat differenceFromLast = self.lastContentOffset - currentOffset;
    self.lastContentOffset = currentOffset;

    // Always show navigation bar in top section
    if (currentOffset <= 10) {
        [self setNavigationBarHidden:NO];
    }
    // Ignore events from the bottom bounce
    else if (currentOffset >= scrollView.contentSize.height - scrollView.frame.size.height) {
        return;
    }
    // Check if scrolling at high enough speed
    else if (scrollView.tracking && abs(differenceFromLast) > 1) {
        [self setNavigationBarHidden:(differenceFromStart < 0)];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self setNavigationBarHidden:NO];
    return YES;
}

@end
