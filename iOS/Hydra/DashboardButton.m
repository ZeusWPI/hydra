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
    //two layer 1 text & 1 badge, so the text can be centerd in the badge
    __unsafe_unretained CATextLayer *_textLayer;
    __unsafe_unretained CALayer *_badgeLayer; //no __weak, because not supported on iOS 4
    UIFont *badgeFont;
}

#pragma mark - Badge properties

- (NSString *)badgeText {
    
    return [_textLayer string];
}

- (void)setBadgeText:(NSString *)badgeText {
    
    [_textLayer setString:badgeText];
    
    
    //under development!!!
    CGSize textSize = [badgeText sizeWithFont:badgeFont];
    CGFloat edge = textSize.height/3;
    CGRect textFrame = CGRectMake(edge, edge, textSize.width, textSize.height);
    _textLayer.frame = textFrame;
    
    CGFloat width = MAX(textSize.height, textSize.width) +2*edge;
    CGFloat height = textSize.height +edge; //only once because some spacing is included in textSize
    CGRect badgeFrame = CGRectMake(-width/4, -height/2, width, height);
    _badgeLayer.cornerRadius = height/2;
    _badgeLayer.frame = badgeFrame;
    //end under development!!!
    
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
    badgeLayer.backgroundColor = [UIColor redColor].CGColor;
    badgeLayer.borderWidth = 3;
    badgeLayer.borderColor = [UIColor whiteColor].CGColor;
    badgeLayer.hidden = YES;
    [self.layer addSublayer:badgeLayer];
    _badgeLayer = badgeLayer;
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.alignmentMode = kCAAlignmentRight;
    textLayer.wrapped = YES;
    
    textLayer.fontSize = kBadgeFontSize;
    badgeFont = [UIFont boldSystemFontOfSize:textLayer.fontSize];
    CGFontRef cgFont = CGFontCreateWithFontName((__bridge CFStringRef)badgeFont.fontName);
    textLayer.font = cgFont;
    CGFontRelease(cgFont);
    
    [badgeLayer addSublayer:textLayer];
    _textLayer = textLayer;
    
    //_textLayer.borderWidth = 1;
    
    [self setBadgeText:@"1"];
}

@end
