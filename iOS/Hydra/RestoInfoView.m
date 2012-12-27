//
//  RestoInfoView.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoInfoView.h"
#import "RestoLegend.h"
#import "RestoMapViewController.h"
#import "AppDelegate.h"

@interface RestoInfoView ()

@property (nonatomic, unsafe_unretained) UIActivityIndicatorView *spinner;

@end

@implementation RestoInfoView

#pragma mark - Properties and init

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        self.legends = [[NSMutableArray alloc] initWithCapacity:0];
        [self createView];
    }
    return self;
}

- (void)createView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // background
    UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:@"header-bg.png"] drawInRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.backgroundColor = [UIColor colorWithPatternImage:image];

    // logo
    UIImage *restoLogo = [UIImage imageNamed:@"resto-logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:restoLogo];
    [imageView setFrame:CGRectMake(90, 20, 100, 100)];

    [self addSubview:imageView];
    [self sendSubviewToBack:imageView];

    // resto info label
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 133, 240, 80)];
    infoLabel.text = @"De resto's van de UGent zijn elke weekdag open van 11u15 tot 14u. 's Avonds kan je ook terecht in resto De Brug van 17u30 tot 21u.";
    infoLabel.numberOfLines = 4;
    [self createLabel:infoLabel];
    [self addSubview:infoLabel];

    // map button
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mapButton.frame = CGRectMake(100, 210, 67, 30);
    [mapButton setTitle:@"Map" forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(mapButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mapButton];
    
    // legende button
    UIButton *legendeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    legendeButton.frame = CGRectMake(100, 250, 67, 30);
    [legendeButton setTitle:@"Legende" forState:UIControlStateNormal];
    [legendeButton addTarget:self action:@selector(legendeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:legendeButton];

    
    /*// resto legende label
    UILabel *legendeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,233,67,21)];
    legendeLabel.text = @"Legende";
    [self createLabel:legendeLabel];
    [legendeLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [legendeLabel sizeToFit];
    [self addSubview:legendeLabel];*/


    //spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.center;
    [self addSubview:spinner];
    self.spinner = spinner;
}

-(void)mapButtonPressed
{
    DLog(@"Infoview switching to Maps");
    UIViewController *c = [[RestoMapViewController alloc] init];
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [del.navController pushViewController:c animated:YES];
}

-(void)legendeButtonPressed
{
    DLog(@"Infoview legende button pressed");
}

- (void) createLabel:(UILabel* )label
{

    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label sizeToFit];
}
@end
