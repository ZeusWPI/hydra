//
//  ActivityViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "ActivityViewController.h"
#import "AssociationStore.h"
#import "AssociationActivity.h"
#import "NSDate+Utilities.h"
#import "ActivityDetailViewController.h"

@interface ActivityViewController ()

@property (nonatomic, strong) NSArray *associations;
@property (nonatomic, strong) NSArray *days;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation ActivityViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.associations = [[AssociationStore sharedStore] associations];
        self.count = 0;
        [self refreshActivities];
    }
    return self;
}

- (void)refreshActivities
{
    AssociationStore *store = [AssociationStore sharedStore];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    // Store activities per day
    for (AssociationActivity *activity in [store allActivities]) {
        NSDate *day = [activity.start dateAtStartOfDay];
        NSMutableArray *activities = data[day];
        if (!activities) {
            data[day] = activities = [[NSMutableArray alloc] init];
        }
        [activities addObject:activity];
    }
    self.days = [[data allKeys] sortedArrayUsingSelector:@selector(compare:)];

    // Sort activities per day
    for (NSDate *date in self.days) {
        data[date] = [data[date] sortedArrayUsingComparator:^(AssociationActivity *obj1, AssociationActivity *obj2) {
            return [obj1.start compare:obj2.start];
        }];
    }
    self.data = data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Activiteiten";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activitiesUpdated:) name:AssociationStoreDidUpdateActivitiesNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)activitiesUpdated:(NSNotification *)notification
{
    [self refreshActivities];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.days.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *date = self.days[section];
    return [self.data[date] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d MMMM"];
    }
    return [dateFormatter stringFromDate:self.days[section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ActivityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    NSDate *date = self.days[indexPath.section];
    AssociationActivity *activity = self.data[date][indexPath.row];
    cell.textLabel.text = activity.title;
    cell.detailTextLabel.text = [activity.start description];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = self.days[indexPath.section];
    AssociationActivity *activity = self.data[date][indexPath.row];
    ActivityDetailViewController *detailViewController = [[ActivityDetailViewController alloc] initWithActivity:activity];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
