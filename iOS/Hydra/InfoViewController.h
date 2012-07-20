//
//  InfoViewController.h
//  Hydra
//
//  Created by Yasser Deceukelier on 19/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UITableViewController {
    NSArray *content;
}

- (id)init;
- (id)initWithContent:(NSArray *)content;

@end
