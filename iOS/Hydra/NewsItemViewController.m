//
//  NewsItemViewController.m
//  Hydra
//
//  Created by Matthias Lemmens on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "NewsItemViewController.h"

@interface NewsItemViewController ()

@end

@implementation NewsItemViewController

- (id) initWithBody: (NSString *) body{
    self = [super init];
    if (self) {
        UITextView *textField = [[UITextView alloc] initWithFrame:self.view.frame];
        textField.text = body;
        [self.view addSubview:textField];
    }
    return self;
}

@end
