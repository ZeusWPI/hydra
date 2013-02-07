//
//  PreferencesViewController.m
//  Hydra
//
//  Created by Toon Willems on 07/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "PreferencesViewController.h"
#import "Association.h"

@interface PreferencesViewController ()

@property (nonatomic, strong) NSArray *associations;

@end

@implementation PreferencesViewController
- (id)init {
    if (self = [super init]) {
        [self loadAssocations];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"preferredAssociations"] == nil){
            DLog(@"TESTING");
            [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init]
                                                      forKey:@"preferredAssociations"];
        }
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
    self.associations = [[Association loadFromPlist] allValues];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.associations.count;
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

    Association *association = self.associations[indexPath.row];

    if ([preferred containsObject:association.internalName]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = nil;
    }
    cell.textLabel.text = association.displayedFullName;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = ((Association*)self.associations[indexPath.row]).internalName;
    NSMutableArray *preferred = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferredAssociations"];

    if ([preferred containsObject:name]) {
        [preferred removeObject:name];
    }
    else {
        [preferred addObject:name];
    }

    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
