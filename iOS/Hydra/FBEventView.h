//
//  FBEventView.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 7/01/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HFBEvent.h"

@interface FBEventView : UIView

@property (strong, nonatomic) HFBEvent *event;

- (void)configureWithEvent:(HFBEvent*)event;
- (void)reloadData;
@end
