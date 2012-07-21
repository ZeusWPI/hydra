//
//  MasterViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgedButton.h"

@interface DashboardViewController : UIViewController <UITextFieldDelegate> 

@property (readonly) IBOutlet BadgedButton *newsButton;
@property (readonly) IBOutlet BadgedButton *activitiesButton;
@property (readonly) IBOutlet BadgedButton *infoButton;
@property (readonly) IBOutlet BadgedButton *restoButton;
@property (readonly) IBOutlet BadgedButton *gsrButton;
@property (readonly) IBOutlet BadgedButton *schamperButton;

- (IBAction)showNews:(id)sender;
- (IBAction)showActivities:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showResto:(id)sender;
- (IBAction)showSchamper:(id)sender;

@end
