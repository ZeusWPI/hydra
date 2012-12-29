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
        [self configure];
        [self createView];
    }
    return self;
}

- (void)configure
{
    /*// Check for updates
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(legendUpdated:)
                   name:RestoStoreDidReceiveMenuNotification
                 object:nil];
    [self loadLegends];//*/
    // array
    // TODO: storage and json temporary like this without json
    RestoLegend *aanbevolen = [[RestoLegend alloc] init];
    aanbevolen.key = @"vet";
    aanbevolen.value = @"Aanbevolen menu: 0,50 euro korting reeds verrekend in de prijs (cfr. gezondheidsbeleid in de resto's.)";
    aanbevolen.style = @"bold";
    RestoLegend *sterretje = [[RestoLegend alloc] init];
    sterretje.key = @"*";
    sterretje.value = @"menu niet verkrijgbaar in resto Diergeneeskunde, Boudewijn en St. Jansvest";
    sterretje.style = @"";
    RestoLegend *haakje = [[RestoLegend alloc] init];
    haakje.key = @"#";
    haakje.value = @"menu niet verkrijgbaar in resto Boudewijn";
    haakje.style = @"";
    RestoLegend *frietjes = [[RestoLegend alloc] init];
    frietjes.key = @"";
    frietjes.value = @"Frietjes of kroketten: +0,20 euro bij menu";
    frietjes.style = @"";
    RestoLegend *snack = [[RestoLegend alloc] init];
    snack.key = @"";
    snack.value = @"In resto St. Jansvest, Diergeneeskunde en Boudewijn wordt dagelijks bijkomend een snackgerecht aangeboden.";
    snack.style = @"";
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:aanbevolen, sterretje, haakje, frietjes, snack, nil];
    self.legends = array;
    [self.tableView reloadData];
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
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableFrame.size.width, 35)];
    [view addSubview:tableView];
    self.tableView = tableView;
    
    CGRect titleFrame = CGRectMake(0, 10, tableFrame.size.width, 24);
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
    legendeButton.frame = CGRectMake(0, 0, 25, 25);
    legendeButton.layer.cornerRadius = 10;
    legendeButton.layer.masksToBounds = YES;
    //TODO create image for button 21	54	93
    legendeButton.backgroundColor = [UIColor colorWithRed:((float) 21 / 255.0f)  green:((float) 54 / 255.0f)  blue:((float) 93 / 255.0f)  alpha:0.6f];
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
    RestoLegend *legend = (self.legends)[indexPath.row];

    CGSize constraintSize = CGSizeMake(150.0f, MAXFLOAT);
    CGSize labelSize = [legend.value sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return (labelSize.height+20);
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
