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
#import "WebViewController.h"

@implementation SchamperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        articles = [[SchamperStore sharedStore] articles];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set title in navigation bar
    [[self navigationItem] setTitle:@"Schamper Daily"];

    // Check for updates
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(articlesUpdated:)
                   name:SchamperStoreDidUpdateArticlesNotification
                 object:nil];
    [[SchamperStore sharedStore] updateArticles];

    // TODO: show loading overlay when no items found yet
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SchamperCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    SchamperArticle *article = [articles objectAtIndex:indexPath.row];
    cell.textLabel.text = article.title;
    cell.detailTextLabel.text = article.author;
    
    return cell;
}

- (void)articlesUpdated:(NSNotification *)notification
{
    DLog(@"Updating tableView");
    articles = [[notification object] articles];
    [[self tableView] reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WebViewController *c = [[WebViewController alloc] init];
    SchamperArticle *article = [articles objectAtIndex:[indexPath row]];
    [[c webView] loadHTMLString:[article body] baseURL:nil];

    [[self navigationController] pushViewController:c animated:YES];
}

@end
