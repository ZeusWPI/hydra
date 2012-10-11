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
    
    //Code for hiding navigationBar but it's not working
    //[[self navigationController] setNavigationBarHidden:YES];
     
    // Do any additional setup after loading the view.
    
    NSString *html = [@"<h1>" stringByAppendingString:self.article.title];
    html = [html stringByAppendingString:@"</h1><small>"];
    //Date needs to be configured to send the date
    // html = [html stringByAppendingString:[self formatDate:article.date]];
    html = [html stringByAppendingString:@"Okt 12, 2012"];
    html = [html stringByAppendingString:@"   --   "];
    html = [html stringByAppendingString:self.article.author];
    html = [html stringByAppendingString:@"</small>"];
    html = [html stringByAppendingString:self.article.body];
    
    [self.webView loadHTMLString: html baseURL:nil];
}

@end
