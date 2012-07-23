//
//  SchamperArticleViewControllerViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (UIWebView *)webView
{
    return (UIWebView *)[self view];
}

- (void)loadView
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:screenFrame];
    [webView setDelegate:self];

    [self setView:webView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadHtml:(NSString *)path
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:path withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) return YES;
    [[UIApplication sharedApplication] openURL:[request URL]];
    return NO;
}

@end
