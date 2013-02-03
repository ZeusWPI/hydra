//
//  InfoPageControl.m
//  Hydra
//
//  Created by Pieter De Baets on 25/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "InfoPageControl.h"

#define kInfoLabelTag 301

@implementation InfoPageControl

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    [super setNumberOfPages:numberOfPages];

    UIImageView *firstItem = self.subviews[0];
    [[firstItem viewWithTag:kInfoLabelTag] removeFromSuperview];

    CGRect labelFrame = CGRectInset(firstItem.bounds, 0, -2);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.font = [UIFont fontWithName:@"Verdana-Bold" size:11];
    label.text = @"?";
    label.textColor = [UIColor colorWithWhite:1 alpha:0.45];
    label.highlightedTextColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.tag = kInfoLabelTag;

    [firstItem addSubview:label];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self updateCustomIndicator];
}

- (void)updateCurrentPageDisplay
{
    [super updateCurrentPageDisplay];
    [self updateCustomIndicator];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    // When dots are directly tapped
    [super endTrackingWithTouch:touch withEvent:event];
    [self updateCustomIndicator];
}

- (void)updateCustomIndicator
{
    if (self.subviews.count > 0) {
        UIImageView *firstItem = self.subviews[0];
        firstItem.image = nil;
        firstItem.highlightedImage = nil;

        UILabel *label = (UILabel *)[firstItem viewWithTag:kInfoLabelTag];
        label.highlighted = (self.currentPage == 0);
    }
}

@end
