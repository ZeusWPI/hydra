//
//  InfoViewController.m
//  Hydra
//
//  Created by Yasser Deceukelier on 19/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "InfoViewController.h"
#import "WebViewController.h"

@interface InfoViewController ()

@property (nonatomic, strong) NSArray *content;

@end

@implementation InfoViewController

#pragma mark - Initializing + loading

- (id)init
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"info-content" ofType:@"plist"];
    self = [self initWithContent:[[NSArray alloc] initWithContentsOfFile:path]];
    [self setTitle:@"Info"];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = cell.contentView.backgroundColor;

    NSDictionary *item = (self.content)[indexPath.row];
    cell.textLabel.text = item[@"title"];
    
    UIImage *icon = [UIImage imageNamed:item[@"image"]];
    if(icon) {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = icon;

        // Ugly fix to add more padding to the image
        cell.indentationLevel = 1;
        cell.textLabel.text = [@" " stringByAppendingString:cell.textLabel.text];
    }
    else {
        cell.imageView.image = nil;
    }
    
    // Show an icon, depending on the subview
    if (item[@"url"]) {
        UIImageView *linkAccossory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"external-link.png"]
                                                       highlightedImage:[UIImage imageNamed:@"external-link-active.png"]];
        linkAccossory.contentMode = UIViewContentModeScaleAspectFit;
        cell.accessoryView = linkAccossory;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = (self.content)[indexPath.row];

    // Choose a different action depending on what data is available
    if(item[@"subcontent"]){
        NSArray *subContent = item[@"subcontent"];
        InfoViewController *c = [[InfoViewController alloc] initWithContent:subContent];
        [c setTitle:item[@"title"]];
        [[self navigationController] pushViewController:c animated:YES];
    }
    else if(item[@"html"]) {
        WebViewController *c = [[WebViewController alloc] init];
        [c loadHtml:item[@"html"]];
        [c setTitle:item[@"title"]];
        [[self navigationController] pushViewController:c animated:YES];
    }
    else if(item[@"url"]) {
        NSURL *url = [NSURL URLWithString:item[@"url"]];
        [[UIApplication sharedApplication] openURL:url];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        DLog(@"Unknown action in %@", item);
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end