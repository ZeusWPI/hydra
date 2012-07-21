//
//  DashboardButton.h
//  Hydra
//
//  Created by Yasser Deceukelier on 20/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgedButton : UIButton

@property (nonatomic, strong) NSString *badgeText;

- (void)setBadgeNumber:(int)number;

@end
