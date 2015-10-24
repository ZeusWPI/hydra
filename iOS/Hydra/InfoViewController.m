//
//  InfoViewController.m
//  Hydra
//
//  Created by Yasser Deceukelier on 19/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

@import SafariServices;

#import "InfoViewController.h"
#import "WebViewController.h"

@interface InfoViewController ()

@property (nonatomic, strong) NSArray *content;
@property (nonatomic, strong) NSString *trackedViewName;

@end

@implementation InfoViewController

#pragma mark - Initializing + loading

- (id)init
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"info-content" ofType:@"plist"];
    self = [self initWithContent:[[NSArray alloc] initWithContentsOfFile:path]];

    self.title = @"Info";
    self.trackedViewName = self.title;

    return self;
}

- (id)initWithContent:(NSArray *)content
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.content = content;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [[self tableView] setBounces:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(self.trackedViewName);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.separatorInset = UIEdgeInsetsZero;
    }

    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = cell.contentView.backgroundColor;

    NSDictionary *item = (self.content)[indexPath.row];
    cell.textLabel.text = item[@"title"];
    
    UIImage *icon = [UIImage imageNamed:item[@"image"]];
    if(icon) {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = icon;
    }
    else {
        cell.imageView.image = nil;
    }
    
    // Show an icon, depending on the subview
    if (item[@"url-ios"] || item[@"url"]) {
        UIImage *linkImage = [UIImage imageNamed:@"external-link.png"];
        UIImage *highlightedLinkImage = [UIImage imageNamed:@"external-link-active.png"];
        UIImageView *linkAccessory = [[UIImageView alloc] initWithImage:linkImage
                                                       highlightedImage:highlightedLinkImage];
        linkAccessory.contentMode = UIViewContentModeScaleAspectFit;
        cell.accessoryView = linkAccessory;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = self.content[indexPath.row];

    // Choose a different action depending on what data is available
    if(item[@"subcontent"]){
        NSArray *subContent = item[@"subcontent"];

        InfoViewController *c = [[InfoViewController alloc] initWithContent:subContent];
        c.title = item[@"title"];
        c.trackedViewName = [NSString stringWithFormat:@"%@ > %@", self.trackedViewName, c.title];

        [self.navigationController pushViewController:c animated:YES];
    }
    else if(item[@"html"]) {
        WebViewController *c = [[WebViewController alloc] init];
        c.title = item[@"title"];
        c.trackedViewName = [NSString stringWithFormat:@"%@ > %@", self.trackedViewName, c.title];
        [c loadHtml:item[@"html"]];

        [self.navigationController pushViewController:c animated:YES];
    }
    else if(item[@"url-ios"] || item[@"url"]) {
        NSURL *url = nil;
        if (item[@"url-ios"]) url = [NSURL URLWithString:item[@"url-ios"]];
        else url = [NSURL URLWithString:item[@"url"]];
        if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9")) {
            SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:url];
            [self.navigationController presentViewController:svc animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        NSLog(@"Unknown action in %@", item);
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
