//
//  DashboardButton.m
//  Hydra
//
//  Created by Yasser Deceukelier on 20/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "DashboardButton.h"
#import <QuartzCore/QuartzCore.h>

#define kBadgeFontSize 15

@implementation DashboardButton
{
    // two layer 1 text & 1 badge, so the text can be centerd in the badge
    // no __weak, because not supported on iOS 4
    __unsafe_unretained CATextLayer *_textLayer;
    __unsafe_unretained CALayer *_badgeLayer;
    UIFont *badgeFont;
}

#pragma mark - Badge properties

- (NSString *)badgeText
{
    return [_textLayer string];
}

- (void)setBadgeText:(NSString *)badgeText
{
    [_textLayer setString:badgeText];
    
    //under development!!!
    CGSize textSize = [badgeText sizeWithFont:badgeFont];
    CGFloat edge = textSize.height/3;
    
    // edge is counted only once because some spacing is included in textSize
    CGFloat height = textSize.height + edge;
    CGFloat width = MAX(height, textSize.width + 2*edge);
    _badgeLayer.frame = CGRectMake(self.frame.size.width - 3*width/4, -height/4,
                                   width, height);
    _badgeLayer.cornerRadius = height/2;
    _badgeLayer.shadowRadius = height/2;

    CGRect textFrame = CGRectMake(0, edge, width, textSize.height);
    _textLayer.frame = textFrame;
    //end under development!!!

    _badgeLayer.hidden = (badgeText ? NO : YES);
}

- (void)setBadgeNumber:(int)number
{
    [self setBadgeText:[NSString stringWithFormat:@"%d", number]];
}

#pragma mark - Badge setup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupBadgeLayers];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupBadgeLayers];
}

- (void)setupBadgeLayers
{
    // Somehow the red background is peeking through the border??
    CALayer *badgeLayer = [CALayer layer];
    badgeLayer.backgroundColor = [UIColor redColor].CGColor;
    badgeLayer.borderWidth = 2;
    badgeLayer.borderColor = [UIColor whiteColor].CGColor;
    badgeLayer.hidden = YES;
    badgeLayer.shadowColor = [[UIColor blackColor] CGColor];
    badgeLayer.shadowOpacity = 0.5;
    badgeLayer.shadowOffset = CGSizeMake(0, 2.0);
    [self.layer addSublayer:badgeLayer];
    _badgeLayer = badgeLayer;

    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.wrapped = YES;
    textLayer.fontSize = kBadgeFontSize;
    badgeFont = [UIFont boldSystemFontOfSize:textLayer.fontSize];
    CGFontRef cgFont = CGFontCreateWithFontName((__bridge CFStringRef)badgeFont.fontName);
    textLayer.font = cgFont;
    CGFontRelease(cgFont);
    
    [badgeLayer addSublayer:textLayer];
    _textLayer = textLayer;

    [self setBadgeText:@"4"];
}

@end
