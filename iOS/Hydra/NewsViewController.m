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

@interface NewsViewController ()

@property (nonatomic, strong) NSArray *associations;
@property (nonatomic, strong) NSMutableArray *newsItems;

@end

@implementation NewsViewController

- (id) initWithAssociations:(NSArray *)associations{
    self = [super init];
    if (self = [super init]) {
        self.associations = associations;
        [self refreshNewsItems];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    // Set title in navigation bar, slightly different title on return button
    [self.navigationItem setTitle:@"Nieuws"];

    // Check for updates
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(newsUpdated:)
                name:AssociationStoreDidUpdateNewsNotification
                object:nil];
     
    // TODO: show loading overlay when no items found yet
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refreshNewsItems
{
    self.newsItems = [NSMutableArray new];
    for (Association *association in self.associations) {
        NSArray *newsItems = [[AssociationStore sharedStore] newsItemsForAssocation:association];
        [self.newsItems addObjectsFromArray:newsItems];
    }
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
    [self refreshNewsItems];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssociationNewsItem *item = self.newsItems[indexPath.row];
    NewsItemViewController *c = [[NewsItemViewController alloc] initWithNewsItem:item];
    [self.navigationController pushViewController:c animated:YES];
}

@end
