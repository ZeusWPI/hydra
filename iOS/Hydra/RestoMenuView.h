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

@property (readonly) RestoMenu *menu;

- (id)initWithRestoMenu:(RestoMenu *)menu;

@end
