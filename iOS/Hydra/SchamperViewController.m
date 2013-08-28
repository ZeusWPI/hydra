//
//  SchamperViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 29/06/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "SchamperViewController.h"
#import "SchamperStore.h"
#import "SchamperArticle.h"
#import "SchamperDetailViewController.h"
#import "SORelativeDateTransformer.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SchamperViewController ()

@property (nonatomic, strong) NSArray *articles;

@end

@implementation SchamperViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.articles = [[SchamperStore sharedStore] articles];

        // Check for updates
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(articlesUpdated:)
                       name:SchamperStoreDidUpdateArticlesNotification
                     object:nil];
        [[SchamperStore sharedStore] updateArticles];
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

    // Set title in navigation bar, slightly different title on return button
    self.title = @"Schamper Daily";
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithTitle:@"Schamper"
                                                           style:UIBarButtonItemStyleBordered
                                                          target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:bb];

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
    [[SchamperStore sharedStore] reloadArticles];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Schamper");

    if (self.articles.count == 0) {
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
    return self.articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SchamperCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    SchamperArticle *article = self.articles[indexPath.row];

    if (article.read){
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    }
    else {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    }

    SORelativeDateTransformer *dateTransformer = [[SORelativeDateTransformer alloc] init];
    NSString *transformedDate = [dateTransformer transformedValue:article.date];

    cell.textLabel.text = article.title;
    NSString *detail = [NSString stringWithFormat:@"%@ door %@", transformedDate, article.author];
    cell.detailTextLabel.text = detail;
    return cell;
}

- (void)articlesUpdated:(NSNotification *)notification
{
    DLog(@"Updating tableView");
    self.articles = [notification.object articles];
    [self.tableView reloadData];

    // Hide or update HUD
    if ([SVProgressHUD isVisible]) {
        if (self.articles.count > 0) {
            [SVProgressHUD dismiss];
        }
        else {
            NSString *errorMsg = @"Geen artikels gevonden";
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
    SchamperArticle *article = self.articles[indexPath.row];
    if (!article.read){
        article.read = YES;
        [tableView reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    SchamperDetailViewController *controller = [[SchamperDetailViewController alloc] initWithArticle:article];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
