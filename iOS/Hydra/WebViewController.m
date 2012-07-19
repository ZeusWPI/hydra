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

    [self setView:webView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
