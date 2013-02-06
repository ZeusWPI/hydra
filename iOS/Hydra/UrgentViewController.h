//
//  UrgentViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 05/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UrgentViewController : UIViewController

@property (nonatomic, unsafe_unretained) IBOutlet UIButton *playButton;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *showLabel;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *songLabel;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *previousSongLabel;

- (IBAction)playButtonTapped:(id)sender;

@end