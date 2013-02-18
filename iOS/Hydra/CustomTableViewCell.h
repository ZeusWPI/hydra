//
//  CustomTableViewCell.h
//  Hydra
//
//  Created by Pieter De Baets on 18/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL alignToTop;
@property (nonatomic, assign) BOOL forceCenter;

@property (nonatomic, unsafe_unretained) UIView *customView;

@end
