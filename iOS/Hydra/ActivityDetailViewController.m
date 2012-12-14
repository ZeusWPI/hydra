//
//  ActivityDetailViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "AssociationActivity.h"
#import "Association.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#define kInfoSection 0
#define KActionSection 1

#define kTitleRow 0
#define kAssociationRow 1
#define kDateRow 2
#define kLocationRow 3

@interface ActivityDetailViewController () <EKEventEditViewDelegate>

@property (nonatomic, strong) AssociationActivity *activity;
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) id<ActivityListDelegate> listDelegate;

@end

@implementation ActivityDetailViewController

- (id)initWithActivity:(AssociationActivity *)activity delegate:(id<ActivityListDelegate>)delegate
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.activity = activity;
        self.listDelegate = delegate;

        [self reloadFields];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Detail";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Fast navigation between activitities
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        [UIImage imageNamed:@"navigation-up"], [UIImage imageNamed:@"navigation-down"]]];
    [segmentedControl addTarget:self action:@selector(segmentTapped:)
               forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    [self enableSegments:segmentedControl];

    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
}

- (void)reloadFields
{
    static NSDateFormatter *dateStartFormatter = nil;
    static NSDateFormatter *dateEndFormatter = nil;
    if (!dateStartFormatter || !dateEndFormatter) {
        dateStartFormatter = [[NSDateFormatter alloc] init];
        [dateStartFormatter setDateFormat:@"EEE d MMMM H:mm"];
        dateEndFormatter = [[NSDateFormatter alloc] init];
        [dateEndFormatter setDateFormat:@"H:mm"];
    }

    NSMutableArray *fields = [[NSMutableArray alloc] init];
    fields[kTitleRow] = self.activity.title;

    Association *association = self.activity.association;
    if (association.fullName) {
        fields[kAssociationRow] = [NSString stringWithFormat:@"%@ (%@)",
                                   association.displayName, association.fullName];
    }
    else {
        fields[kAssociationRow] = association.displayName;
    }

    if (self.activity.end) {
        fields[kDateRow] = [NSString stringWithFormat:@"%@ - %@",
                            [dateStartFormatter stringFromDate:self.activity.start],
                            [dateEndFormatter stringFromDate:self.activity.end]];
    }
    else {
        fields[kDateRow] = [dateStartFormatter stringFromDate:self.activity.start];
    }

    fields[kLocationRow] = self.activity.location ? self.activity.location : @"";

    self.fields = fields;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == kInfoSection ? 4 : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kInfoSection) {
        BOOL isTitleRow = indexPath.row == kTitleRow;

        UIFont *font = [UIFont systemFontOfSize:13.0f];
        if (isTitleRow) font = [UIFont boldSystemFontOfSize:20.0f];

        NSString *text = self.fields[indexPath.row];
        CGFloat width = tableView.frame.size.width - (isTitleRow ? 40.0f : 125.0f);
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];

        return MAX(40.0f, size.height + (isTitleRow ? 26.0f : 18.0f));
    }
    else {
        return 44.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kInfoSection) {
        if (indexPath.row == kTitleRow) {
            static NSString *CellIdentifier = @"ActivityDetailTitleCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:CellIdentifier];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.textLabel.numberOfLines = 0;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.text = self.fields[indexPath.row];
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"ActivityDetailCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                              reuseIdentifier:CellIdentifier];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
                cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13.0f];
                cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.detailTextLabel.numberOfLines = 0;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            switch (indexPath.row) {
                case kAssociationRow:
                    cell.textLabel.text = @"Vereniging";
                    break;
                case kDateRow:
                    cell.textLabel.text = @"Datum";
                    break;
                case kLocationRow:
                    cell.textLabel.text = @"Locatie";
                    break;
            }
            cell.detailTextLabel.text = self.fields[indexPath.row];

            return cell;
        }
    }
    else {
        static NSString *CellIdentifier = @"ActivityDetailButtonCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Toevoegen aan agenda";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.textLabel.textColor = [UIColor detailLabelTextColor];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKEventStore *store = [[EKEventStore alloc] init];
    if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self performSelectorOnMainThread:@selector(addEventToCalendarStore:)
                                       withObject:store waitUntilDone:NO];
            }
        }];
    }
    else {
        [self addEventToCalendarStore:store];
    }
}

- (void)addEventToCalendarStore:(EKEventStore *)store
{
    EKEvent *event  = [EKEvent eventWithEventStore:store];
    event.title     = self.activity.title;
    event.location  = self.activity.location;
    event.startDate = self.activity.start;
    event.endDate   = self.activity.end;

    [event setCalendar:[store defaultCalendarForNewEvents]];

    EKEventEditViewController *eventViewController = [[EKEventEditViewController alloc] init];

    eventViewController.event = event;
    eventViewController.eventStore = store;
    eventViewController.editViewDelegate = self;
    [self.navigationController presentModalViewController:eventViewController animated:YES];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Segmented control

- (void)enableSegments:(UISegmentedControl *)control
{
    AssociationActivity *prev = [self.listDelegate activityBefore:self.activity];
    [control setEnabled:(prev != nil) forSegmentAtIndex:0];
    AssociationActivity *next = [self.listDelegate activityAfter:self.activity];
    [control setEnabled:(next != nil) forSegmentAtIndex:1];
}

- (void)segmentTapped:(UISegmentedControl *)control
{
    if (control.selectedSegmentIndex == 0) {
        self.activity = [self.listDelegate activityBefore:self.activity];
    }
    else {
        self.activity = [self.listDelegate activityAfter:self.activity];
    }

    [self reloadFields];
    [self.tableView reloadData];
    [self enableSegments:control];
    [self.listDelegate didSelectActivity:self.activity];
}

@end
