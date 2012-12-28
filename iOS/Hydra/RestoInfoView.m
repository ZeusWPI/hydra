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
#import "RestoLegendView.h"
#import "AppDelegate.h"

@interface RestoInfoView ()

@property (nonatomic, unsafe_unretained) UIActivityIndicatorView *spinner;

@end

@implementation RestoInfoView

#pragma mark - Properties and init

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)createView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // background
    UIImage *background = [UIImage imageNamed:@"header-bg.png"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundView.image = background;
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    backgroundView.autoresizingMask = self.autoresizingMask;
    [self addSubview:backgroundView];

    // logo
    UIImage *logo = [UIImage imageNamed:@"resto-logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];
    [imageView setFrame:CGRectMake(90, 20, 100, 100)];
    [self addSubview:imageView];

    // resto info
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 133, 240, 80)];
    infoLabel.text = @"De resto's van de UGent zijn elke weekdag open van 11u15 tot 14u. 's Avonds kan je ook terecht in resto De Brug van 17u30 tot 21u.";
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.font = [UIFont systemFontOfSize:15];
    infoLabel.textAlignment = UITextAlignmentCenter;
    infoLabel.numberOfLines = 4;
    [self addSubview:infoLabel];

    // map button
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mapButton.frame = CGRectMake(40, 260, 67, 30);
    [mapButton setTitle:@"Kaart" forState:UIControlStateNormal];
    [self addSubview:mapButton];
    self.mapButton = mapButton;
    
    // legende button
    UIButton *legendeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    legendeButton.frame = CGRectMake(100, 250, 67, 30);
    [legendeButton setTitle:@"Legende" forState:UIControlStateNormal];
    [legendeButton addTarget:self action:@selector(legendeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:legendeButton];

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
{;
    DLog(@"Infoview legende button pressed");
    RestoLegendView *legendView = [[RestoLegendView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
    //TODO ROUNDED CORNERS
    [self addSubview:legendView];
    
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
