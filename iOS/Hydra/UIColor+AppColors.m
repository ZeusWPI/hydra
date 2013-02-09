//
//  UIColor+AppColors.m
//  Hydra
//
//  Created by Pieter De Baets on 19/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "UIColor+AppColors.h"

@implementation UIColor (AppColors)

+ (UIColor *)hydraTintColor
{
    // #204E80
    return [UIColor colorWithRed:0.126 green:0.304 blue:0.500 alpha:1.000];
}

+ (UIColor *)hydraBackgroundColor
{
    // #CED6E0
    return [UIColor colorWithRed:0.807 green:0.840 blue:0.878 alpha:1.000];
}

+ (UIColor *)H_detailLabelTextColor
{
    // #385487
    return [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
}

+ (UIColor *)H_hintColor
{
    return [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1];
}

@end
