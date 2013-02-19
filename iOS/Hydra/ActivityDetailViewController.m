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
#import "NSDate+Utilities.h"
#import "CustomTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#define kHeaderSection 0

#define kInfoSection 1
    #define kAssociationRow 0
    #define kDateRow 1
    #define kLocationRow 2
    #define kGuestsRow 3
    #define kDescriptionRow 4
    #define kUrlRow 5

#define kActionSection 2
    #define kRsvpActionRow 0
    #define kCalendarActionRow 1

@interface ActivityDetailViewController () <EKEventEditViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) AssociationActivity *activity;
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) id<ActivityListDelegate> listDelegate;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *friendsView;
@property (nonatomic, strong) UITextView *descriptionView;

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
        [self reloadData];
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

- (void)reloadData
{
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    fields[kAssociationRow] = self.activity.association.displayedFullName;

    // Formatted date
    static NSDateFormatter *dateStartFormatter = nil;
    static NSDateFormatter *dateEndFormatter = nil;
    if (!dateStartFormatter || !dateEndFormatter) {
        dateStartFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateStartFormatter.dateFormat = @"EEE d MMMM H:mm";
        dateEndFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateEndFormatter.dateFormat = @"H:mm";
    }

    if (self.activity.end) {
        // Does the event span more than 24 hours?
        if ([[self.activity.start dateByAddingDays:1] isLaterThanDate:self.activity.end]) {
            fields[kDateRow] = [NSString stringWithFormat:@"%@ - %@",
                                [dateStartFormatter stringFromDate:self.activity.start],
                                [dateEndFormatter stringFromDate:self.activity.end]];
        }
        else {
            fields[kDateRow] = [NSString stringWithFormat:@"%@ -\n%@",
                                [dateStartFormatter stringFromDate:self.activity.start],
                                [dateStartFormatter stringFromDate:self.activity.end]];
        }
    }
    else {
        fields[kDateRow] = [dateStartFormatter stringFromDate:self.activity.start];
    }

    fields[kLocationRow] = self.activity.location ? self.activity.location : @"";

    FacebookEvent *fbEvent = self.activity.facebookEvent;
    if (fbEvent.valid) {
        NSString *guests = [NSString stringWithFormat:@"%d aanwezig", fbEvent.attendees];
        if (fbEvent.friendsAttending) {
            NSUInteger count = fbEvent.friendsAttending.count;
            guests = [guests stringByAppendingFormat:@", %d %@", count,
                      (count == 1 ? @"vriend" : @"vrienden")];
        }
        fields[kGuestsRow] = guests;
    }
    else {
        fields[kGuestsRow] = @"";
    }

    fields[kDescriptionRow] =  @"";
    fields[kUrlRow] = @"http://";

    self.fields = fields;
    self.descriptionView = nil;
    self.friendsView = nil;

    // Trigger event reload
    [self.activity.facebookEvent update];

    [self.tableView reloadData];
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

        case kInfoSection: {
            NSUInteger rows = 3;
            if (self.activity.descriptionText.length > 0) rows++;
            if (self.activity.url.length > 0) rows++;

            // Facebook info?
            FacebookEvent *fbEvent = self.activity.facebookEvent;
            if (fbEvent.valid) rows++;

            return rows;
        }

        case kActionSection: {
            FacebookEvent *fbEvent = self.activity.facebookEvent;
            return fbEvent.valid ? 2 : 1;
        }

        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set some defaults
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGFloat width = tableView.frame.size.width - 125;
    CGFloat minHeight = 36, spacing = 20;

    // Determine text, possibility to override settings
    NSString *text = nil;

    NSUInteger row = [self virtualRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case kHeaderSection:
            text = self.activity.title;

            font = [UIFont boldSystemFontOfSize:20];
            width = tableView.frame.size.width - 40;
            spacing = 0;

            if (self.activity.facebookEvent.smallImageUrl) {
                minHeight = 70;
                width -= 70;
            }
            break;

        case kInfoSection:
            // TODO: bug? This check should not be required, but sometimes
            // this method is called with an indexPath it cannot handle...
            if (row < self.fields.count) {
                text = self.fields[row];
            }

            if (row == kGuestsRow) {
                FacebookEvent *fbEvent = self.activity.facebookEvent;
                if (fbEvent.friendsAttending.count > 0) {
                    spacing += 40;
                }
            }
            else if (row == kDescriptionRow) {
                // Different calculation for UITextView
                if (!self.descriptionView) {
                    self.descriptionView = [self createDescriptionView];
                    width = tableView.frame.size.width - 20;
                    self.descriptionView.frame = CGRectMake(0, 0, width, 0);
                }
                return self.descriptionView.contentSize.height + 4;
            }
            break;

        case kActionSection:
            minHeight = 40;
            if (row == kRsvpActionRow) {
                FacebookEvent *fbEvent = self.activity.facebookEvent;
                if (fbEvent.userRsvp != FacebookEventRsvpNone) {
                    return 48;
                }
            }
            break;
    }

    if (text) {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
        return MAX(minHeight, size.height + spacing);
    }
    else {
        return minHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (section == 2) ? 0 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [self virtualRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case kHeaderSection:
            return [self tableView:tableView headerCellForRowAtIndex:row];

        case kInfoSection:
            return [self tableView:tableView infoCellForRowAtIndex:row];

        case kActionSection:
            return [self tableView:tableView actionCellForRowAtIndex:row];

        default:
            return nil;
    }
}

- (NSUInteger)virtualRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    if (indexPath.section == kInfoSection) {
        FacebookEvent *fbEvent = self.activity.facebookEvent;
        if (row >= kGuestsRow && !fbEvent.valid) row ++;

        if (row >= kDescriptionRow && self.activity.descriptionText.length == 0) row++;
        if (row >= kUrlRow && self.activity.url.length == 0) row++;

        ZAssert(row <= kUrlRow, @"Invalid virtual row number");
    }
    else if (indexPath.section == kActionSection)
    {
        FacebookEvent *fbEvent = self.activity.facebookEvent;
        if (row >= kRsvpActionRow && !fbEvent.valid) row += 1;
    }

    return row;
}

#pragma mark - Creating cells and views

- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForRowAtIndex:(NSUInteger)row
{
    static NSString *CellIdentifier = @"ActivityDetailHeaderCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[UIView alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
    }
    else {
        cell.customView = nil;
        cell.indentationLevel = 0;
    }

    cell.textLabel.text = self.activity.title;

    // Show image
    NSURL *imageUrl = self.activity.facebookEvent.smallImageUrl;
    if (imageUrl) {
        if (!self.imageView) {
            CGRect imageRect = CGRectMake(-1, -1, 72, 72);
            self.imageView = [[UIImageView alloc] initWithFrame:imageRect];
            self.imageView.backgroundColor = [UIColor whiteColor];
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
            self.imageView.layer.masksToBounds = YES;
            self.imageView.layer.cornerRadius = 5;
            self.imageView.layer.borderWidth = 1.2;
            self.imageView.layer.borderColor = [UIColor colorWithWhite:0.65 alpha:1].CGColor;
        }

        [self.imageView setImageWithURL:imageUrl];
        cell.customView = self.imageView;
        cell.indentationLevel = 7; // inset text 70pt
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView infoCellForRowAtIndex:(NSUInteger)row
{
    static NSString *CellIdentifier = @"ActivityDetailInfoCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        // Restore defaults
        cell.alignToTop = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.customView = nil;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
    }

    cell.textLabel.text = @"";
    cell.detailTextLabel.text = self.fields[row];

    // Customize per row
    switch (row) {
        case kAssociationRow:
            cell.textLabel.text = @"Vereniging";
            break;

        case kDateRow:
            cell.textLabel.text = @"Datum";
            break;

        case kLocationRow:
            // TODO: make the location go to a seperate view with just a map
            cell.textLabel.text = @"Locatie";
            if (self.activity.latitude != 0 && self.activity.longitude != 0) {
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }
            break;

        case kGuestsRow: {
            cell.textLabel.text = @"Gasten";
            cell.alignToTop = YES;
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

            FacebookEvent *event = self.activity.facebookEvent;
            if (event.friendsAttending.count > 0) {
                if (!self.friendsView) {
                    self.friendsView = [self createFriendsView:event.friendsAttending];
                    self.friendsView.frame = CGRectOffset(self.friendsView.frame, 83,
                                                          cell.frame.size.height - 42);
                    self.friendsView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                }
                cell.customView = self.friendsView;
            }
        } break;

        case kDescriptionRow:
            if (!self.descriptionView) {
                self.descriptionView = [self createDescriptionView];
            }
            self.descriptionView.frame = cell.contentView.bounds;
            cell.customView = self.descriptionView;
            break;

        case kUrlRow:
            cell.textLabel.text = @"Meer info";
            cell.detailTextLabel.text = self.activity.url;
            cell.detailTextLabel.numberOfLines = 1;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;

            UIImage *linkImage = [UIImage imageNamed:@"external-link"];
            UIImage *highlightedLinkImage = [UIImage imageNamed:@"external-link-active"];
            UIImageView *linkAccessory = [[UIImageView alloc] initWithImage:linkImage
                                                           highlightedImage:highlightedLinkImage];
            linkAccessory.contentMode = UIViewContentModeScaleAspectFit;
            cell.accessoryView = linkAccessory;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            break;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView actionCellForRowAtIndex:(NSUInteger)row
{
    static NSString *CellIdentifier = @"ActivityDetailButtonCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:CellIdentifier];
        cell.forceCenter = YES;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.textColor = [UIColor H_detailLabelTextColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    else {
        cell.customView = nil;
    }

    FacebookEvent *fbEvent = self.activity.facebookEvent;
    if (row == kRsvpActionRow) {
        if (!fbEvent.userRsvp || fbEvent.userRsvp == FacebookEventRsvpNone) {
            cell.textLabel.text = @"Bevestig aanwezigheid";
        }
        else {
            cell.textLabel.text = @"Aanwezigheid wijzigen";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Momenteel sta je op '%@'",
                                         FacebookEventRsvpAsLocalizedString(fbEvent.userRsvp)];

            if (fbEvent.userRsvpUpdating) {
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                CGRect spinnerFrame = spinner.frame;
                spinnerFrame.origin.x = 10;
                spinnerFrame.origin.y = roundf(0.5 * (cell.contentView.bounds.size.height - spinnerFrame.size.height));
                spinner.frame = spinnerFrame;
                spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                                         | UIViewAutoresizingFlexibleBottomMargin;
                [spinner startAnimating];
                cell.customView = spinner;
            }
        }
    }
    else if (row == kCalendarActionRow) {
        cell.textLabel.text = @"Toevoegen aan agenda";
        cell.detailTextLabel.text = nil;
    }

    return cell;
}

- (UITextView *)createDescriptionView
{
    UITextView *view = [[UITextView alloc] init];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth
                          | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor clearColor];
    view.bounces = NO;
    view.dataDetectorTypes = UIDataDetectorTypeLink
                           | UIDataDetectorTypePhoneNumber;
    view.editable = NO;
    view.font = [UIFont systemFontOfSize:13];
    view.scrollEnabled = NO;
    view.text = self.activity.descriptionText;
    return view;
}

- (UIView *)createFriendsView:(NSArray *)friends
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 30)];

    CGRect pictureFrame = CGRectMake(0, 0, 30, 30);
    UIImage *placeholder = [UIImage imageNamed:@"FacebookSDKResources.bundle/"
                                                "FBProfilePictureView/images/"
                                                "fb_blank_profile_square.png"];
    for (NSUInteger i = 0; i < friends.count && i < 5; i++) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:pictureFrame];
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 5;
        [image setImageWithURL:[friends[i] photoUrl] placeholderImage:placeholder];
        [container addSubview:image];

        pictureFrame.origin.x += 35;
    }

    return container;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [self virtualRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case kInfoSection:
            if (row == kUrlRow) {
                NSURL *url = [NSURL URLWithString:self.activity.url];
                [[UIApplication sharedApplication] openURL:url];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            break;

        case kActionSection:
            if (row == kRsvpActionRow) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Bevestig aanwezigheid" delegate:self
                                              cancelButtonTitle:@"Annuleren" destructiveButtonTitle:nil
                                              otherButtonTitles:@"Aanwezig", @"Misschien", @"Niet aanwezig", nil];
                [actionSheet showInView:self.view];
            }
            else if (row == kCalendarActionRow) {
                [self addEventToCalendar];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            break;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kInfoSection) {
        NSUInteger row = [self virtualRowAtIndexPath:indexPath];
        if (row == kGuestsRow) {
            [self.activity.facebookEvent showExternally];
        }
        else if (row == kLocationRow) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.activity.latitude,
                                                                           self.activity.longitude);
            // Create MKMapItem out of coordinates
            MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
            destination.name = self.activity.location;

            // Use native maps on iOS6 or open Google Maps on iOS5
            if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)]) {
                [destination openInMapsWithLaunchOptions:nil];
            }
            else {
                NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?ll=%f,%f",
                                 self.activity.latitude, self.activity.longitude];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
    }
}

- (void)addEventToCalendar
{
    EKEventStore *store = [[EKEventStore alloc] init];
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) return;
            [self performSelectorOnMainThread:@selector(addEventWithCalendarStore:)
                                   withObject:store waitUntilDone:NO];
        }];
    }
    else {
        [self addEventWithCalendarStore:store];
    }
}

- (void)addEventWithCalendarStore:(EKEventStore *)store
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 3) {
        FacebookEventRsvp answer = buttonIndex + 1;
        self.activity.facebookEvent.userRsvp = answer;
    }

    // Update view (show waiting indicator)
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView beginUpdates];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
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

    [self reloadData];
    [self enableSegments:control];
    [self viewDidAppear:NO]; // Trigger analytics
    [self.listDelegate didSelectActivity:self.activity];
}

#pragma mark - Notifications

- (void)facebookEventUpdated:(NSNotification *)notification
{
    [self reloadData];
}

@end
