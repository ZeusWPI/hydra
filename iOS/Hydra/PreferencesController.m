//
//  PreferencesController.m
//  Hydra
//
//  Created by Pieter De Baets on 08/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "PreferencesController.h"
#import "AssociationPreferenceController.h"

#define kFilterSection 0
#define kFilterPref @"useAssociationFilter"

@implementation PreferencesController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        // Custom initialization
    }
    return self;
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PreferencesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }

    switch (indexPath.section) {
        case kFilterSection:
            switch (indexPath.row) {
                case 0: {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"Filter inhoud";

                    CGRect toggleRect = CGRectMake(225, 9, 0, 0);
                    UISwitch *toggle = [[UISwitch alloc] initWithFrame:toggleRect];
                    toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:kFilterPref];
                    [toggle addTarget:self action:@selector(filterSwitch:didToggle:)
                                 forControlEvents:UIControlEventValueChanged];
                    [cell addSubview:toggle];
                } break;

                case 1:
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.textLabel.text = @"Verenigingen";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
            }
            break;
    }

    return cell;
}

- (CGFloat)tableView:tableView heightForFooterInSection:(NSInteger)section
{
    if (section == kFilterSection) {
        return 150;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == kFilterSection) {
        CGRect infoRect = CGRectMake(10, 3, 300, 56);
        UILabel *info = [[UILabel alloc] initWithFrame:infoRect];
        info.backgroundColor = [UIColor clearColor];
        info.font = [UIFont systemFontOfSize:14];
        info.text = @"Selecteer verenigingen om activiteiten en "
                     "nieuwsberichten te filteren. Berichten die in de kijker "
                     "staan worden steeds getoond.";
        info.lineBreakMode = UILineBreakModeWordWrap;
        info.numberOfLines = 0;
        info.shadowColor = [UIColor whiteColor];
        info.shadowOffset = CGSizeMake(0, 1);
        info.textAlignment = UITextAlignmentCenter;
        info.textColor = [UIColor colorWithWhite:0.2 alpha:1];

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
    [[NSUserDefaults standardUserDefaults] setBool:toggle.on forKey:kFilterPref];
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
    }
}

@end
