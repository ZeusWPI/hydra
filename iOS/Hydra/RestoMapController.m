//
//  RestoMapController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMapController.h"
#import "RestoLocation.h"
#import "RestoStore.h"
#import "UINavigationController+ReplaceController.h"

@interface RestoMapController () <UISearchDisplayDelegate, UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchController;

@property (nonatomic, strong) NSArray *mapItems;
@property (nonatomic, strong) NSArray *filteredMapItems;
@property (nonatomic, strong) NSMutableDictionary *distances;

@property (nonatomic, assign) BOOL endingSearch;

@end

@implementation RestoMapController

#pragma mark Setting up the view & viewcontroller

- (id)init
{
    if (self = [super init]) {
        // Register for updates
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(loadMapItems)
                       name:RestoStoreDidUpdateInfoNotification object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    // Search field
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect searchBarFrame = CGRectMake(0, 0, bounds.size.width, 44);
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    searchBar.placeholder = @"Zoek een resto";
    [self.view addSubview:searchBar];

    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                              contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;

    // Offset map frame a little bit
    CGRect mapFrame = self.mapView.frame;
    mapFrame.origin.y = 44;
    self.mapView.frame = mapFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Resto Map";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Resto Kaart");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mapLocationUpdated
{
    if (self.searchController.isActive) {
        [self calculateDistances];
        [[[self searchController] searchResultsTableView] reloadData];
    }
}

#pragma mark - Data

- (void)loadMapItems
{
    [self.mapView removeAnnotations:self.mapItems];
    self.mapItems = [RestoStore sharedStore].locations;
    [self.mapView addAnnotations:self.mapItems];

    [self filterMapItems];
}

- (void)calculateDistances
{
    CLLocation *user = self.mapView.userLocation.location;
    NSMutableDictionary *distances = [NSMutableDictionary dictionaryWithCapacity:self.mapItems.count];
    for (RestoLocation *resto in self.mapItems) {
        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:resto.coordinate.latitude
                                                           longitude:resto.coordinate.longitude];
        CLLocationDistance distance = [user distanceFromLocation:coordinate];
        distances[resto.title] = @(distance);
    }
    self.distances = distances;

    [self reorderMapItems];
}

- (void)filterMapItems
{
    NSString *searchString = self.searchController.searchBar.text;
    if (searchString.length == 0) {
        self.filteredMapItems = self.mapItems;
    }
    else {
        NSMutableArray *filteredItems = [[NSMutableArray alloc] init];
        for (RestoLocation *resto in self.mapItems) {
            NSRange r = [resto.title rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if (r.location != NSNotFound) {
                [filteredItems addObject:resto];
            }
        }
        self.filteredMapItems = filteredItems;
    }

    [self reorderMapItems];
}

- (void)reorderMapItems
{
    self.filteredMapItems = [self.filteredMapItems sortedArrayUsingComparator:^(id a, id b) {
        NSNumber *distA = self.distances[[a title]];
        NSNumber *distB = self.distances[[b title]];
        return [distA compare:distB];
    }];
}

#pragma mark - MapView delegate

- (void)resetMapViewRect
{
    // Hardcoded rectangle for the central resto's, so the default map is a nice overview
    MKMapRect defaultRect = MKMapRectMake(13.6974e+7, 8.9796e+7, 30e3, 45e3);
    [self.mapView setVisibleMapRect:defaultRect animated:NO];
}

#pragma mark - SearchController delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.endingSearch = NO;

    // Just by accessing the property here, the searchResultsTableView will
    // be initialized with the correct frame. Crazy shit.
    [controller searchResultsTableView];

    // After this method the searchcontroller will start its animation, which we
    // want in on so we execute our hook in the next run loop.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _showSearchResults:controller.searchResultsTableView animated:YES];
        controller.searchResultsTableView.contentOffset = CGPointZero;
    });

    [self calculateDistances];
    [self filterMapItems];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.endingSearch = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    if (!self.endingSearch) {
        [self _showSearchResults:controller.searchResultsTableView animated:NO];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterMapItems];
    return YES;
}

// Hacky method to show the search results tableview immediately
- (void)_showSearchResults:(UITableView *)tableView animated:(BOOL)animated
{
    if (tableView.superview) {
        // iOS7 approach: show tableview, hide overlay-view
        tableView.hidden = NO;
        [[tableView.superview.subviews lastObject] setHidden:YES];
    }
    else {
        [tableView.layer removeAllAnimations];
        [self.view addSubview:tableView];
    }

    if (animated) {
        // Smooth appearance
        tableView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            tableView.alpha = 1;
        }];
    }
}

#pragma mark - SearchController tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredMapItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RestoMapViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];

        cell.separatorInset = UIEdgeInsetsZero;
    }

    RestoLocation *resto = self.filteredMapItems[indexPath.row];
    cell.textLabel.text = resto.name;

    double distance = [self.distances[resto.name] doubleValue];
    if (distance == 0) {
        cell.detailTextLabel.text = @"";
    }
    else if (distance < 2000) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f m", distance];
    }
    else {
        distance /= 1000;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f km", distance];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Keep the search string
    NSString *search = self.searchDisplayController.searchBar.text;
    [self.searchDisplayController setActive:NO animated:YES];
    self.searchDisplayController.searchBar.text = search;

    // Highlight the selected item
    RestoLocation *selected = self.filteredMapItems[indexPath.row];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.012, 0.012);
    MKCoordinateRegion region = MKCoordinateRegionMake(selected.coordinate, span);
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:selected animated:YES];
}

@end
