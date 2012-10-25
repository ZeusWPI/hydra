//
//  SchamperDetailViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperDetailViewController.h"

@interface SchamperDetailViewController ()

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

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM YYYY 'om' hh.mm 'uur'";

    NSString *html = [NSString stringWithFormat:
        @"<head><link rel='stylesheet' type='text/css' href='schamper.css' /></head>"
        @"<body>"
            @"<header><h1>%@</h1><p class='meta'>%@ door %@</div></header>"
            @"<div class='content'>%@</div>"
        @"</body>",
        self.article.title, [dateFormatter stringFromDate:self.article.date],
        self.article.author, self.article.body];

    NSURL *bundeUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.webView loadHTMLString:html baseURL:bundeUrl];

    // TODO: add share button to toolbar
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

@end
