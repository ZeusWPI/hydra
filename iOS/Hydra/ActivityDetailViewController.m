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
#import "NSDateFormatter+AppLocale.h"
#import "FacebookEvent.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#define kHeaderSection 0
#define kInfoSection 1
#define kActionSection 2

#define kAssociationRow 0
#define kDateRow 1
#define kLocationRow 2
#define kGuestsRow 3
#define kDescriptionRow 4


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

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(facebookEventUpdated:)
                       name:FacebookEventDidUpdateNotification object:nil];
        [self reloadFields];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track([@"Activity > " stringByAppendingString:self.activity.title]);
}

- (void)reloadFields
{
    static NSDateFormatter *dateStartFormatter = nil;
    static NSDateFormatter *dateEndFormatter = nil;
    if (!dateStartFormatter || !dateEndFormatter) {
        dateStartFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateStartFormatter.dateFormat = @"EEE d MMMM H:mm";
        dateEndFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateEndFormatter.dateFormat = @"H:mm";
    }

    NSMutableArray *fields = [[NSMutableArray alloc] init];
    fields[kAssociationRow] = self.activity.association.displayedFullName;

    // TODO: check if spans multiple days
    if (self.activity.end) {
        fields[kDateRow] = [NSString stringWithFormat:@"%@ - %@",
                            [dateStartFormatter stringFromDate:self.activity.start],
                            [dateEndFormatter stringFromDate:self.activity.end]];
    }
    else {
        fields[kDateRow] = [dateStartFormatter stringFromDate:self.activity.start];
    }

    fields[kLocationRow] = self.activity.location ? self.activity.location : @"";

    FacebookEvent *fbEvent = self.activity.facebookEvent;
    if (fbEvent.valid) {
        NSString *guests = [NSString stringWithFormat:@"%d %@", fbEvent.attendees,
                            (fbEvent.attendees == 1 ? @"aanwezige" : @"aanwezigen")];
        if (fbEvent.friendsAttending) {
            NSUInteger count = fbEvent.friendsAttending.count;
            guests = [guests stringByAppendingFormat:@" (%d %@)", count,
                      (count == 1 ? @"vriend" : @"vrienden")];
        }
        fields[kGuestsRow] = guests;
    }
    else {
        fields[kGuestsRow] = @"";
    }

    fields[kDescriptionRow] = self.activity.htmlDescription ? self.activity.htmlDescription : @"";

    self.fields = fields;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section) {
        case kHeaderSection:
            return 1;
        case kInfoSection:
            return 5; //[self numberOfRowsInInfoSection];
        case kActionSection:
            return 1;
        default:
            return 0;
    }
}
/*
- (NSUInteger)numberOfRowsInInfoSection
{
    NSUInteger rows = 4;

    if (self.activity.htmlDescription != nil){
        rows++;
    }

    if (self.activity.facebookEvent.valid) {
        rows++;
    }

    return rows;
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set some defaults
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGFloat width = tableView.frame.size.width - 125;
    CGFloat spacing = 18;

    // Determine text, possibility to override settings
    NSString *text = nil;
    switch (indexPath.section) {
        case kHeaderSection:
            font = [UIFont boldSystemFontOfSize:20];
            width = tableView.frame.size.width - 40;
            text = self.activity.title;
            spacing = 0;
            break;
        
        case kInfoSection:
            text = self.fields[indexPath.row];
            break;
    }

    if (text) {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
        return MAX(40, size.height + spacing);
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kHeaderSection) {
        static NSString *CellIdentifier = @"ActivityDetailTitleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIView alloc] init];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
        }

        [cell.imageView setImageWithURL:self.activity.facebookEvent.squareImageUrl];
        cell.textLabel.text = self.activity.title;

        return cell;
    }
    else if (indexPath.section == kInfoSection) {
        static NSString *CellIdentifier = @"ActivityDetailCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13];
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
            case kGuestsRow:
                cell.textLabel.text = @"Gasten";
                break;
        }
        cell.detailTextLabel.text = self.fields[indexPath.row];

        return cell;
    }
    else if (indexPath.section == kActionSection) {
        static NSString *CellIdentifier = @"ActivityDetailButtonCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Toevoegen aan agenda";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.textLabel.textColor = [UIColor H_detailLabelTextColor];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        return cell;
    }
    /*else if (indexPath.section == kFaceBookButtonSection) {
        static NSString *CellIdentifier = @"FacebookButtonCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.textLabel.textColor = [UIColor H_detailLabelTextColor];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        cell.textLabel.text = @"TEST";
        //cell.textLabel.text = self.activity.facebookEvent.userAttending ? @"Aanwezig" : @"Deelnemen";
        return cell;
    }*/
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kActionSection: {
            EKEventStore *store = [[EKEventStore alloc] init];
            if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
                [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (!granted) return;

                    [self performSelectorOnMainThread:@selector(addEventToCalendarStore:)
                                          withObject:store waitUntilDone:NO];
                }];
            }
            else {
                [self addEventToCalendarStore:store];
            }
        } break;
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
    [self viewDidAppear:NO]; // Trigger analytics
    [self enableSegments:control];
    [self.tableView reloadData];
    [self.listDelegate didSelectActivity:self.activity];
}

#pragma mark - Notifications

- (void)facebookEventUpdated:(NSNotification *)notification
{
    [self reloadFields];
    [self.tableView reloadData];
}

@end
