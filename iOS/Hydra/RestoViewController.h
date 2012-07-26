//
//  RestoViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestoViewController : UIViewController <UIScrollViewDelegate> 

@property (readonly, nonatomic) NSInteger currentPage;

- (IBAction)pageChanged:(id)sender;

@end
