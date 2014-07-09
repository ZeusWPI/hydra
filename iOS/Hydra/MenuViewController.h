//
//  MenuViewController.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 8/07/14.
//  Copyright (c) 2014 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController

@end

@interface MenuObject : NSObject
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) Class viewController;

- (MenuObject*)initWithImage:(NSString *)image andTitle:(NSString *)title andController:(Class)controller;
- (UIViewController *)controller;
@end