//
//  MasterViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgedButton.h"

@interface DashboardViewController : UIViewController

@property (nonatomic, assign) IBOutlet BadgedButton *newsButton;
@property (nonatomic, assign) IBOutlet BadgedButton *activitiesButton;
@property (nonatomic, assign) IBOutlet BadgedButton *infoButton;
@property (nonatomic, assign) IBOutlet BadgedButton *restoButton;
@property (nonatomic, assign) IBOutlet BadgedButton *gsrButton;
@property (nonatomic, assign) IBOutlet BadgedButton *schamperButton;

- (IBAction)showNews:(id)sender;
- (IBAction)showActivities:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showResto:(id)sender;
- (IBAction)showSchamper:(id)sender;
- (IBAction)showFeedbackView:(id)sender;

@end
