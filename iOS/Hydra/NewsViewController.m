//
//  NewsViewController.m
//  Hydra
//
//  Created by Pieter Gunst on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "NewsViewController.h"
#import "AssociationStore.h"
#import "AssociationNewsItem.h"
#import "NewsItemViewController.h"
#import "AssociationNewsItem.h"
#import "Association.h"
#import "NSDateFormatter+AppLocale.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface NewsViewController ()

@property (nonatomic, strong) NSArray *newsItems;

@end

@implementation NewsViewController

- (id) init
{
    if (self = [super init]) {
        // Check for updates
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(newsUpdated:)
                       name:AssociationStoreDidUpdateNewsNotification
                     object:nil];

        self.newsItems = [AssociationStore sharedStore].newsItems;
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
    self.title = @"Nieuws";
    if([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor hydraTintColor];
        [refreshControl addTarget:self action:@selector(didPullRefreshControl:)
                 forControlEvents:UIControlEventValueChanged];

        self.refreshControl = refreshControl;
    }
}

- (void)didPullRefreshControl:(id)sender
{
    [[AssociationStore sharedStore] reloadNewsItems];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"News");

    if (self.newsItems.count == 0) {
        [SVProgressHUD show];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.newsItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    AssociationNewsItem *newsItem = self.newsItems[indexPath.row];
    Association *association = newsItem.association;

    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateFormatter.dateFormat = @"EEEE d MMMM";
    }

    NSString *detailText = [NSString stringWithFormat:@"%@, %@", association.displayName, [dateFormatter stringFromDate:newsItem.date]];
    cell.textLabel.text = newsItem.title;
    cell.detailTextLabel.text = detailText;
    
    return cell;
}

- (void)newsUpdated:(NSNotification *)notification
{
    DLog(@"Updating tableView for news items");
    self.newsItems = [AssociationStore sharedStore].newsItems;
    [self.tableView reloadData];

    // Hide or update HUD
    if ([SVProgressHUD isVisible]) {
        if (self.newsItems.count > 0) {
            [SVProgressHUD dismiss];
        }
        else {
            NSString *errorMsg = @"Geen nieuws gevonden";
            [SVProgressHUD showErrorWithStatus:errorMsg];
        }
    }
    if ([UIRefreshControl class]) {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssociationNewsItem *item = self.newsItems[indexPath.row];
    NewsItemViewController *c = [[NewsItemViewController alloc] initWithNewsItem:item];
    [self.navigationController pushViewController:c animated:YES];
}

@end
