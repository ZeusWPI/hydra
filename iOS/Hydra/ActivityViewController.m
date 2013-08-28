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
#import "NSDateFormatter+AppLocale.h"
#import "PreferencesService.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define kCellTitleLabel 101
#define kCellSubtitleLabel 102

@interface ActivityViewController () <ActivityListDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray *days;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSArray *oldDays;
@property (nonatomic, strong) NSDictionary *oldData;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSUInteger previousSearchLength;

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UIPickerView *datePicker;

@end

@implementation ActivityViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.count = 0;
        [self loadActivities];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(activitiesUpdated:)
                       name:AssociationStoreDidUpdateActivitiesNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Activiteiten";

    // Switch dates using the calendar icon
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-calendar.png"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(dateButtonTapped:)];
    btn.enabled = self.days.count > 0;
    self.navigationItem.rightBarButtonItem = btn;

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;

    self.tableView.tableHeaderView = searchBar;
    
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor hydraTintColor];
        [refreshControl addTarget:self action:@selector(didPullRefreshControl:)
                 forControlEvents:UIControlEventValueChanged];

        self.refreshControl = refreshControl;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // Make sure we scroll with any selection that may have been set
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:NO];

    // Call super last, as it will clear the selection
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Activities");

    // Show loading indicator when no content is found yet
    if (self.days.count == 0) {
        [SVProgressHUD show];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didPullRefreshControl:(id)sender
{
    [[AssociationStore sharedStore] reloadActivities];
}

- (void)loadActivities
{
    NSArray *activities = [AssociationStore sharedStore].activities;

    // Filter activities
    PreferencesService *prefs = [PreferencesService sharedService];
    if (prefs.filterAssociations) {
        NSArray *associations = prefs.preferredAssociations;
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
            return [associations containsObject:[obj association].internalName] ||
                   [obj highlighted];
        }];
        activities = [activities filteredArrayUsingPredicate:pred];
    }

    // Group activities by day
    NSDate *now = [NSDate date];
    NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];

    for (AssociationActivity *activity in activities) {
        NSDate *day = [activity.start dateAtStartOfDay];

        // Check that activity is not over yet
        if (!activity.end || [activity.end isEarlierThanDate:now]) continue;

        NSMutableArray *group = groups[day];
        if (!group) {
            groups[day] = group = [[NSMutableArray alloc] init];
        }
        [group addObject:activity];
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
    self.navigationItem.rightBarButtonItem.enabled = self.days.count > 0;
    [self.tableView reloadData];
}

- (void)activitiesUpdated:(NSNotification *)notification
{
    [self loadActivities];
    [self.tableView reloadData];

    // Hide or update HUD
    if ([SVProgressHUD isVisible]) {
        if (self.days.count > 0) {
            [SVProgressHUD dismiss];
        }
        else {
            NSString *errorMsg = @"Geen activiteiten gevonden";
            [SVProgressHUD showErrorWithStatus:errorMsg];
        }
    }

    if ([UIRefreshControl class]) {
        [self.refreshControl endRefreshing];
    }
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
        dateFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateFormatter.dateFormat = @"d MMMM";
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

    NSDate *date = self.days[indexPath.section];
    AssociationActivity *activity = self.data[date][indexPath.row];
    static NSString *NoHighlightCellIdentifier = @"ActivityCellNoHighlight";
    static NSString *HighlightCellIdentifier = @"ActivityCellHighlight";
    UITableViewCell *cell;

    if (!activity.highlighted) {
        // request cell without the special star view
        cell = [tableView dequeueReusableCellWithIdentifier:NoHighlightCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:NoHighlightCellIdentifier];
            [self setupCell:cell withWidth:250];
        }
    }
    else {
        // request cell with special star view
        cell = [tableView dequeueReusableCellWithIdentifier:HighlightCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:HighlightCellIdentifier];
            [self setupCell:cell withWidth:220];

            UIImageView *star = [[UIImageView alloc] initWithImage:
                                 [UIImage imageNamed:@"icon-star"]];
            star.frame = CGRectMake(286, 8, 27, 27);
            [cell.contentView addSubview:star];
        }

    }
    titleLabel = (UILabel *)[cell viewWithTag:kCellTitleLabel];
    subtitleLabel = (UILabel *)[cell viewWithTag:kCellSubtitleLabel];

    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateFormatter.dateFormat = @"HH.mm";
    }

    cell.textLabel.text = [dateFormatter stringFromDate:activity.start];
    titleLabel.text = activity.title;
    subtitleLabel.text = activity.association.displayName;

    return cell;
}

- (void)setupCell:(UITableViewCell *)cell withWidth:(int)width
{
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];

    CGRect titleFrame = CGRectMake(60, 4, width, 20);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.tag = kCellTitleLabel;
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    titleLabel.highlightedTextColor = [UIColor whiteColor];
    [cell.contentView addSubview:titleLabel];

    CGRect subtitleFrame = CGRectMake(60, 24, width, 16);
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitleLabel.tag = kCellSubtitleLabel;
    subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
    subtitleLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    subtitleLabel.highlightedTextColor = [UIColor whiteColor];
    [cell.contentView addSubview:subtitleLabel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = self.days[indexPath.section];
    AssociationActivity *activity = self.data[date][indexPath.row];
    ActivityDetailViewController *detailViewController = [[ActivityDetailViewController alloc]
                                                          initWithActivity:activity delegate:self];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Searchbar delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.oldDays = [[NSArray alloc] initWithArray:self.days copyItems:YES];
    self.oldData = [[NSDictionary alloc] initWithDictionary:self.data copyItems:YES];

    [self filterActivities];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    self.data = self.oldData;
    self.days = self.oldDays;
    self.previousSearchLength = 0;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterActivities];
    return YES;
}

- (void) filterActivities
{
    NSString *searchString = self.searchController.searchBar.text;
    if (searchString.length == 0) {
        self.days = self.oldDays;
        self.data = self.oldData;
        self.previousSearchLength = 0;
    }
    else {
        if (self.previousSearchLength > searchString.length){
            self.days = self.oldDays;
            self.data = self.oldData;
        }
        
        self.previousSearchLength = searchString.length;
        
        NSMutableArray *filteredDays = [[NSMutableArray alloc] init];
        NSMutableDictionary *filteredData = [[NSMutableDictionary alloc] init];
        
        for (NSDate *day in self.days) {
            NSMutableArray *activities = self.data[day];
            NSMutableArray *filteredActivities = [[NSMutableArray alloc] init];
            for (AssociationActivity *activity in activities) {
                NSRange title = [activity.title rangeOfString:searchString options:NSCaseInsensitiveSearch];
                NSRange org = [activity.association.fullName rangeOfString:searchString options:NSCaseInsensitiveSearch];
                NSRange orgInt = [activity.association.internalName rangeOfString:searchString options:NSCaseInsensitiveSearch];
                if (title.location != NSNotFound || org.location != NSNotFound || orgInt.location != NSNotFound) {
                    [filteredActivities addObject:activity];
                }
            }
            if (filteredActivities.count > 0){
                [filteredDays addObject:day];
                filteredData[day] = filteredActivities;
            }
        }
        self.days = filteredDays;
        self.data = filteredData;
    }
}

#pragma mark - Activy list delegate

- (AssociationActivity *)activityBefore:(AssociationActivity *)current
{
    NSDate *day = [current.start dateAtStartOfDay];
    NSUInteger index = [self.data[day] indexOfObject:current];
    if (index == NSNotFound) return nil;

    // Is there another activity in the same day?
    if (index > 0) {
        return self.data[day][index - 1];
    }

    // Is there another day we can find activities in
    NSUInteger dayIndex = [self.days indexOfObject:day];
    if (dayIndex == 0 || dayIndex == NSNotFound) return nil;
    else {
        // Assuming each category has at least one date
        NSDate *prevDay = self.days[dayIndex - 1];
        return [self.data[prevDay] lastObject];
    }
}

- (AssociationActivity *)activityAfter:(AssociationActivity *)current
{
    NSDate *day = [current.start dateAtStartOfDay];
    NSUInteger index = [self.data[day] indexOfObject:current];
    if (index == NSNotFound) return nil;

    // Is there another activity in the same day?
    if (index < [self.data[day] count] - 1) {
        return self.data[day][index + 1];
    }

    // Is there another day we can find activities in
    NSUInteger dayIndex = [self.days indexOfObject:day];
    if (dayIndex == self.days.count - 1 || dayIndex == NSNotFound) return nil;
    else {
        // Assuming each category has at least one date
        NSDate *nextDay = self.days[dayIndex + 1];
        return self.data[nextDay][0];
    }
}

- (void)didSelectActivity:(AssociationActivity *)activity
{
    NSDate *day = [activity.start dateAtStartOfDay];
    NSUInteger row = [self.data[day] indexOfObject:activity];
    NSUInteger section = [self.days indexOfObject:day];

    NSIndexPath *selection = [NSIndexPath indexPathForRow:row inSection:section];
    [self.tableView selectRowAtIndexPath:selection animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Date button and UIPickerView

- (void)dateButtonTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];

    // Create datepicker
    self.datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    self.datePicker.showsSelectionIndicator = YES;
    self.datePicker.dataSource = self;
    self.datePicker.delegate = self;
    [actionSheet addSubview:self.datePicker];

    NSIndexPath *firstSection = [self.tableView indexPathsForVisibleRows][0];
    [self.datePicker selectRow:firstSection.section inComponent:0 animated:NO];

    // Create toolbar
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Gereed" style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(dismissActionSheet:)];
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.tintColor = [UIColor hydraTintColor];
    pickerToolbar.items = @[flexSpace, doneBtn];
    [actionSheet addSubview:pickerToolbar];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 250, 22)];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.text = @"Selecteer een dag";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = UITextAlignmentCenter;
    title.shadowColor = [UIColor blackColor];
    title.shadowOffset = CGSizeMake(1, 1);
    title.backgroundColor = [UIColor clearColor];
    [actionSheet addSubview:title];

    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 500)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.days.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label;
    if (!view) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 37)];
        label.font = [UIFont boldSystemFontOfSize:18];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
    }
    else {
        label = (UILabel *)view;
    }

    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        formatter.dateFormat = @"EEEE d MMMM";
    }
    label.text = [formatter stringFromDate:self.days[row]];

    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:row];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)dismissActionSheet:(id)sender
{
    UIActionSheet *sheet = (UIActionSheet *)[self.datePicker superview];
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
    self.datePicker = nil;
}

@end
