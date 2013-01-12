//
//  NewsItemViewController.m
//  Hydra
//
//  Created by Matthias Lemmens on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "NewsItemViewController.h"

@interface NewsItemViewController ()

@property (nonatomic, strong) AssociationNewsItem *newsItem;

@end

@implementation NewsItemViewController

- (id) initWithNewsItem:(AssociationNewsItem *)newsItem {
    self = [super init];
    if (self) {
        self.newsItem = newsItem;
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"Nieuwsbericht";

    // Body
    UITextView *bodyField = [[UITextView alloc] initWithFrame:self.view.bounds];
    bodyField.autoresizingMask = UIViewAutoresizingFlexibleWidth
                               | UIViewAutoresizingFlexibleHeight;
    bodyField.editable = NO;
    bodyField.font = [UIFont systemFontOfSize:14.0f];

    bodyField.dataDetectorTypes = UIDataDetectorTypeLink
                                | UIDataDetectorTypePhoneNumber
                                | UIDataDetectorTypeAddress;
    bodyField.text = self.newsItem.body;
    [self.view addSubview:bodyField];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track([@"News > " stringByAppendingString:self.newsItem.title]);
}

@end
