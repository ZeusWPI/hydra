//
//  NewsDetailViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 6/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "Association.h"
#import "NSDateFormatter+AppLocale.h"
#import <QuartzCore/QuartzCore.h>

@interface NewsDetailViewController ()

@property (nonatomic, strong) AssociationNewsItem *newsItem;

@end

@implementation NewsDetailViewController

- (id)initWithNewsItem:(AssociationNewsItem *)newsItem
{
    if (self = [super init]) {
        self.newsItem = newsItem;
    }
    return self;
}

- (void)viewDidLoad
{
    CGSize viewSize = self.view.bounds.size;
    CGSize contentSize = CGSizeMake(viewSize.width - 20, CGFLOAT_MAX);
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = @"Nieuwsbericht";

    // Title
    UIFont *titleFont = [UIFont boldSystemFontOfSize:19];
    CGSize actualSize = [self.newsItem.title sizeWithFont:titleFont
                                        constrainedToSize:contentSize
                               lineBreakMode:NSLineBreakByWordWrapping];

    CGRect titleFrame = CGRectMake(10, 8, contentSize.width, actualSize.height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = titleFont;
    titleLabel.text = self.newsItem.title;
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor hydraTintColor];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    // Date
    NSDateFormatter *dateFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
    dateFormatter.dateFormat = @"EEEE d MMMM YYYY";
    NSString *formatttedDate = [dateFormatter stringFromDate:self.newsItem.date];
    formatttedDate = [formatttedDate stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                      withString:[[formatttedDate substringToIndex:1] capitalizedString]];

    UIFont *metaFont = [UIFont systemFontOfSize:15];
    CGRect dateFrame = CGRectMake(10, CGRectGetMaxY(titleFrame) + 4, contentSize.width, 18);
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateFrame];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.font = metaFont;
    dateLabel.text = formatttedDate;
    dateLabel.textAlignment = UITextAlignmentCenter;
    dateLabel.textColor = [UIColor hydraTintColor];

    // Association
    actualSize = [self.newsItem.association.displayedFullName sizeWithFont:metaFont
                                                         constrainedToSize:contentSize
                                                             lineBreakMode:NSLineBreakByWordWrapping];
    CGRect associationFrame = CGRectMake(10, CGRectGetMaxY(dateFrame),
                                         contentSize.width, actualSize.height);
    UILabel *associationLabel = [[UILabel alloc] initWithFrame:associationFrame];
    associationLabel.backgroundColor = [UIColor clearColor];
    associationLabel.font = metaFont;
    associationLabel.text = self.newsItem.association.displayedFullName;
    associationLabel.textAlignment = UITextAlignmentCenter;
    associationLabel.textColor = [UIColor hydraTintColor];
    associationLabel.numberOfLines = 0;
    associationLabel.lineBreakMode = NSLineBreakByWordWrapping;

    // Header
    CGRect headerFrame = CGRectMake(-5, 0, viewSize.width + 10, CGRectGetMaxY(associationFrame) + 10);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    headerView.backgroundColor = [UIColor hydraBackgroundColor];
    headerView.layer.shadowColor = [UIColor blackColor].CGColor;
    headerView.layer.shadowOffset = CGSizeMake(0, 3);
    headerView.layer.shadowOpacity = 0.5;

    // Body
    CGRect bodyFrame = CGRectMake(0, CGRectGetMaxY(headerFrame), viewSize.width,
                                  viewSize.height - CGRectGetMaxY(headerFrame));
    UIWebView *bodyView = [[UIWebView alloc] initWithFrame:bodyFrame];
    bodyView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                              | UIViewAutoresizingFlexibleHeight;

    // Remove background from webView
    bodyView.backgroundColor = [UIColor whiteColor];
    id scrollView = [bodyView.subviews objectAtIndex:0];
    [scrollView setContentInset:UIEdgeInsetsMake(5, 0, 0, 0)];
    [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
    for (UIView *subview in [scrollView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            subview.hidden = YES;
        }
    }

    NSString *bodyHtml = [NSString stringWithFormat:
                          @"<head>"
                          @"<link rel='stylesheet' type='text/css' href='webview.css' />"
                          @"</head>"
                          @"<body>%@</body>", self.newsItem.content];
    NSURL *bundeUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [bodyView loadHTMLString:bodyHtml baseURL:bundeUrl];

    [self.view addSubview:bodyView];
    [self.view addSubview:headerView];
    [self.view addSubview:titleLabel];
    [self.view addSubview:dateLabel];
    [self.view addSubview:associationLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track([@"News > " stringByAppendingString:self.newsItem.title]);
}

@end
