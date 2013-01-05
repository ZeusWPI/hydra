//
//  RestoInfoView.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoInfoView.h"
#import "RestoLegendItem.h"
#import "RestoMapViewController.h"
#import "RestoStore.h"
#import "AppDelegate.h"

@interface RestoInfoView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, unsafe_unretained) UITableView *tableView;
@property (nonatomic, unsafe_unretained) UIActivityIndicatorView *spinner;

@end
@implementation RestoInfoView

#pragma mark - Properties and init

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)createView
{
    // background
    UIImage *background = [UIImage imageNamed:@"header-bg.png"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundView.image = background;
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    backgroundView.autoresizingMask = self.autoresizingMask;
    [self addSubview:backgroundView];

    // logo
    UIImage *logo = [UIImage imageNamed:@"resto-logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];
    [imageView setFrame:CGRectMake(90, 20, 100, 100)];
    [self addSubview:imageView];

    // resto info
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 133, 240, 80)];
    infoLabel.text = @"De resto's van de UGent zijn elke weekdag open van 11u15 tot 14u. 's Avonds kan je ook terecht in resto De Brug van 17u30 tot 21u.";
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.font = [UIFont systemFontOfSize:15];
    infoLabel.textAlignment = UITextAlignmentCenter;
    infoLabel.numberOfLines = 4;
    [self addSubview:infoLabel];
    
    //tableview
    CGRect tableFrame = CGRectMake(20, 220, self.frame.size.width-40, self.frame.size.height-310);
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.allowsSelection = NO;
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableFrame.size.width, 15)];
    [self addSubview:tableView];
    self.tableView = tableView;
    
    CGRect titleFrame = CGRectMake(0, 0, tableFrame.size.width, 20);
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:titleFrame];
    headerTitle.text = @"Legende";
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.font = [UIFont boldSystemFontOfSize:18];
    headerTitle.textColor = [UIColor whiteColor];
    headerTitle.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    [self.tableView.tableHeaderView addSubview:headerTitle];
}

- (void)setLegend:(NSArray *)legend
{
    _legend = legend;
    [self.tableView reloadData];
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.legend.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestoLegendItem *legend = self.legend[indexPath.row];
    static NSString *cellIdentifier = @"RestoLegendViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
        //set cell textLabel, contains value
        [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:13]];
        [cell.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;
        //set cell detailTextLabel, to contain key, if key
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    }
    else {
        
    }
    // textLabel
    CGSize constraintSize = CGSizeMake(150.0f, MAXFLOAT);
    CGSize labelSize = [legend.value sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    [cell.detailTextLabel setFrame:CGRectMake(60, 0, labelSize.width, labelSize.height)];
    cell.detailTextLabel.text = legend.value;
    
    
    // detailTextLabel
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    // look to styles
    if (legend.key != nil) {
        cell.textLabel.text = legend.key;
    }
    if (legend.style != nil){
        if ([legend.style rangeOfString:@"bold"].location != NSNotFound) {
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15]];
        }
        if ([legend.style rangeOfString:@"underline"].location != NSNotFound) {
            //TODO set underlined
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestoLegendItem *legend = self.legend[indexPath.row];
    
    CGSize constraintSize = CGSizeMake(150.0f, MAXFLOAT);
    CGSize labelSize = [legend.value sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return (labelSize.height+20);
}

@end
