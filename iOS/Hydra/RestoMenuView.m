//
//  RestoMenuView.m
//  Hydra
//
//  Created by Yasser Deceukelier on 22/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMenuView.h"
#import "NSDate+Utilities.h"

@interface RestoMenuView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDate *day;
@property (nonatomic, strong) RestoMenu *menu;

@property (nonatomic, unsafe_unretained) UIView *contentView;
@property (nonatomic, unsafe_unretained) UILabel *dateHeader;
@property (nonatomic, unsafe_unretained) UITableView *tableView;
@property (nonatomic, unsafe_unretained) UIImageView *closedView;
@property (nonatomic, unsafe_unretained) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) UIView *soupHeader;
@property (nonatomic, strong) UIView *meatHeader;
@property (nonatomic, strong) UIView *vegetableHeader;

@end

@implementation RestoMenuView

#pragma mark - Constants

#define kDateHeaderHeight 45
#define kSectionHeaderHeight 35
#define kSectionFooterHeight 20
#define kRowHeight 22
#define kCellLabelTag 101

#pragma mark - Properties and init

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}


- (void)configureWithDay:(NSDate *)day andMenu:(id)menu
{
    if (![self.day isEqual:day] || ![self.menu isEqual:menu]) {
        self.day = day;
        self.menu = (menu != [NSNull null]) ? menu : nil;
        [self reloadData];
    }
}

- (void)createView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor whiteColor];

    CGRect headerFrame = CGRectMake(0, 0, self.frame.size.width, kDateHeaderHeight);
    UIImageView *header = [[UIImageView alloc] initWithFrame:headerFrame];
    header.contentMode = UIViewContentModeScaleToFill;
    header.image = [UIImage imageNamed:@"header-bg"];
    [self addSubview:header];

    CGRect dateHeaderFrame = CGRectMake(0, 3, self.frame.size.width, kDateHeaderHeight - 3);
    UILabel *dateHeader = [[UILabel alloc] initWithFrame:dateHeaderFrame];
    dateHeader.font = [UIFont boldSystemFontOfSize:19];
    dateHeader.textAlignment = UITextAlignmentCenter;
    dateHeader.textColor = [UIColor whiteColor];
    dateHeader.backgroundColor = [UIColor clearColor];
    dateHeader.shadowColor = [UIColor blackColor];
    dateHeader.shadowOffset = CGSizeMake(0, 2);
    [header addSubview:dateHeader];
    self.dateHeader = dateHeader;

    CGRect tableFrame = CGRectMake(0, headerFrame.size.height, self.frame.size.width,
                                   self.bounds.size.height - headerFrame.size.height);
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    tableView.rowHeight = kRowHeight;
    tableView.separatorColor = [UIColor clearColor];
    tableView.allowsSelection = NO;
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 5)];
    [self addSubview:tableView];
    self.tableView = tableView;

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.center;
    [self addSubview:spinner];
    self.spinner = spinner;

    CGRect closedFrame = CGRectMake(0, kDateHeaderHeight, self.frame.size.width,
                                    self.frame.size.height - 2*kDateHeaderHeight);
    UIImageView *closedView = [[UIImageView alloc] initWithFrame:closedFrame];
    closedView.image = [UIImage imageNamed:@"resto-closed.jpg"];
    closedView.contentMode = UIViewContentModeCenter;
    [self addSubview:closedView];
    self.closedView = closedView;
}

- (void)reloadData
{    
    NSString *dateString;
    if ([self.day isToday]) dateString = @"Vandaag";
    else if ([self.day isTomorrow]) dateString = @"Morgen";
    else {
        // Create capitalized, formatted string
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE d MMMM"];
        dateString = [formatter stringFromDate:self.day];
        dateString = [dateString stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                      withString:[[dateString substringToIndex:1] capitalizedString]];
    }
    [self.dateHeader setText:dateString];

    self.spinner.hidden = (self.menu != nil);
    if (!self.spinner.hidden) [self.spinner startAnimating];
    self.closedView.hidden = (self.menu == nil || self.menu.open);

    [self.tableView reloadData];
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.menu.open ? 3 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 1;
        case 1: return self.menu.meat.count;
        case 2: return self.menu.vegetables.count;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *textLabel;

    static NSString *cellIdentifier = @"RestoMenuViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                      reuseIdentifier:cellIdentifier];
        CGRect labelFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 70, kRowHeight - 1);
        textLabel = [[UILabel alloc] initWithFrame:labelFrame];
        textLabel.tag = kCellLabelTag;
        textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        [cell.contentView addSubview:textLabel];

        cell.detailTextLabel.textColor = textLabel.textColor;
    }
    else {
        textLabel = (UILabel *)[cell viewWithTag:kCellLabelTag];
    }

    textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.font = textLabel.font;

    if(indexPath.section == 0) {
        textLabel.text = self.menu.soup.name;
        cell.detailTextLabel.text = self.menu.soup.price;
    }
    else if (indexPath.section == 1) {
        RestoMenuItem *item = self.menu.meat[indexPath.row];
        
        if(item.recommended) {
            textLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.detailTextLabel.font = textLabel.font;
        }

        textLabel.text = item.name;
        cell.detailTextLabel.text = item.price;
    }
    else { // section == 2
        textLabel.text = (self.menu.vegetables)[indexPath.row];
    }
    
    return cell;
}

#pragma mark - Table view delegate 

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 0) {
        if(!self.soupHeader) {
            UIImage *soupImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-soup" ofType:@"png"]];
            self.soupHeader = [self headerWithImage:soupImage andTitle:@"Soep"];
        }
        return self.soupHeader;
    }
    else if(section == 1) {
        if(!self.meatHeader) {
            UIImage *meatImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-meal" ofType:@"png"]];
            self.meatHeader = [self headerWithImage:meatImage andTitle:@"Vlees en veggie"];
        }
        return self.meatHeader;
    }
    else { //section == 2
        if(!self.vegetableHeader) {
            UIImage *vegetableImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-vegetables" ofType:@"png"]];
            self.vegetableHeader = [self headerWithImage:vegetableImage andTitle:@"Groenten"];
        }
        return self.vegetableHeader;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return (section < 2) ? kSectionFooterHeight : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UILabel *tildeLabel = nil;
    if(section < 2) {
        tildeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tildeLabel.font = [UIFont fontWithName:@"Baskerville-Italic" size:28];
        tildeLabel.textAlignment = UITextAlignmentCenter;
        tildeLabel.text = @"~";
        tildeLabel.textColor = [UIColor lightGrayColor];
    }
    return tildeLabel;
}
 
#pragma mark - Utility methods

- (UIView *)headerWithImage:(UIImage *)image andTitle:(NSString *)title {
    CGRect headerFrame = CGRectMake(0, 0, self.bounds.size.width, kSectionHeaderHeight);
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];

    UIFont *font = [UIFont fontWithName:@"Baskerville-SemiBold" size:20];
    CGSize textSize = [title sizeWithFont:font];
    NSUInteger padding = (self.bounds.size.width - textSize.width) / 2;

    CGRect iconFrame = CGRectMake(padding - kSectionHeaderHeight - 5, 1,
                                  kSectionHeaderHeight - 5, kSectionHeaderHeight - 5);
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.image = image;
    [header addSubview:iconView];
    
    CGRect titleFrame = CGRectMake(padding, 0, textSize.width, kSectionHeaderHeight - 5);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    titleLabel.font = font;
    titleLabel.text = title;
    [header addSubview:titleLabel];
    
    return header;
}

@end
