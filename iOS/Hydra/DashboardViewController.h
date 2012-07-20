//
//  MasterViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController <UITextFieldDelegate> {
    UISwipeGestureRecognizer *gestureRecognizer;
    UITextField *codeField;
    NSArray *requiredMoves;
    NSUInteger movesPerformed;
}

- (IBAction)showNews:(id)sender;
- (IBAction)showActivities:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showResto:(id)sender;
- (IBAction)showSchamper:(id)sender;

@end
