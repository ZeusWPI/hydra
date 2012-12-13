//
//  NewsItemViewController.h
//  Hydra
//
//  Created by Matthias Lemmens on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssociationNewsItem.h"

@interface NewsItemViewController : UIViewController

- (id) initWithNewsItem:(AssociationNewsItem *)newsItem;

@end
