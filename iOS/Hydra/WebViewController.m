//
//  SchamperArticleViewControllerViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (void)loadView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                             | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    self.view = webView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(self.trackedViewName);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIWebView *)webView
{
    return (UIWebView *)self.view;
}

- (void)loadHtml:(NSString *)path
{
    // Trigger view laod
    [self view];

    NSURL *url = [[NSBundle mainBundle] URLForResource:path withExtension:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) return YES;
    [[UIApplication sharedApplication] openURL:[request URL]];
    return NO;
}

@end
