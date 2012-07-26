//
//  InfoViewController.m
//  Hydra
//
//  Created by Yasser Deceukelier on 19/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "InfoViewController.h"
#import "WebViewController.h"

@implementation InfoViewController
{
    NSArray *content;
}

#pragma mark - Initializing + loading

- (id)init
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"info-content" ofType:@"plist"];
    self = [self initWithContent:[[NSArray alloc] initWithContentsOfFile:path]];
    if (self) {
        [self setTitle:@"Info"];
    }
    return self;
}

- initWithContent:(NSArray *)newContent
{
    UITableViewStyle style = UITableViewStylePlain; //automaticly use UITableViewStyleGrouped when [newContent count] < 4 ?
    self = [super initWithStyle:style];
    if (self) {
        content = newContent;
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
    return [content count];
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

    NSDictionary *item = [content objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"title"];
    
    UIImage *icon = [UIImage imageNamed:[item objectForKey:@"image"]];
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
    
    // Show an arrow if there's a subview
    if (![item objectForKey:@"url"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [content objectAtIndex:indexPath.row];

    // Choose a different action depending on what data is available
    if([item objectForKey:@"subcontent"]){
        NSArray *subContent = [item objectForKey:@"subcontent"];
        InfoViewController *c = [[InfoViewController alloc] initWithContent:subContent];
        [c setTitle:[item objectForKey:@"title"]];
        [[self navigationController] pushViewController:c animated:YES];
    }
    else if([item objectForKey:@"html"]) {
        WebViewController *c = [[WebViewController alloc] init];
        [c loadHtml:[item objectForKey:@"html"]];
        [c setTitle:[item objectForKey:@"title"]];
        [[self navigationController] pushViewController:c animated:YES];
    }
    else if([item objectForKey:@"url"]) {
        NSURL *url = [NSURL URLWithString:[item objectForKey:@"url"]];
        [[UIApplication sharedApplication] openURL:url];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        DLog(@"Unknown action in %@", item);
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
