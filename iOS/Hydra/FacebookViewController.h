//
//  FacebookViewController.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIButton *logInButton;
@property (nonatomic, assign) IBOutlet UIButton *logOutButton;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *spinner;

-(IBAction)loginButtonPressed:(id)sender;
-(IBAction)logoutButtonPressed:(id)sender;


@end
