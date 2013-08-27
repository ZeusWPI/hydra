//
//  ActivityDetailViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AssociationActivity;

@protocol ActivityListDelegate <NSObject>

- (AssociationActivity *)activityBefore:(AssociationActivity *)current;
- (AssociationActivity *)activityAfter:(AssociationActivity *)current;
- (void)didSelectActivity:(AssociationActivity *)activity;

@end

@interface ActivityDetailController : UITableViewController

- (id)initWithActivity:(AssociationActivity *)activity delegate:(id<ActivityListDelegate>)delegate;

@end
