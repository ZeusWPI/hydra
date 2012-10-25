//
//  SchamperArticleViewControllerViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (nonatomic, unsafe_unretained) UIWebView *webView;

@end

@implementation WebViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                             | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    webView.hidden = YES;
    [self.view addSubview:webView];
    self.webView = webView;

    self.view.backgroundColor = self.webView.backgroundColor;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadHtml:(NSString *)path
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:path withExtension:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.hidden = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) return YES;
    [[UIApplication sharedApplication] openURL:[request URL]];
    return NO;
}

@end
