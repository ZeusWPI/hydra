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

@interface NewsViewController ()

@property (nonatomic, strong) NSArray *associations;
@property (nonatomic, strong) NSMutableArray *newsItems;


@end

@implementation NewsViewController

- (id) initWithAssociations: (NSArray *) associations{
    self = [super init];
    if (self) {
        if([associations count] == 0){
            self.associations = [[AssociationStore sharedStore] associations];
        }else{
            self.associations = associations;
        }
        [self pullNewsItems];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    // Set title in navigation bar, slightly different title on return button
    [[self navigationItem] setTitle:@"Nieuws"];
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithTitle:@"Terug"
                                                            style:UIBarButtonItemStyleBordered
                                                           target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:bb];
    
    // Check for updates
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(newsUpdated:)
                name:AssociationStoreDidUpdateNewsNotification
                object:nil];
     
    // TODO: show loading overlay when no items found yet

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) pullNewsItems {
    self.newsItems = [NSMutableArray new];
    for(int i=0;i<[self.associations count];i++){
        [self.newsItems addObjectsFromArray:[[AssociationStore sharedStore] newsItemsForAssocation:[self.associations objectAtIndex:i]]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.newsItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    AssociationNewsItem *newsItem = [self.newsItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = newsItem.title;
    NSString *detailText = [NSString stringWithFormat:@"%@ - %@",[self formatDate:newsItem.date],newsItem.associationId];
    cell.detailTextLabel.text = detailText;
    
    return cell;
}

- (void)newsUpdated:(NSNotification *)notification
{
    DLog(@"Updating tableView for news items");
    [self pullNewsItems];
    [[self tableView] reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssociationNewsItem *item = [self.newsItems objectAtIndex:indexPath.row];
    NewsItemViewController *c = [[NewsItemViewController alloc]initWithBody:item.body];
    [self.navigationController pushViewController:c animated:YES];
    
}

- (NSString *) formatDate: (NSDate *) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return [formatter stringFromDate:date];
}


@end
