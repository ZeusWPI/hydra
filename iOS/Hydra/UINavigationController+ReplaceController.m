//
//  UINavigationController+ReplaceController.m
//  Hydra
//
//  Created by Pieter De Baets on 18/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "UINavigationController+ReplaceController.h"
#import <QuartzCore/QuartzCore.h>

@implementation UINavigationController (ReplaceController)

- (void)H_replaceViewControllerWith:(UIViewController *)controller options:(UIViewAnimationOptions)options
{
    [UIView transitionWithView:self.view duration:1.0 options:options
                    animations:^{
                        [self popViewControllerAnimated:NO];
                        [self pushViewController:controller animated:NO];

                        // Since UINavigationController seems to add animations even
                        // after being told not to.
                        for (UIView *child in self.navigationBar.subviews) {
                            [child.layer removeAllAnimations];
                        }
                    } completion:NULL];
}

@end
