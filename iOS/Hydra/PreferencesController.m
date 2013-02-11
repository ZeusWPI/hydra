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

#define kFilterSection 0
#define kFacebookSection 1

#define kFilterPref @"useAssociationFilter"
#define kAssociationsPref @"preferredAssociations"

#define kSwitchTag 500

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kFilterSection:
            return 2;
        case kFacebookSection:
            return 1;
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

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    switch (indexPath.section) {
        case kFilterSection:
            switch (indexPath.row) {
                case 0: {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"Beperk inhoud";
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryNone;

                    CGRect toggleRect = CGRectMake(225, 9, 0, 0);
                    UISwitch *toggle = [[UISwitch alloc] initWithFrame:toggleRect];
                    toggle.tag = kSwitchTag;
                    toggle.on = [settings boolForKey:kFilterPref];
                    [toggle addTarget:self action:@selector(filterSwitch:didToggle:)
                                 forControlEvents:UIControlEventValueChanged];
                    [cell addSubview:toggle];
                } break;

                case 1: {
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.textLabel.text = @"Verenigingen";
                    NSArray *associations = [settings objectForKey:kAssociationsPref];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d geselecteerd", associations.count];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    [[cell viewWithTag:kSwitchTag] removeFromSuperview];
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
    }

    return cell;
}

- (CGFloat)tableView:tableView heightForFooterInSection:(NSInteger)section
{
    if (section == kFilterSection) {
        return 58;
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
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:toggle.on forKey:kFilterPref];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    switch (indexPath.section) {
        case kFilterSection:
            switch (indexPath.row) {
                case 1: {
                    UIViewController *c = [[AssociationPreferenceController alloc] init];
                    [self.navigationController pushViewController:c animated:YES];
                } break;
            }
            break;
        case kFacebookSection: {
            FacebookSession *session = [FacebookSession sharedSession];
            if (session.open) {
                // TODO: show actionpicker to allow logoff
                [session close];
            }
            else {
                [session openWithAllowLoginUI:YES];
            }

            [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } break;
    }
}

#pragma mark - Notifications

- (void)facebookUpdated:(NSNotification *)notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:kFacebookSection];
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
