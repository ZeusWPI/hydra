//
//  CustomTableViewCell.m
//  Hydra
//
//  Created by Pieter De Baets on 18/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)setCustomView:(UIView *)customView
{
    if (customView != _customView) {
        if (_customView != nil) {
            [_customView removeFromSuperview];
        }
        if (customView != nil) {
            [self.contentView addSubview:customView];
        }
        _customView = customView;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Override vertical alignment
    if (self.alignToTop) {
        CGRect textLabelFrame = self.textLabel.frame;
        textLabelFrame.origin.y = 11;
        self.textLabel.frame = textLabelFrame;

        CGRect detailLabelFrame = self.detailTextLabel.frame;
        detailLabelFrame.origin.y = 10;
        self.detailTextLabel.frame = detailLabelFrame;
    }
}

@end
