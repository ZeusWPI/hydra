//
//  ActivityDetailViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AssociationActivity;

@interface ActivityDetailViewController : UITableViewController

- (id)initWithActivity:(AssociationActivity *)activity;

@end
