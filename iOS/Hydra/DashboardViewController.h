//
//  MasterViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgedButton.h"

@interface DashboardViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet BadgedButton *newsButton;
    IBOutlet BadgedButton *activitiesButton;
    IBOutlet BadgedButton *infoButton;
    IBOutlet BadgedButton *restoButton;
    IBOutlet BadgedButton *gsrButton;
    IBOutlet BadgedButton *schamperButton;
}

- (IBAction)showNews:(id)sender;
- (IBAction)showActivities:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showResto:(id)sender;
- (IBAction)showSchamper:(id)sender;

@end
