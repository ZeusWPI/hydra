//
//  RestoMenuView.h
//  Hydra
//
//  Created by Yasser Deceukelier on 22/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestoMenu.h"

@interface RestoMenuView : UIView

- (id)initWithFrame:(CGRect)frame;
- (void)configureWithDay:(NSDate *)day andMenu:(RestoMenu *)menu;

@end
