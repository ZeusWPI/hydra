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
#import "Association.h"
#import "NSDate+Utilities.h"
#import "ActivityDetailViewController.h"

#define kCellTitleLabel 101
#define kCellSubtitleLabel 102

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

    // Group activities by day
    NSDate *now = [NSDate date];
    NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];

    for (AssociationActivity *activity in [store allActivities]) {
        NSDate *day = [activity.start dateAtStartOfDay];

        // Check that activity is not over yet
        if (!activity.end || [activity.end isEarlierThanDate:now]) continue;

        NSMutableArray *activities = groups[day];
        if (!activities) {
            groups[day] = activities = [[NSMutableArray alloc] init];
        }
        [activities addObject:activity];
    }

    self.days = [[groups allKeys] sortedArrayUsingSelector:@selector(compare:)];

    // Sort activities per day
    for (NSDate *date in self.days) {
        groups[date] = [groups[date] sortedArrayUsingComparator:
                            ^(AssociationActivity *obj1, AssociationActivity *obj2) {
                                return [obj1.start compare:obj2.start];
                            }];
    }

    self.data = groups;
    [self.tableView reloadData];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // TODO: add calendar icon here to switch to dates faster
}

#pragma mark - Table view delegate

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *titleLabel, *subtitleLabel;

	static NSString *CellIdentifier = @"ActivityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];

        CGRect titleFrame = CGRectMake(60, 5, 250, 20);
        titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.tag = kCellTitleLabel;
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        titleLabel.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:titleLabel];

        CGRect subtitleFrame = CGRectMake(60, 25, 250, 16);
        subtitleLabel = [[UILabel alloc] initWithFrame:subtitleFrame];
        subtitleLabel.tag = kCellSubtitleLabel;
        subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        subtitleLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        subtitleLabel.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:subtitleLabel];
    }
    else {
        titleLabel = (UILabel *)[cell viewWithTag:kCellTitleLabel];
        subtitleLabel = (UILabel *)[cell viewWithTag:kCellSubtitleLabel];
    }

    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH.mm"];
    }

    NSDate *date = self.days[indexPath.section];
    AssociationActivity *activity = self.data[date][indexPath.row];

    cell.textLabel.text = [dateFormatter stringFromDate:activity.start];
    titleLabel.text = activity.title;
    subtitleLabel.text = activity.associationId;
    //subtitleLabel.text = activity.association.displayName;

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
