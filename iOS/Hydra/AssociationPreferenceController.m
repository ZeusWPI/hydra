//
//  AssociationPreferenceController.m
//  Hydra
//
//  Created by Toon Willems on 07/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "AssociationPreferenceController.h"
#import "Association.h"
#import "AssociationStore.h"

#define kAssociationsPref @"preferredAssociations"

@interface AssociationPreferenceController () <UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray *convents;
@property (nonatomic, strong) NSDictionary *associations;
@property (nonatomic, strong) NSMutableArray *filteredConvents;
@property (nonatomic, strong) NSMutableDictionary *filteredAssociations;
@property (nonatomic, strong) UISearchDisplayController *searchController;

@end

@implementation AssociationPreferenceController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        [self loadAssocations];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kAssociationsPref] == nil){
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray array]
                                                      forKey:kAssociationsPref];
        }
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.placeholder = @"Zoek een vereniging";
    self.tableView.tableHeaderView = searchBar;

    self.searchController = [[UISearchDisplayController alloc]
                             initWithSearchBar:searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Verenigingen";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Voorkeuren > Verenigingen");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadAssocations
{
    NSArray *all = [[AssociationStore sharedStore] assocations];

    // Get all unique parent organisations
    NSSet *convents = [NSSet setWithArray:[all valueForKey:@"parentAssociation"]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    self.convents = [convents sortedArrayUsingDescriptors:@[sort]];
    self.filteredConvents = [self.convents mutableCopy];

    // Group by parentAssociation
    NSMutableDictionary *grouped = [[NSMutableDictionary alloc] init];
    sort = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    for (NSString *name in self.convents) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",
                             @"parentAssociation", name];
        grouped[name] = [[all filteredArrayUsingPredicate:pred]
                         sortedArrayUsingDescriptors:@[sort]];
    }
    self.associations = grouped;
    self.filteredAssociations = [self.associations mutableCopy];
}

#pragma mark - Search Control Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)query
{
    if (query.length > 0) {
        for(NSString *convent in [self.associations allKeys]) {
            NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject matches:query];
            }];
            self.filteredAssociations[convent] = [self.associations[convent] filteredArrayUsingPredicate:filter];

            // Remove convent from list if it does not have any items
            if ([self.filteredAssociations[convent] count] == 0) {
                [self.filteredConvents removeObject:convent];
            }
            // Check if convent with items is present
            else if (![self.filteredConvents containsObject:convent]) {
                [self.filteredConvents addObject:convent];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
                NSArray *sorted = [self.filteredConvents sortedArrayUsingDescriptors:@[sort]];
                self.filteredConvents = [sorted mutableCopy];
            }
        }
    }
    else {
        self.filteredAssociations = [self.associations mutableCopy];
        self.filteredConvents = [self.convents mutableCopy];
    }

    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *internalName;
    if (tableView == self.tableView) {
        internalName = self.convents[section];
    }
    else {
        internalName = self.filteredConvents[section];
    }

    Association *association = [[AssociationStore sharedStore] associationWithName:internalName];
    return association.displayName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return self.convents.count;
    }
    else {
        return self.filteredConvents.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [self.associations[self.convents[section]] count];
    }
    else {
        return [self.filteredAssociations[self.filteredConvents[section]] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AssociationPreferenceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }

    Association *association;
    if (tableView == self.tableView) {
        NSString *convent = self.convents[indexPath.section];
        association = self.associations[convent][indexPath.row];
    }
    else {
        NSString *convent = self.filteredConvents[indexPath.section];
        association = self.filteredAssociations[convent][indexPath.row];
    }
    cell.textLabel.text = association.fullName;

    NSArray *preferred = [[NSUserDefaults standardUserDefaults] objectForKey:kAssociationsPref];
    if ([preferred containsObject:association.internalName]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = nil;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name;
    if (tableView == self.tableView) {
        NSString *convent = self.convents[indexPath.section];
        name = [self.associations[convent][indexPath.row] internalName];
    }
    else {
        NSString *convent = self.filteredConvents[indexPath.section];
        name = [self.filteredAssociations[convent][indexPath.row] internalName];
    }

    NSMutableArray *preferred = [[[NSUserDefaults standardUserDefaults] objectForKey:kAssociationsPref] mutableCopy];
    if ([preferred containsObject:name]) {
        [preferred removeObject:name];
    }
    else {
        [preferred addObject:name];
    }
    [[NSUserDefaults standardUserDefaults] setObject:preferred forKey:kAssociationsPref];

    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
