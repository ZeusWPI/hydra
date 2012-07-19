//
//  RestoViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestoViewController : UIViewController <UIScrollViewDelegate> {
    NSMutableArray *days;
    NSMutableArray *menus;
    NSUInteger pageControlUsed;

    IBOutlet UIPageControl *pageControl;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *infoPage;
}

- (IBAction)pageChanged:(id)sender;

@end
