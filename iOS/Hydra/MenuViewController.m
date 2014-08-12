//
//  MenuViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 8/07/14.
//  Copyright (c) 2014 Zeus WPI. All rights reserved.
//

#import "MenuViewController.h"

#import <MessageUI/MessageUI.h>

#import "DashboardViewController.h"
#import "ActivitiesController.h"
#import "InfoViewController.h"
#import "NewsViewController.h"
#import "PreferencesController.h"
#import "RestoMenuController.h"
#import "SchamperViewController.h"
#import "UrgentViewController.h"

@interface MenuViewController ()

@property (nonatomic, strong) NSArray *controllers;

@end

@implementation MenuViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [self createControllers];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Style & set-up tableview
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor hydraBackgroundColor];
    self.tableView.tableHeaderView = [self createHeaderView];
    self.tableView.separatorColor = [UIColor hydraTintColor];
    self.tableView.tableFooterView = [[UIView alloc] init]; // Fixes seperator lines in empty cells
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 45, 0, 0);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Menu");
    
    // Disable touch on frontviewcontroller
    [[self.revealController frontViewController].view setUserInteractionEnabled:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    // Re-enable touch on frontviewcontroller
    [[self.revealController frontViewController].view setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createControllers
{
    MenuObject *dashboard = [[MenuObject alloc] initWithImage:@"icon-dashboard"
                                                     andTitle:@"Dashboard"
                                                andController:[DashboardViewController class]];
    
    MenuObject *news = [[MenuObject alloc] initWithImage:@"icon-news"
                                                andTitle:@"Nieuws"
                                           andController:[NewsViewController class]];
    
    MenuObject *activities = [[MenuObject alloc] initWithImage:@"icon-activities"
                                                      andTitle:@"Activiteiten"
                                                 andController:[ActivitiesController class]];
    
    MenuObject *info = [[MenuObject alloc] initWithImage:@"icon-info"
                                                andTitle:@"Info"
                                           andController:[InfoViewController class]];
    
    MenuObject *resto = [[MenuObject alloc] initWithImage:@"icon-resto"
                                                 andTitle:@"Resto Menu"
                                            andController:[RestoMenuController class]];
    
    MenuObject *urgent = [[MenuObject alloc] initWithImage:@"icon-urgent"
                                                  andTitle:@"Urgent.fm"
                                             andController:[UrgentViewController class]];
    
    MenuObject *schamper = [[MenuObject alloc] initWithImage:@"icon-schamper"
                                                    andTitle:@"Schamper Daily"
                                               andController:[SchamperViewController class]];
    
    MenuObject *preferences = [[MenuObject alloc] initWithImage:@"icon-settings"
                                                       andTitle:@"Voorkeuren"
                                                  andController:[PreferencesController class]];
    
    NSArray *controllers = [[NSArray alloc] initWithObjects:dashboard, news, activities,
                            info, resto, urgent, schamper, preferences, nil];
    
    self.controllers = controllers;
}

- (UIView *)createHeaderView
{
    // Create header background
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 114)];
    headerView.backgroundColor = [UIColor blueColor];
    UIImage *background = [UIImage imageNamed:@"header-bg.png"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    backgroundView.image = background;
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [headerView addSubview:backgroundView];
    
    // place hydra logo
    UIImage *hydraLogo = [UIImage imageNamed:@"hydra-logo"];
    //UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(93, 37, 134, 50)];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(65, 37, 134, 50)];
    logoView.image = hydraLogo;
    logoView.contentMode = UIViewContentModeScaleToFill;
    logoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [headerView addSubview:logoView];
    
    return headerView;
}

#pragma mark - Table view delegate
#define kTitleTag 234
#define kImageTag 235
#define kImageTitleTag 236

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self controllers] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Do not use identifiers because every cell is placed on the screen
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [self setupCell:cell];
    
    MenuObject *menuItem = self.controllers[indexPath.row];
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:kTitleTag];
    [titleLabel setText: menuItem.title];
        
    if (menuItem.image) {
        UIImage *image = [UIImage imageNamed:menuItem.image];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageTag];
        imageView.image = image;
    }

    return cell;
}

- (void)setupCell:(UITableViewCell *)cell
{
    // Style cell
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = cell.contentView;
    
    // Add cell attributes
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setTag:kTitleTag];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor hydraTintColor]];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setTag:kImageTag];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeCenter;
    [contentView addSubview:imageView];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(titleLabel, imageView);
    
    // Use auto-layout to place the cells
    NSArray *horizontalLayoutConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[imageView(40)]-5-[titleLabel]|"
                                            options:0
                                            metrics:nil
                                              views:viewsDictionary
     ];
    
    NSArray *verticalImageViewConstraint =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|"
                                            options:0
                                            metrics:nil
                                              views:viewsDictionary
     ];
    
    NSArray *verticalTitleConstraint =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|"
                                            options:0
                                            metrics:nil
                                              views:viewsDictionary
     ];
    
    [contentView addConstraints:horizontalLayoutConstraints];
    [contentView addConstraints:verticalImageViewConstraint];
    [contentView addConstraints:verticalTitleConstraint];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *c = [self.controllers[indexPath.row] controller];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:c];
    [self.revealController setFrontViewController:nav];
    [self.revealController resignPresentationModeEntirely:NO animated:YES completion:nil];
}
@end

#pragma mark MenuObject
@implementation MenuObject

- (MenuObject *)initWithImage:(NSString *)image andTitle:(NSString *)title andController:(Class)controller
{
    self = [super init];
    if(self) {
        self.image = image;
        self.title = title;
        self.viewController = controller;
    }
    
    return self;
}

- (UIViewController *)controller
{
    return [[self.viewController alloc] init];
}

@end
