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

#import <SDWebImage/UIImageView+WebCache.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#define kHeaderSection 0
#define kInfoSection 1
#define kActionSection 2

#define kAssociationRow 0
#define kDateRow 1
#define kLocationRow 2
#define kGuestsRow 3
#define kFriendsRow 4
#define kDescriptionRow 5
#define kUrlRow 6

#define kRsvpActionRow 0
#define kCalendarActionRow 1

#define kImageViewTag 501
#define kBorderOverlayTag 502
#define kImageContainerTag 503
#define kTextViewTag 504
#define kDetailLabelTag 505

@interface ActivityDetailViewController () <EKEventEditViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) AssociationActivity *activity;
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) id<ActivityListDelegate> listDelegate;

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

    if (self.activity.end) {
        if ([[self.activity.start dateByAddingDays:1] compare:self.activity.end] != NSOrderedAscending) {
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

    fields[kFriendsRow] = @"";
    fields[kDescriptionRow] = self.activity.descriptionText ? self.activity.descriptionText : @"";
    fields[kUrlRow] = self.activity.url ? self.activity.url : @"";

    self.fields = fields;

    // Trigger event reload
    [self.activity.facebookEvent update];
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

            // Facebook-rows?
            FacebookEvent *event = self.activity.facebookEvent;
            if (event.valid) rows++;
            if (event.friendsAttending.count > 0) rows++;

            return rows;
        } break;

        case kActionSection: {
            FacebookEvent *event = self.activity.facebookEvent;
            return event.valid ? 2 : 1;
        } break;

        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set some defaults
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGFloat width = tableView.frame.size.width - 125;

    CGFloat minHeight = 40;
    CGFloat spacing = 18;

    // Determine text, possibility to override settings
    NSString *text = nil;
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
        
        case kInfoSection: {
            NSUInteger row = [self virtualRowAtIndexPath:indexPath];
            if (row == kFriendsRow) {
                minHeight = 36; // Quick ugly shortcut
            }

            // TODO: Bug? This check should not be required, but sometimes
            // this method is called with an indexPath it cannot handle...
            if (row < self.fields.count) {
                text = self.fields[row];
            }

            // Long url's should just be cut off
            if (row == kUrlRow) {
                text = @"http://";
            }
            // Different calculation for UITextView
            else if (row == kDescriptionRow) {
                if (self.descriptionView) {
                    return self.descriptionView.contentSize.height;
                }
                else {
                    return 44;
                }
            }
        } break;

        case kActionSection: {
            FacebookEvent *event = self.activity.facebookEvent;
            if (indexPath.row == kRsvpActionRow && event.valid && event.userRsvp) {
                return 48;
            }
        } break;
    }

    if (text) {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
        return MAX(minHeight, size.height + spacing);
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (section == 2) ? 0 : 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

// TODO: split this method per section
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
            cell.textLabel.shadowColor = [UIColor whiteColor];
            cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        }

        cell.indentationLevel = 0;
        cell.textLabel.text = self.activity.title;
        [[cell.contentView viewWithTag:kImageViewTag] removeFromSuperview];

        // TODO: make this image tappable to view the full size
        NSURL *url = self.activity.facebookEvent.smallImageUrl;
        if (url) {
            CGRect imageRect = CGRectMake(-1, 0, 70, 70);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 5;
            imageView.layer.borderWidth = 1.2;
            imageView.layer.borderColor = [UIColor colorWithWhite:0.65 alpha:1].CGColor;
            imageView.tag = kImageViewTag;
            [imageView setImageWithURL:url];
            [cell.contentView addSubview:imageView];

            // Inset text
            cell.indentationLevel = 7; // 70pt
        }

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
        }

        NSUInteger row = [self virtualRowAtIndexPath:indexPath];
        switch (row) {
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
            case kUrlRow:
                cell.textLabel.text = @"Meer info";
                break;
            default:
                cell.textLabel.text = @"";
                break;
        }
        cell.detailTextLabel.text = self.fields[row];

        // Defaults
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        [[cell viewWithTag:kBorderOverlayTag] removeFromSuperview];
        [[cell viewWithTag:kImageContainerTag] removeFromSuperview];
        [[cell viewWithTag:kTextViewTag] removeFromSuperview];

        // Customize per row
        // TODO: make the location go to a seperate view with just a map
        if (row == kLocationRow) {
            if (self.activity.latitude != 0 && self.activity.longitude != 0) {
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }
        }
        else if (row == kGuestsRow) {
            FacebookEvent *event = self.activity.facebookEvent;
            if (event.valid) {
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }

            if (event.friendsAttending.count > 0) {
                // Overlay border to next cell
                CGRect overlayFrame = CGRectInset(cell.bounds, 10, 0);
                overlayFrame.origin.y = overlayFrame.size.height - 1;
                overlayFrame.size.height = 2;

                UIView *overlay = [[UIView alloc] initWithFrame:overlayFrame];
                overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                         | UIViewAutoresizingFlexibleTopMargin;
                overlay.tag = kBorderOverlayTag;
                [cell addSubview:overlay];

                // Add profile pictures to this cell too, so we don't have
                // issues with cells overlapping each other
                UIView *friendsContainer = [self createFriendsView:event.friendsAttending];
                CGRect containerFrame = friendsContainer.frame;
                containerFrame.origin = CGPointMake(95, cell.frame.size.height - 6);
                friendsContainer.frame = containerFrame;
                friendsContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                friendsContainer.tag = kImageContainerTag;
                [cell addSubview:friendsContainer];
            }
        }
        else if (row == kDescriptionRow) {
            if (!self.descriptionView) {
                UITextView *descriptionView = [[UITextView alloc] init];
                descriptionView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                                 | UIViewAutoresizingFlexibleHeight;
                descriptionView.backgroundColor = [UIColor clearColor];
                descriptionView.bounces = NO;
                descriptionView.dataDetectorTypes = UIDataDetectorTypeLink
                                                  | UIDataDetectorTypePhoneNumber;
                descriptionView.editable = NO;
                descriptionView.font = [UIFont systemFontOfSize:13];
                descriptionView.tag = kTextViewTag;
                descriptionView.scrollEnabled = NO;
                self.descriptionView = descriptionView;

                [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
            }
            self.descriptionView.text = self.fields[row];
            self.descriptionView.frame = cell.contentView.bounds;
            [cell.contentView addSubview:self.descriptionView];
            cell.detailTextLabel.text = nil;
        }
        else if (row == kUrlRow) {
            UIImage *linkImage = [UIImage imageNamed:@"external-link"];
            UIImage *highlightedLinkImage = [UIImage imageNamed:@"external-link-active"];
            UIImageView *linkAccessory = [[UIImageView alloc] initWithImage:linkImage
                                                           highlightedImage:highlightedLinkImage];
            linkAccessory.contentMode = UIViewContentModeScaleAspectFit;
            cell.accessoryView = linkAccessory;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.detailTextLabel.numberOfLines = 1;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }

        return cell;
    }
    else if (indexPath.section == kActionSection) {
        static NSString *CellIdentifier = @"ActivityDetailButtonCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.textLabel.textColor = [UIColor H_detailLabelTextColor];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        else {
            [[cell viewWithTag:kDetailLabelTag] removeFromSuperview];
        }

        FacebookEvent *event = self.activity.facebookEvent;
        if (event.valid && indexPath.row == kRsvpActionRow) {
            if (!event.userRsvp || [event.userRsvp isEqualToString:@"not_replied"]) {
                cell.textLabel.text = @"Bevestig aanwezigheid";
            }
            else {
                cell.textLabel.text = @"Aanwezigheid wijzigen\n ";

                NSString *rsvpDescription = @"misschien";
                if ([event.userRsvp isEqualToString:@"attending"]) {
                    rsvpDescription = @"aanwezig";
                }
                else if ([event.userRsvp isEqualToString:@"declined"]) {
                    rsvpDescription = @"niet aanwezig";
                }

                NSString *detailLabelText = [NSString stringWithFormat:@"Momenteel sta je op '%@'",
                                             rsvpDescription];

                CGRect detailFrame = CGRectMake(0, 24, cell.contentView.bounds.size.width, 16);
                UILabel *detailLabel = [[UILabel alloc] initWithFrame:detailFrame];
                detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                detailLabel.backgroundColor = [UIColor clearColor];
                detailLabel.font = [UIFont systemFontOfSize:13];
                detailLabel.text = detailLabelText;
                detailLabel.textAlignment = UITextAlignmentCenter;
                detailLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
                detailLabel.tag = kDetailLabelTag;
                [cell.contentView addSubview:detailLabel];
            }
        }
        else {
            cell.textLabel.text = @"Toevoegen aan agenda";
        }

        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Fix background-color
    UIView *overlay = [cell viewWithTag:kBorderOverlayTag];
    if (overlay) {
        overlay.backgroundColor = cell.backgroundColor;
    }
}

- (NSUInteger)virtualRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;

    FacebookEvent *event = self.activity.facebookEvent;
    if (row >= kGuestsRow && !event.valid) row += 2;
    if (row >= kFriendsRow) {
        if (event.valid && event.friendsAttending.count == 0) {
            row++;
        }
    }
    if (row >= kDescriptionRow && self.activity.descriptionText.length == 0) row++;
    if (row >= kUrlRow && self.activity.url.length == 0) row++;

    return row;
}

- (UIView *)createFriendsView:(NSArray *)friends
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];

    CGRect pictureFrame = CGRectMake(0, 0, 30, 30);
    UIImage *placeholder = [UIImage imageNamed:@"FacebookSDKResources.bundle/FBProfilePictureView/images/fb_blank_profile_square.png"];

    for (NSUInteger i = 0; i < friends.count && i < 5; i++) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:pictureFrame];
        image.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
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
    switch (indexPath.section) {
        case kInfoSection : {
            NSUInteger row = [self virtualRowAtIndexPath:indexPath];
            if (row == kUrlRow) {
                NSURL *url = [NSURL URLWithString:self.activity.url];
                [[UIApplication sharedApplication] openURL:url];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
           
        } break;
        case kActionSection: {
            FacebookEvent *event = self.activity.facebookEvent;
            if (event.valid && indexPath.row == kRsvpActionRow) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Bevestig aanwezigheid" delegate:self
                                              cancelButtonTitle:@"Annuleren" destructiveButtonTitle:nil
                                              otherButtonTitles:@"Aanwezig", @"Misschien", @"Niet aanwezig", nil];
                [actionSheet showInView:self.view];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            else {
                [self addEventToCalendar];
            }
        } break;
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

            if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)]) {
                //using iOS6 native maps app
                [destination openInMapsWithLaunchOptions:nil];
            }
            else {
                //using iOS 5 which has the Google Maps application
                NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?ll=%f,%f",
                                 self.activity.latitude, self.activity.longitude];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
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
    NSString *answer = nil;
    switch(buttonIndex) {
        case 0: answer = @"attending"; break;
        case 1: answer = @"unsure"; break;
        case 2: answer = @"declined"; break;
    }

    if (answer) {
        // TODO: show some kind of spinner to show activity
        self.activity.facebookEvent.userRsvp = answer;
    }
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

    self.descriptionView = nil;
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
