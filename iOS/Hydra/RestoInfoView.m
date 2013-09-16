//
//  RestoInfoView.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoInfoView.h"
#import "RestoLegendItem.h"
#import "RestoMapController.h"
#import "RestoStore.h"
#import "AppDelegate.h"

#define kCellKeyLabel 101
#define kCellValueLabel 102

@interface RestoInfoView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, unsafe_unretained) UITableView *tableView;

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
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:backgroundView];

    // Header view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 208)];

    // logo
    UIImage *logo = [UIImage imageNamed:@"resto-logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];
    [imageView setFrame:CGRectMake(90, 0, 100, 100)];
    [headerView addSubview:imageView];

    // resto info
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(imageView.frame),
                                                                   self.frame.size.width - 60, 80)];
    infoLabel.text = @"De resto's van de UGent zijn elke weekdag open van 11u15 tot 14u. 's Avonds kan je ook terecht in resto De Brug van 17u30 tot 21u.";
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.font = [UIFont systemFontOfSize:14];
    infoLabel.textAlignment = UITextAlignmentCenter;
    infoLabel.numberOfLines = 4;
    [headerView addSubview:infoLabel];

    // title
    CGRect titleFrame = CGRectMake(0, CGRectGetMaxY(infoLabel.frame) + 5, self.frame.size.width, 20);
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:titleFrame];
    headerTitle.text = @"Legende";
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.font = [UIFont boldSystemFontOfSize:13];
    headerTitle.textColor = [UIColor whiteColor];
    headerTitle.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerTitle];

    // Tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds
                                                          style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.allowsSelection = NO;
    tableView.tableHeaderView = headerView;
    tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    [self addSubview:tableView];
    self.tableView = tableView;
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

    UILabel *keyLabel, *valueLabel;

	static NSString *cellIdentifier = @"RestoLegendViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        cell.backgroundColor = [UIColor clearColor];

        keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 19)];
        keyLabel.tag = kCellKeyLabel;
        keyLabel.font = [UIFont boldSystemFontOfSize:13];
        keyLabel.backgroundColor = [UIColor clearColor];
        keyLabel.textColor = [UIColor whiteColor];
        keyLabel.textAlignment = UITextAlignmentRight;
        [cell.contentView addSubview:keyLabel];

        CGFloat valueX = CGRectGetMaxX(keyLabel.frame) + 10;
        CGRect valueFrame = CGRectMake(valueX, 0, cell.frame.size.width - valueX - 20,
                                       cell.frame.size.height);
        valueLabel = [[UILabel alloc] initWithFrame:valueFrame];
        valueLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight
                                    | UIViewAutoresizingFlexibleWidth;
        valueLabel.numberOfLines = 0;
        valueLabel.lineBreakMode = UILineBreakModeWordWrap;
        valueLabel.tag = kCellValueLabel;
        valueLabel.font = [UIFont systemFontOfSize:13];
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:valueLabel];
    }
    else {
        keyLabel = (UILabel *)[cell viewWithTag:kCellKeyLabel];
        valueLabel = (UILabel *)[cell viewWithTag:kCellValueLabel];
    }

    if ([legend.style isEqual:@"bold"]) {
        keyLabel.font = [UIFont boldSystemFontOfSize:13];
    }
    else {
        keyLabel.font = [UIFont systemFontOfSize:13];
    }

    valueLabel.text = legend.value;
    keyLabel.text = legend.key;

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestoLegendItem *legend = self.legend[indexPath.row];
    
    CGSize constraintSize = CGSizeMake(200, CGFLOAT_MAX);
    CGSize labelSize = [legend.value sizeWithFont:[UIFont systemFontOfSize:13]
                                constrainedToSize:constraintSize
                                    lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 5;
}

@end
