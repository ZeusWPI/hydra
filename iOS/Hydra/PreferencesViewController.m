//
//  PreferencesViewController.m
//  Hydra
//
//  Created by Toon Willems on 07/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "PreferencesViewController.h"
#import "Association.h"
#import "AssociationStore.h"

@interface PreferencesViewController ()

@property (nonatomic, strong) NSArray *konventen;
@property (nonatomic, strong) NSDictionary *associations;
@property (nonatomic, strong) NSMutableArray *filteredKonventen;
@property (nonatomic, strong) NSMutableDictionary *filteredAssociations;
@property (nonatomic, strong) UISearchDisplayController *searchController;

@end

@implementation PreferencesViewController
- (id)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        [self loadAssocations];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"preferredAssociations"] == nil){
            [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init]
                                                      forKey:@"preferredAssociations"];
        }
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
        searchBar.delegate = self;
        self.tableView.tableHeaderView = searchBar;
        self.searchController = [[UISearchDisplayController alloc]
                                 initWithSearchBar:searchBar contentsController:self];
        self.searchController.delegate = self;
        self.searchController.searchResultsDataSource = self;
        self.searchController.searchResultsDelegate = self;
    }
    return self;}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Voorkeuren";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadAssocations
{
    NSArray *arr = [[Association loadFromPlist] allValues];
    self.konventen = [[NSSet setWithArray:[arr valueForKey:@"parentAssociation"]] allObjects];
    self.filteredKonventen = [NSMutableArray arrayWithArray:self.konventen];


    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
    for (NSString *name in self.konventen) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",
                             @"parentAssociation", name];
        [tmp setObject:[arr filteredArrayUsingPredicate:pred] forKey:name];
    }
    self.associations = tmp;
    self.filteredAssociations = [NSMutableDictionary dictionaryWithDictionary:self.associations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Search Control Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = [searchText lowercaseString];
    if ([searchText length] > 0) {
        for(NSString *konvent in [self.associations allKeys]) {
            NSPredicate *filterPred = [NSPredicate predicateWithBlock:
                                       ^(id association, NSDictionary *bindings){
                return (BOOL)([[((Association *)association).displayedFullName lowercaseString]
                               rangeOfString:searchText].location != NSNotFound);
            }];

            self.filteredAssociations[konvent] = [self.associations[konvent] filteredArrayUsingPredicate:filterPred];
            
            if ([self.filteredAssociations[konvent] count] == 0) {
                [self.filteredKonventen removeObject:konvent];
            }
        }
    }
    else {
        self.filteredAssociations = [NSMutableDictionary dictionaryWithDictionary:self.associations];
        self.filteredKonventen = [NSMutableArray arrayWithArray:self.konventen];
    }
    [self.tableView reloadData];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    // Updates the regular tableView after cancel has been pressed.
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [[AssociationStore sharedStore] associationWithName:self.konventen[section]].displayedFullName;
    }
    else {
        return [[AssociationStore sharedStore] associationWithName:self.filteredKonventen[section]].displayedFullName;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return [self.konventen count];
    }
    else {
        return [self.filteredKonventen count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [self.associations[self.konventen[section]] count];
    }
    else {
        return [self.filteredAssociations[self.filteredKonventen[section]] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *preferred = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferredAssociations"];


    static NSString *CellIdentifier = @"AssociationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    Association *association;
    if (tableView == self.tableView) {
        association = self.associations[self.konventen[indexPath.section]][indexPath.row];
    }
    else {
        association = self.filteredAssociations[self.filteredKonventen[indexPath.section]][indexPath.row];
    }

    if ([preferred containsObject:association.internalName]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = nil;
    }
    if (association.fullName) {
        cell.textLabel.text = association.fullName;
    }
    else {
        cell.textLabel.text = association.displayedFullName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name;
    if (false) {
        name = ((Association*)self.associations[self.konventen[indexPath.section]][indexPath.row]).internalName;
    }
    else {
        name = ((Association*)self.filteredAssociations[self.filteredKonventen[indexPath.section]][indexPath.row]).internalName;
    }

    NSMutableArray *preferred = [[[NSUserDefaults standardUserDefaults] objectForKey:@"preferredAssociations"] mutableCopy];

    if ([preferred containsObject:name]) {
        [preferred removeObject:name];
    }
    else {
        [preferred addObject:name];
    }
    [[NSUserDefaults standardUserDefaults] setObject:preferred forKey:@"preferredAssociations"];

    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
