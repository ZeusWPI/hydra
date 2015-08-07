//
//  MenuViewController.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController

@end

@interface MenuObject : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) Class viewController;

- (MenuObject*)initWithTitle:(NSString *)title andController:(Class)controller;
- (UIViewController *)controller;
@end