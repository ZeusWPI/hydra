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

@implementation DashboardButton
{
    __unsafe_unretained CATextLayer *badgeLayer; //geen __weak, want niet ondersteund op iOS 4
}

- (NSString *)badgeText {
    
    return [badgeLayer string];
}

- (void)setBadgeText:(NSString *)badgeText {
    
    [badgeLayer setString:badgeText];
    
    badgeLayer.frame = CGRectMake(-kBadgeRadius, -kBadgeRadius, 2*kBadgeRadius, 2*kBadgeRadius);

    badgeLayer.hidden = (badgeText ? NO : YES);
}

- (void)setBadgeNumber:(int)number {
    
    [self setBadgeText:[NSString stringWithFormat:@"%d", number]];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        [self setupBadgeLayer];
    }
    return self;
}

- (void)awakeFromNib {
    
    [self setupBadgeLayer];
}

- (void)setupBadgeLayer {
    
    badgeLayer = [CATextLayer layer];
    
    badgeLayer.cornerRadius = kBadgeRadius;
    badgeLayer.backgroundColor = [UIColor redColor].CGColor;
    badgeLayer.borderWidth = 2;
    badgeLayer.borderColor = [UIColor whiteColor].CGColor;
    badgeLayer.hidden = YES;
    
    badgeLayer.fontSize = 1.5*kBadgeRadius;
    badgeLayer.alignmentMode = kCAAlignmentCenter;
    badgeLayer.truncationMode = kCATruncationMiddle;
    badgeLayer.wrapped = YES;
    
    //TODO vertical alignment 
    
    [self.layer addSublayer:badgeLayer];
    
    [self setBadgeNumber:2];
}

@end
