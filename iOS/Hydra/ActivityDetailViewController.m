//
//  ActivityDetailViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "AssociationActivity.h"

@interface ActivityDetailViewController ()

@property (nonatomic, strong) AssociationActivity *activity;

@end

@implementation ActivityDetailViewController

- (id)initWithActivity:(AssociationActivity *)activity
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.activity = activity;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActivityDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }

    static NSDateFormatter *dateStartFormatter = nil;
    static NSDateFormatter *dateEndFormatter = nil;
    if (!dateStartFormatter || !dateEndFormatter) {
        dateStartFormatter = [[NSDateFormatter alloc] init];
        [dateStartFormatter setDateFormat:@"EEE d MMMM H:mm"];
        dateEndFormatter = [[NSDateFormatter alloc] init];
        [dateEndFormatter setDateFormat:@"H:mm"];
    }

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Naam";
            cell.detailTextLabel.text = self.activity.title;
            break;
        case 1:
            cell.textLabel.text = @"Vereniging";
            cell.detailTextLabel.text = self.activity.associationId;
            break;
        case 2:
            cell.textLabel.text = @"Datum";
            if (self.activity.end) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                             [dateStartFormatter stringFromDate:self.activity.start],
                                             [dateEndFormatter stringFromDate:self.activity.end]];
            }
            else {
                cell.detailTextLabel.text = [dateStartFormatter stringFromDate:self.activity.start];
            }
            break;
        case 3:
            cell.textLabel.text = @"Locatie";
            cell.detailTextLabel.text = self.activity.location;
            break;
    }

    return cell;
}

@end
