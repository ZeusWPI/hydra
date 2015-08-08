//
//  MenuViewController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

#import "MenuViewController.h"

#import <MessageUI/MessageUI.h>

#import "Hydra-Swift.h"

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
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = [self createHeaderView];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.92549 alpha:1.0];
    self.tableView.tableFooterView = [[UIView alloc] init]; // Fixes seperator lines in empty cells
    //self.tableView.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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
    MenuObject *dashboard = [[MenuObject alloc] initWithTitle:@"Home"
                                                andController:[HomeViewController class]];
    
    MenuObject *news = [[MenuObject alloc] initWithTitle:@"Nieuws"
                                           andController:[NewsViewController class]];
    
    MenuObject *activities = [[MenuObject alloc] initWithTitle:@"Activiteiten"
                                                 andController:[ActivitiesController class]];
    
    MenuObject *info = [[MenuObject alloc] initWithTitle:@"Info"
                                           andController:[InfoViewController class]];
    
    MenuObject *resto = [[MenuObject alloc] initWithTitle:@"Resto Menu"
                                            andController:[RestoMenuController class]];
    
    MenuObject *urgent = [[MenuObject alloc] initWithTitle:@"Urgent.fm"
                                             andController:[UrgentViewController class]];
    
    MenuObject *schamper = [[MenuObject alloc] initWithTitle:@"Schamper Daily"
                                               andController:[SchamperViewController class]];
    
    MenuObject *preferences = [[MenuObject alloc] initWithTitle:@"Voorkeuren"
                                                  andController:[PreferencesController class]];
    
    NSArray *controllers = [[NSArray alloc] initWithObjects:dashboard, news, activities,
                            info, resto, urgent, schamper, preferences, nil];
    
    self.controllers = controllers;
}

- (UIView *)createHeaderView
{
    // Create header background
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 91)];
    
    // Add seperator
    CGRect sepFrame = CGRectMake(0, headerView.frame.size.height-1, self.view.bounds.size.width, 0.5);
    UIView *seperatorView = [[UIView alloc] initWithFrame:sepFrame];
    seperatorView.backgroundColor = [UIColor colorWithWhite:0.92549 alpha:1.0];
    [headerView addSubview:seperatorView];
    
    //TODO: add close button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(50, 30.5, 30, 30);
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(0, 30)];
    [bezierPath addLineToPoint: CGPointMake(15, 15)];
    [bezierPath addLineToPoint: CGPointMake(30, 0)];
    [bezierPath addLineToPoint: CGPointMake(15, 15)];
    [bezierPath addLineToPoint: CGPointMake(30, 30)];
    [bezierPath addLineToPoint: CGPointMake(0, 0)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [bezierPath stroke];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = button.bounds;
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;//[UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.lineWidth = 3;
    button.layer.mask = shapeLayer;
    
    [headerView addSubview:button];
    
    return headerView;
}

#pragma mark - Table view delegate
#define kTitleTag 234

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
    return 62;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Do not use identifiers because every cell is placed on the screen
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [self setupCell:cell];
    
    MenuObject *menuItem = self.controllers[indexPath.row];
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:kTitleTag];
    [titleLabel setText: menuItem.title];
    
    return cell;
}

- (void)setupCell:(UITableViewCell *)cell
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // Style cell
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = cell.contentView;
    
    // Add cell attributes
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setTag:kTitleTag];
    [titleLabel setFont:[UIFont systemFontOfSize:20.0 weight:UIFontWeightLight]]; //TODO: find better font
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor colorWithWhite:0.0862745 alpha:1.0]];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:titleLabel];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(titleLabel);
    
    // Use auto-layout to place the cells
    NSArray *horizontalLayoutConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"|-50-[titleLabel]|"
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
    [contentView addConstraints:verticalTitleConstraint];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *root;
    UIViewController *c = [self.controllers[indexPath.row] controller];
    if ([c isKindOfClass:[HomeViewController class]]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        root = [storyboard instantiateInitialViewController];
    } else {
        root = [[UINavigationController alloc] initWithRootViewController:c];
    }
    [self.revealController setFrontViewController:root];
    [self.revealController resignPresentationModeEntirely:NO animated:YES completion:nil];
}

#pragma mark Header button
- (void) closeButton:(UIButton *)button
{
    [self.revealController showViewController:self.revealController.frontViewController];
}

@end

#pragma mark MenuObject
@implementation MenuObject

- (MenuObject *)initWithTitle:(NSString *)title andController:(Class)controller
{
    self = [super init];
    if(self) {
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
