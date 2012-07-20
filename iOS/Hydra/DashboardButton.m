//
//  DashboardButton.m
//  Hydra
//
//  Created by Yasser Deceukelier on 20/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "DashboardButton.h"
#import <QuartzCore/QuartzCore.h>

#define kBadgeRadius 12
#define kBadgeFontSize 10;

@implementation DashboardButton
{
    //two layer 1 text & 1 badge, so the text can be centerd in the badge
    __unsafe_unretained CATextLayer *_textLayer;
    __unsafe_unretained CALayer *_badgeLayer; //no __weak, because not supported on iOS 4
}

#pragma mark - Badge properties

- (NSString *)badgeText {
    
    return [_textLayer string];
}

- (void)setBadgeText:(NSString *)badgeText {
    
    [_textLayer setString:badgeText];
    
    //calculate frames for layers;
    
    _badgeLayer.hidden = (badgeText ? NO : YES);
}

- (void)setBadgeNumber:(int)number {
    
    [self setBadgeText:[NSString stringWithFormat:@"%d", number]];
}

#pragma mark - Badge setup

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        [self setupBadgeLayers];
    }
    return self;
}

- (void)awakeFromNib {
    
    [self setupBadgeLayers];
}

- (void)setupBadgeLayers {
    
    CALayer *badgeLayer = [CALayer layer];
    badgeLayer.cornerRadius = kBadgeRadius;
    badgeLayer.backgroundColor = [UIColor redColor].CGColor;
    badgeLayer.borderWidth = 2;
    badgeLayer.borderColor = [UIColor whiteColor].CGColor;
    badgeLayer.hidden = YES;
    [self.layer addSublayer:badgeLayer];
    _badgeLayer = badgeLayer;
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.fontSize = kBadgeFontSize;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.wrapped = YES;
    [badgeLayer addSublayer:textLayer];
    _textLayer = textLayer;
    
    [self setBadgeNumber:2];
}

@end
