//
//  UINavigationController+ReplaceController.h
//  Hydra
//
//  Created by Pieter De Baets on 18/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (ReplaceController)

- (void)H_replaceViewControllerWith:(UIViewController *)controller options:(UIViewAnimationOptions)options;

@end
