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
     
    // Do any additional setup after loading the view.
    NSString *html = [@"<head><link rel='stylesheet' type='text/css' href='schamper.css' /></head><body><h1>" stringByAppendingString:self.article.title];
    html = [html stringByAppendingString:@"</h1><div class='authorAndDate'>"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM YYYY om hh.mm uur"];

    //Date needs to be configured to send the date
    html = [html stringByAppendingString:[dateFormatter stringFromDate:self.article.date]];
    html = [html stringByAppendingString:@" door "];
    html = [html stringByAppendingString:self.article.author];
    html = [html stringByAppendingString:@"</div><div class='buttons'><a href='hydra://back'>Back</a></div>"];
    html = [html stringByAppendingString:@"<div class='content'"];
    html = [html stringByAppendingString:self.article.body];
    html = [html stringByAppendingString:@"</div></body>"];

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];

    [self.webView loadHTMLString: html baseURL: baseURL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
 
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    static NSString *urlPrefix = @"hydra://";
    if([url hasPrefix:urlPrefix]) {
        NSString *command = [url substringFromIndex:[urlPrefix length]];
        if([command isEqualToString:@"back"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return NO;
    }
    else {
        return YES;
    }
}

@end
