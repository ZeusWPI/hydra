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

@property (nonatomic, unsafe_unretained) IBOutlet BadgedButton *newsButton;
@property (nonatomic, unsafe_unretained) IBOutlet BadgedButton *activitiesButton;
@property (nonatomic, unsafe_unretained) IBOutlet BadgedButton *infoButton;
@property (nonatomic, unsafe_unretained) IBOutlet BadgedButton *restoButton;
@property (nonatomic, unsafe_unretained) IBOutlet BadgedButton *urgentButton;
@property (nonatomic, unsafe_unretained) IBOutlet BadgedButton *schamperButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *feedbackButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *preferencesButton;

- (IBAction)showNews:(id)sender;
- (IBAction)showActivities:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showResto:(id)sender;
- (IBAction)showUrgent:(id)sender;
- (IBAction)showSchamper:(id)sender;
- (IBAction)showFeedbackView:(id)sender;
- (IBAction)showFacebook:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
