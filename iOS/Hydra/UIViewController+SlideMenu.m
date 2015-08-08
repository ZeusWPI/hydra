//
//  UIViewController+SlideMenu.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

#import "UIViewController+SlideMenu.h"

@implementation UIViewController (SlideMenu)

- (void) H_setSlideMenuButton
{
    if (self==[self.navigationController.viewControllers objectAtIndex:0]) {
        UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"MENU"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(H_openSlideMenu:)];
        
        self.navigationItem.leftBarButtonItems = @[menuButtonItem];
    }
}

- (void)H_openSlideMenu:(id)sender
{
    [self.revealController showViewController:self.revealController.leftViewController];
}

@end
