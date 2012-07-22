//
//  RestoMenuView.m
//  Hydra
//
//  Created by Yasser Deceukelier on 22/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMenuView.h"
#import "NSDate+Utilities.h"

@implementation RestoMenuView
{
    UILabel *dateHeader;
    
    UIView *soupHeader;
    UIView *meatHeader;
    UIView *vegetableHeader;
    
    UIActivityIndicatorView *spinner;
}

#pragma mark - Constants

#define kDateHeaderHeight 50
#define kRowHeight 30

#define kSectionHeaderHeight 40
#define kTableViewHeight 356
#define kTableViewWidth 280

#pragma mark - Static stuff

+ (UIView *)headerWithImage:(UIImage *)image andTitle:(NSString *)title {
    
    CGFloat edge = 5;
    CGRect headerFrame = CGRectMake(0, 0,kTableViewWidth, kSectionHeaderHeight);
    CGRect iconFrame = CGRectMake(edge, edge, kSectionHeaderHeight -2*edge, kSectionHeaderHeight -2*edge);
    CGRect labelFrame = CGRectMake(kSectionHeaderHeight, 0, kTableViewWidth -2*kSectionHeaderHeight, kSectionHeaderHeight);
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:iconFrame];
    imageView.image = image;
    [header addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:kSectionHeaderHeight/2];
    titleLabel.text = title;
    [header addSubview:titleLabel];
    
    return header;
}

#pragma mark - Propety & init methode

@synthesize menu = _menu;

- (void)setMenu:(RestoMenu *)menu {
    
    if(_menu != menu) {
        _menu = menu;
        if(_menu) {
        	[spinner stopAnimating];
            [spinner removeFromSuperview];
        	[self reloadData];
        } else {
            [self reloadData];
            [self addSubview:spinner];
            [spinner startAnimating];
        }
    }
}

- (id)initWithRestoMenu:(RestoMenu *)menu andDate:(NSDate *)day{
    
    CGRect frame = CGRectMake(0, 0, kTableViewWidth, kTableViewHeight);
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if(self) {
        
        self.dataSource = self;
        self.delegate = self;
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = self.center;
        
        _menu = menu;
        if(menu && !_menu.open) {
            
            CGRect closedFrame = CGRectMake(0, kDateHeaderHeight, self.bounds.size.width, self.bounds.size.height -kDateHeaderHeight);
            UIImageView *closedView = [[UIImageView alloc] initWithFrame:closedFrame];
            closedView.image = [UIImage imageNamed:@"resto-closed.jpg"];
            [self addSubview:closedView];
        } else if (!menu) {
            [self addSubview:spinner];
            [spinner startAnimating];
        }
        
        CGRect headerFrame = CGRectMake(0, 0, kTableViewWidth, kDateHeaderHeight);
        UIImageView *tableViewHeader = [[UIImageView alloc] initWithFrame:headerFrame];
        tableViewHeader.contentMode = UIViewContentModeScaleToFill;
        tableViewHeader.image = [UIImage imageNamed:@"header-bg"];

        dateHeader = [[UILabel alloc] initWithFrame:tableViewHeader.bounds];
        dateHeader.font = [UIFont boldSystemFontOfSize:kDateHeaderHeight/2];
        dateHeader.textAlignment = UITextAlignmentCenter;
        dateHeader.textColor = [UIColor whiteColor];
        dateHeader.backgroundColor = [UIColor clearColor];
        
        NSString *dateString;
        if ([day isToday]) dateString = @"Vandaag";
        else if ([day isTomorrow]) dateString = @"Morgen";
        else {
            // Create capitalized, formatted string
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE d MMMM"];
            dateString = [formatter stringFromDate:day];
            dateString = [dateString stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                             withString:[[dateString substringToIndex:1] capitalizedString]];
        }
        dateHeader.text = dateString;
        
        [tableViewHeader addSubview:dateHeader];
        self.tableHeaderView = tableViewHeader;
        
        self.bounces = NO;
        self.rowHeight = kRowHeight;
        self.separatorColor = [UIColor clearColor];
        self.allowsSelection = NO;
    }
    return self;
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.menu.open ? 3 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return 1;
    } else if (section == 1) {
        return [self.menu.meat count];
    } else { //section == 2
        return [self.menu.vegetables count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
     //}
        cell.textLabel.font = [UIFont systemFontOfSize:kRowHeight/2];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:kRowHeight/2];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }

    if(indexPath.section == 0) {
        
        cell.textLabel.text = self.menu.soup.name;
        cell.detailTextLabel.text = self.menu.soup.price;
    } else if (indexPath.section == 1) {
        
        RestoMenuItem *item = [self.menu.meat objectAtIndex:indexPath.row];
        cell.textLabel.text = item.name;
        cell.detailTextLabel.text = item.price;
    } else { //section == 2
        
        cell.textLabel.text = [self.menu.vegetables objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - Table view delegate 

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 0) {
        
        if(!soupHeader) {
            UIImage *soupImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-soup" ofType:@"png"]];
            soupHeader = [RestoMenuView headerWithImage:soupImage andTitle:@"Soep"];
        }
        return soupHeader;
    }
    else if(section == 1) {
        
        if(!meatHeader) {
            UIImage *meatImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-meal" ofType:@"png"]];
            meatHeader = [RestoMenuView headerWithImage:meatImage andTitle:@"Vlees"];
        }
        return meatHeader;
    }
    else { //section == 2
        
        if(!vegetableHeader) {
            UIImage *vegetableImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon-vegetables" ofType:@"png"]];
            vegetableHeader = [RestoMenuView headerWithImage:vegetableImage andTitle:@"Groenten"];
        }
        return vegetableHeader;
    }
}

@end
