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
#import "NSDate+Utilities.h"

@interface SchamperViewController ()

@property (nonatomic, strong) NSArray *articles;

@end

@implementation SchamperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.articles = [[SchamperStore sharedStore] articles];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set title in navigation bar, slightly different title on return button
    [[self navigationItem] setTitle:@"Schamper Daily"];
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithTitle:@"Schamper"
                                                           style:UIBarButtonItemStyleBordered
                                                          target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:bb];

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

    SchamperArticle *article = (self.articles)[indexPath.row];
    cell.textLabel.text = article.title;
    cell.detailTextLabel.text = article.author;
    
    return cell;
}

- (void)articlesUpdated:(NSNotification *)notification
{
    DLog(@"Updating tableView");
    self.articles = [[notification object] articles];
    [[self tableView] reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SchamperArticle *article = (self.articles)[indexPath.row];
    SchamperDetailViewController *controller = [[SchamperDetailViewController alloc] initWithArticle:article];
    [self.navigationController pushViewController:controller animated:YES];
}
/* Does not work right
- (NSString *) formatDate: (NSDate *) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return [formatter stringFromDate:date];
}
*/
@end
