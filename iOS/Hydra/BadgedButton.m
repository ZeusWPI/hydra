//
//  DashboardButton.m
//  Hydra
//
//  Created by Yasser Deceukelier on 20/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "BadgedButton.h"
#import <QuartzCore/QuartzCore.h>

#define kBadgeFontSize 15

@implementation BadgedButton
{
    // two layer 1 text & 1 badge, so the text can be centerd in the badge
    // no __weak, because not supported on iOS 4
    __unsafe_unretained CATextLayer *_textLayer;
    __unsafe_unretained CALayer *_badgeLayer;
    
    UIFont *badgeFont;
    CGFloat badgeHeight;
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
    CGFloat textWidth = MAX(textSize.height, textSize.width);
    CGRect textFrame = CGRectMake(0, badgeHeight -textSize.height, textWidth, textSize.height);
    
    CGFloat badgeWidth = ([_textLayer.string length] > 1 ? textWidth+badgeHeight/2 : badgeHeight);
    textFrame.origin.x = (badgeWidth -textWidth)/2;
    _textLayer.frame = textFrame;
    
    CGRect badgeFrame = CGRectMake(self.frame.size.width -2*badgeWidth/3, -badgeHeight/3, badgeWidth, badgeHeight);
    _badgeLayer.frame = badgeFrame;

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:_badgeLayer.bounds cornerRadius:_badgeLayer.cornerRadius];
    _badgeLayer.shadowPath = shadowPath.CGPath;

    _badgeLayer.hidden = (badgeText ? NO : YES);
}

- (void)setBadgeNumber:(int)number
{
    if(number != 0) {
    	[self setBadgeText:[NSString stringWithFormat:@"%d", number]];
    } else {
        [self setBadgeText:nil];
    }
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
    // Is it also visible on an actual device or just in the simulator???
    
    badgeFont = [UIFont boldSystemFontOfSize:kBadgeFontSize];
    CGFloat newlineSpace = [badgeFont lineHeight] - [badgeFont ascender];
    badgeHeight = [badgeFont lineHeight] + newlineSpace;
    
    CAGradientLayer *badgeLayer = [CAGradientLayer layer];
    badgeLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithRed:1 green:.5 blue:.5 alpha:1].CGColor,
                         (id)[UIColor colorWithRed:.8 green:0 blue:0 alpha:1].CGColor, nil];
    badgeLayer.cornerRadius = badgeHeight/2;
    badgeLayer.borderWidth = 2;
    badgeLayer.borderColor = [UIColor whiteColor].CGColor;
    badgeLayer.hidden = YES;
    badgeLayer.shadowColor = [[UIColor blackColor] CGColor];	//Note: ca shadows may slow down scrolling on actual devices, no problem as long as scrolling (or rotation isn't enabled in the Dashboard
    badgeLayer.shadowOpacity = 0.5;
    badgeLayer.shadowOffset = CGSizeMake(0, 4.0);
    [self.layer addSublayer:badgeLayer];
    _badgeLayer = badgeLayer;

    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.wrapped = YES;
    textLayer.fontSize = kBadgeFontSize;
   
    CGFontRef cgFont = CGFontCreateWithFontName((__bridge CFStringRef)badgeFont.fontName);
    textLayer.font = cgFont;
    CGFontRelease(cgFont);
    
    [badgeLayer addSublayer:textLayer];
    _textLayer = textLayer;
}

@end
