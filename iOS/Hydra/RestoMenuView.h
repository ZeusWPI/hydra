//
//  RestoMenuView.h
//  Hydra
//
//  Created by Yasser Deceukelier on 22/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestoMenu.h"

@interface RestoMenuView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RestoMenu *menu;

- (id)initWithRestoMenu:(RestoMenu *)menu andDate:(NSDate *)date;

@end
