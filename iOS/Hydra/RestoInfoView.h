//
//  RestoInfoView.h
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestoMenu.h"

@interface RestoInfoView : UIView

- (id)initWithFrame:(CGRect)frame;
- (void)configure;
- (void)configureWithArray:(NSMutableArray*)array;
@end
