//
//  InfoWebViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 17/09/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "InfoWebViewController.h"

#define kCachingBaseURL @"http://kelder.zeus.ugent.be/~feliciaan/hydra/1.0/info/"

@interface InfoWebViewController ()

@property (nonatomic, strong) NSString *path;

@end

@implementation InfoWebViewController



- (void)loadHtml:(NSString *)path
{
    // Trigger view laod
    [self view];

    self.path = path;

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kCachingBaseURL, path]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    [self.webView loadRequest:request];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error WebView: %@",error.localizedDescription);

    NSString *path = [[NSBundle mainBundle] pathForResource:self.path ofType:nil];
    if (path) {
        [super loadHtml:self.path];
    }
}
@end
