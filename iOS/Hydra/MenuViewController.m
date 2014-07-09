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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createControllers
{
    MenuObject *dashboard = [[MenuObject alloc] initWithImage:nil
                                                     andTitle:@"Dashboard"
                                                andController:[DashboardViewController class]];
    
    MenuObject *news = [[MenuObject alloc] initWithImage:nil
                                                andTitle:@"News"
                                           andController:[NewsViewController class]];
    
    MenuObject *activities = [[MenuObject alloc] initWithImage:nil
                                                      andTitle:@"Activities"
                                                 andController:[ActivitiesController class]];
    
    MenuObject *info = [[MenuObject alloc] initWithImage:nil
                                                andTitle:@"Info" andController:[InfoViewController class]];
    
    MenuObject *resto = [[MenuObject alloc] initWithImage:nil
                                                 andTitle:@"Resto Menu"
                                            andController:[RestoMenuController class]];
    
    MenuObject *urgent = [[MenuObject alloc] initWithImage:nil
                                                  andTitle:@"Urgent.fm"
                                             andController:[UrgentViewController class]];
    
    MenuObject *schamper = [[MenuObject alloc] initWithImage:nil
                                                    andTitle:@"Schamper"
                                               andController:[SchamperViewController class]];
    
    MenuObject *preferences = [[MenuObject alloc] initWithImage:nil
                                                       andTitle:@"Preferences"
                                                  andController:[PreferencesController class]];
    
    NSArray *controllers = [[NSArray alloc] initWithObjects:dashboard, news, activities,
                            info, resto, urgent, schamper, preferences, nil];
    
    self.controllers = controllers;
}

#pragma mark - Table view delegate

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
    static NSString *MenuCellIdentifier = @"ActivityCellNoHighlight";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:MenuCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MenuCellIdentifier];
        [self setupCell:cell];
        
    }
    
    MenuObject *menuItem = self.controllers[indexPath.row];
    [cell.textLabel setText:menuItem.title];
   
    return cell;
}

- (void)setupCell:(UITableViewCell *)cell
{
    //TODO
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
