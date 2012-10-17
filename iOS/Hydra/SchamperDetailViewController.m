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
    NSLog(@"Date: %@",self.article.date.description);
    NSString *html = [@"<head><link rel='stylesheet' type='text/css' href='schamper.css' /></head><body><h1>" stringByAppendingString:self.article.title];
    html = [html stringByAppendingString:@"</h1><div class='authorAndDate'>"];
    //Date needs to be configured to send the date
    html = [html stringByAppendingString:[self formatDate:self.article.date]];
    html = [html stringByAppendingString:@" door "];
    html = [html stringByAppendingString:self.article.author];
    html = [html stringByAppendingString:@"</div><div class='content'"];
    html = [html stringByAppendingString:self.article.body];
    html = [html stringByAppendingString:@"</div></body>"];

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];

    [self.webView loadHTMLString: html baseURL: baseURL];
}

 - (NSString *) formatDate: (NSDate *) date {
     // returns temporary today instead of the publishing date because it has a NULL value!!!
     // needs to be like "13 oktober 2012 om 22.57 uur"
     NSLocale *dutch = [[NSLocale alloc] initWithLocaleIdentifier:@"nl_NL"];
     NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"dd MMMM YYYY om hh.mm uur" options:0 locale:dutch];
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:formatString];


     NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];
     NSLog(@"todayString: %@", todayString);
     return todayString;
 }
 


@end
