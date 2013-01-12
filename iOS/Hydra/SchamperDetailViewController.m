//
//  SchamperDetailViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperDetailViewController.h"
#import "NSDateFormatter+AppLocale.h"

@interface SchamperDetailViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) SchamperArticle *article;

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
    scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    scrollView.scrollIndicatorInsets = scrollView.contentInset;

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
    // TODO: implement share button
    VLog(sender);
}

#pragma mark - Navigation bar madness

- (void)setNavigationBarHidden:(BOOL)hide
{
    BOOL current = self.navigationController.navigationBarHidden;
    if (current == hide) return;

    // Don't do anything if the content's not big enough
    UIScrollView *scrollView = self.webView.scrollView;
    CGSize contentSize = scrollView.contentSize;
    if (contentSize.height <= self.view.frame.size.height) return;

    [self.navigationController setNavigationBarHidden:hide animated:YES];

    scrollView.contentInset = UIEdgeInsetsMake(hide ? 0 : 44, 0, 0, 0);
    scrollView.scrollIndicatorInsets = scrollView.contentInset;
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
