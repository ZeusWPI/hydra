//
//  SchamperDetailViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperDetailViewController.h"
#import "NSDateFormatter+AppLocale.h"

@interface SchamperDetailViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) SchamperArticle *article;

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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didRecognizeTap:(UIEvent *)event
{
    // Don't do anything if the content's not big enough
    CGSize contentSize = self.webView.scrollView.contentSize;
    if (contentSize.height <= self.view.frame.size.height) return;

    BOOL hidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!hidden animated:YES];

    // Save the contentoffset, we'll need to restore it later
    CGPoint contentOffset = self.webView.scrollView.contentOffset;

    UIEdgeInsets insets = hidden ? UIEdgeInsetsZero : UIEdgeInsetsMake(-44, 0, 0, 0);
    self.webView.scrollView.contentInset = insets;
    self.webView.scrollView.contentOffset = contentOffset;

    // Prevent the view from landing in the top buffer zone
    if (contentOffset.y <= 44) {
        CGPoint newOffset = hidden ? CGPointZero : CGPointMake(0, 44);
        [self.webView.scrollView setContentOffset:newOffset animated:YES];
    }
}

- (void)shareButtonTapped:(id)sender
{
    // TODO: implement share button
    VLog(sender);
}

@end
