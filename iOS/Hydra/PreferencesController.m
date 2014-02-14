//
//  PreferencesController.m
//  Hydra
//
//  Created by Pieter De Baets on 08/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "PreferencesController.h"
#import "AssociationPreferenceController.h"
#import "FacebookSession.h"
#import "PreferencesService.h"

#import <VTAcknowledgementsViewController/VTAcknowledgementsViewController.h>

#define kFacebookSection 0
#define kFilterSection 1
#define kInfoSection 2

#define kSwitchTag 500

@interface PreferencesController () <UIActionSheetDelegate>

@end

@implementation PreferencesController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        // Listen for facebook state changes
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(facebookUpdated:)
                       name:FacebookSessionStateChangedNotification object:nil];
        [center addObserver:self selector:@selector(facebookUpdated:)
                       name:FacebookUserInfoUpdatedNotifcation object:nil];
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
    self.title = @"Voorkeuren";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Voorkeuren");

    // Reload changes
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kFilterSection:
            return 2;
        case kFacebookSection:
            return 1;
        case kInfoSection:
            return 3;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PreferencesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }
    else {
        cell.textLabel.alpha = 1;
        cell.detailTextLabel.alpha = 1;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [[cell viewWithTag:kSwitchTag] removeFromSuperview];
    }

    PreferencesService *prefs = [PreferencesService sharedService];
    switch (indexPath.section) {
        case kFilterSection:
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = @"Toon alle verenigingen";
                    cell.detailTextLabel.text = @"";

                    CGRect toggleRect = CGRectMake(225, 9, 0, 0);
                    UISwitch *toggle = [[UISwitch alloc] initWithFrame:toggleRect];
                    toggle.tag = kSwitchTag;
                    toggle.on = !prefs.filterAssociations;
                    [toggle addTarget:self action:@selector(filterSwitch:didToggle:)
                                 forControlEvents:UIControlEventValueChanged];
                    [cell addSubview:toggle];
                } break;

                case 1: {
                    cell.textLabel.text = @"Selectie";
                    NSUInteger count = prefs.preferredAssociations.count;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", count,
                                                 count == 1 ? @"vereniging" : @"verenigingen"];

                    if (prefs.filterAssociations) {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    }
                    else {
                        cell.textLabel.alpha = 0.5;
                        cell.detailTextLabel.alpha = 0.5;
                    }
                } break;
            }
            break;
        case kFacebookSection: {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.text = @"Facebook";

            FacebookSession *session = [FacebookSession sharedSession];
            if (session.open) {
                id<FBGraphUser> userInfo = [session userInfo];
                cell.detailTextLabel.text = userInfo ? [userInfo name] : @"Aangemeld";
            }
            else {
                cell.detailTextLabel.text = @"Niet aangemeld";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        } break;

        case kInfoSection:
            switch (indexPath.row) {
                case 0: {
                    static NSString *TextCellIdentifier = @"PreferencesTextCell";
                    cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:CellIdentifier];
                        cell.textLabel.font = [UIFont systemFontOfSize:14];
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.numberOfLines = 0;
                        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.textLabel.text = @"Hydra werd ontwikkeld door Zeus WPI, "
                                           "de studentenwerkgroep informatica van "
                                           "de Universiteit Gent, in opdracht van "
                                           "de Dienst StudentenActiviteiten.";
                } break;

                case 1: {
                    UIImage *linkImage = [UIImage imageNamed:@"external-link"];
                    UIImage *highlightedLinkImage = [UIImage imageNamed:@"external-link-active"];
                    UIImageView *linkAccessory = [[UIImageView alloc] initWithImage:linkImage
                                                                   highlightedImage:highlightedLinkImage];
                    linkAccessory.contentMode = UIViewContentModeScaleAspectFit;
                    cell.accessoryView = linkAccessory;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.textLabel.text = @"Meer informatie";
                } break;

                case 2: {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.textLabel.text = @"Externe componenten";
                } break;
            }
            break;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kInfoSection && indexPath.row == 0) {
        return 88;
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:tableView heightForFooterInSection:(NSInteger)section
{
    if (section == kFilterSection) {
        return 68;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == kFilterSection) {
        CGRect infoRect = CGRectMake(10, 3, 300, 58);
        UILabel *info = [[UILabel alloc] initWithFrame:infoRect];
        info.backgroundColor = [UIColor clearColor];
        info.font = [UIFont systemFontOfSize:14];
        info.text = @"Selecteer verenigingen om activiteiten en nieuws"
                     "berichten te filteren. Berichten die in de kijker "
                     "staan worden steeds getoond.";
        info.lineBreakMode = UILineBreakModeWordWrap;
        info.numberOfLines = 0;
        info.shadowColor = [UIColor whiteColor];
        info.shadowOffset = CGSizeMake(0, 1);
        info.textAlignment = UITextAlignmentCenter;
        info.textColor = [UIColor H_hintColor];

        UIView *wrapper = [[UIView alloc] initWithFrame:CGRectZero];
        [wrapper addSubview:info];
        return wrapper;
    }
    else {
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)filterSwitch:(UISwitch *)toggle didToggle:(NSNotification *)notification
{
    PreferencesService *prefs = [PreferencesService sharedService];
    prefs.filterAssociations = !toggle.on;
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:kFilterSection];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    switch (indexPath.section) {
        case kFilterSection:
            if (indexPath.row == 1) {
                PreferencesService *prefs = [PreferencesService sharedService];
                if (prefs.filterAssociations) {
                    UIViewController *c = [[AssociationPreferenceController alloc] init];
                    [self.navigationController pushViewController:c animated:YES];
                }
            }
            break;
        case kFacebookSection: {
            FacebookSession *session = [FacebookSession sharedSession];
            if (session.open) {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Facebook"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Annuleren"
                                                     destructiveButtonTitle:@"Afmelden"
                                                          otherButtonTitles:nil];
                [sheet showInView:self.view];
            }
            else {
                [session openWithAllowLoginUI:YES];
            }

            [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } break;
        case kInfoSection: {
            if (indexPath.row == 1) {
                NSURL *url = [NSURL URLWithString:@"http://zeus.ugent.be/hydra"];
                [[UIApplication sharedApplication] openURL:url];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            else if (indexPath.row == 2) {
                UIViewController *c = [VTAcknowledgementsViewController acknowledgementsViewController];
                [self.navigationController pushViewController:c animated:YES];
            }
        }
    }
}

#pragma mark - Notifications

- (void)facebookUpdated:(NSNotification *)notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:kFacebookSection];
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ActionSheet callback

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index
{
    if (index == 0) {
        FacebookSession *session = [FacebookSession sharedSession];
        [session close];
    }
}

@end
