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
#import "NewsDetailViewController.h"
#import "AssociationNewsItem.h"
#import "Association.h"
#import "NSDateFormatter+AppLocale.h"
#import "PreferencesService.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface NewsViewController ()

@property (nonatomic, strong) NSArray *newsItems;
@property (nonatomic, assign) BOOL update;
@end

@implementation NewsViewController

- (id)init
{
    if (self = [super init]) {
        // Check for updates
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(newsUpdated:)
                       name:AssociationStoreDidUpdateNewsNotification
                     object:nil];

        [self loadNews];
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

    if ([UIRefreshControl class]) {
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

    // TODO: what if there are 0 due to filters
    if (self.newsItems.count == 0) {
        [SVProgressHUD show];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    if ([self isMovingFromParentViewController]) {
        [[AssociationStore sharedStore] updateStoreCache];
        self.update = NO;
    }
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
        dateFormatter.dateFormat = @"EE d MMM";
    }
    NSString *detailText = [NSString stringWithFormat:@"%@, %@", [dateFormatter stringFromDate:newsItem.date], association.displayName];
    cell.textLabel.text = newsItem.title;
    cell.detailTextLabel.text = detailText;

    if (newsItem.read){
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    }
    else {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    }

    if (newsItem.highlighted) {
        UIImageView *star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-star"]];
        cell.accessoryView = star;
    }
    else {
        cell.accessoryView = nil;
    }

    return cell;
}

- (void)loadNews
{
    NSArray *newsItems = [AssociationStore sharedStore].newsItems;

    // Filter news items
    PreferencesService *prefs = [PreferencesService sharedService];
    if (prefs.filterAssociations) {
        NSArray *associations = prefs.preferredAssociations;
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
            return [associations containsObject:[obj association].internalName] ||
                   [obj highlighted];
        }];
        newsItems = [newsItems filteredArrayUsingPredicate:pred];
    }

    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    self.newsItems = [newsItems sortedArrayUsingDescriptors:@[desc]];
}

- (void)newsUpdated:(NSNotification *)notification
{
    DLog(@"Updating tableView for news items");
    [self loadNews];
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
    if (!item.read){
        item.read = YES;
        if (!self.update) {
            self.update = YES;
            [AssociationStore sharedStore].updateCache = YES;
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    NewsDetailViewController *c = [[NewsDetailViewController alloc] initWithNewsItem:item];
    [self.navigationController pushViewController:c animated:YES];
}

@end
