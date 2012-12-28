//
//  RestoLegendView.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 28/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RestoLegendView.h"
#import "RestoLegend.h"
#import "RestoStore.h"

@interface RestoLegendView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *legends;

@property (nonatomic, unsafe_unretained) UITableView *tableView;
@property (nonatomic, unsafe_unretained) UIActivityIndicatorView *spinner;


@end
@implementation RestoLegendView
#define kBorderMargin 20

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self configure];
        [self createView];
    }
    return self;
}

- (void)configure
{
    // Check for updates
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(legendUpdated:)
                   name:RestoStoreDidReceiveMenuNotification
                 object:nil];
    [self loadLegends];
}

- (void)createView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //backgroundcolor
    self.backgroundColor = [UIColor clearColor];
    
    CGRect viewFrame = CGRectMake(kBorderMargin, kBorderMargin, self.frame.size.width - 2 * kBorderMargin, self.frame.size.height - 2 * kBorderMargin);
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    // background
    UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:@"header-bg.png"] drawInRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    view.backgroundColor = [UIColor colorWithPatternImage:image];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    [self addSubview:view];
    
    //tableview
    CGRect tableFrame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.allowsSelection = NO;
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableFrame.size.width, 25)];
    [view addSubview:tableView];
    self.tableView = tableView;
    
    CGRect titleFrame = CGRectMake(0, 10, tableFrame.size.width, 20);
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:titleFrame];
    headerTitle.text = @"Legende";
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.font = [UIFont boldSystemFontOfSize:20];
    headerTitle.textColor = [UIColor whiteColor];
    headerTitle.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    [self.tableView.tableHeaderView addSubview:headerTitle];
    
    
    // close button
    UIButton *legendeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    legendeButton.frame = CGRectMake(5, 5, 20, 20);
    legendeButton.layer.cornerRadius = 10;
    legendeButton.layer.masksToBounds = YES;
    //TODO create image for button
    legendeButton.backgroundColor = [UIColor blackColor];
    [legendeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:legendeButton];
    
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.legends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *textLabel;
    RestoLegend *legend = (self.legends)[indexPath.row];
    static NSString *cellIdentifier = @"RestoLegendViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
        
    }
    else {
        
    }
    
    cell.textLabel.text = legend.value;
    return cell;
}


#pragma Selector methods

- (IBAction)closeView
{
    DLog(@"Close view ");
    [self removeFromSuperview];
}

- (void)loadLegends
{
    self.legends = [[RestoStore sharedStore] allLegends];
}

- (void)menuUpdated:(NSNotification *)notification
{
    DLog(@"Legend updated!");
    [self loadLegends];
    [self.tableView reloadData];
}

@end
