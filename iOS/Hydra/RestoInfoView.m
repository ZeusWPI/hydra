//
//  RestoInfoView.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoInfoView.h"
#import "RestoLegend.h"

@interface RestoInfoView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, unsafe_unretained) UITableView *tableView;
@property (nonatomic, unsafe_unretained) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSMutableArray *legends;

@end

@implementation RestoInfoView

#pragma mark - Constants

#define kCellKeyWidth 40
#define kCellLabelTag 33

#pragma mark - Properties and init

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.legends = [[NSMutableArray alloc] initWithCapacity:0];
        [self createView];
    }
    return self;
}

- (void)configureWithArray:(NSMutableArray*)array
{
    if (![self.legends isEqual:array]){
        self.legends = array;
        [self reloadDate];
    }
}

- (void)configure
{
    // array
    // TODO: storage and json temporary like this without json
    RestoLegend *aanbevolen = [[RestoLegend alloc] init];
    aanbevolen.key = @"vet";
    aanbevolen.value = @"Aanbevolen menu: 0,50 euro korting reeds verrekend in de prijs (cfr. gezondheidsbeleid in de resto's.)";
    aanbevolen.options = @"bold";
    RestoLegend *sterretje = [[RestoLegend alloc] init];
    sterretje.key = @"*";
    sterretje.value = @"menu niet verkrijgbaar in resto Diergeneeskunde, Boudewijn en St. Jansvest";
    sterretje.options = @"";
    RestoLegend *haakje = [[RestoLegend alloc] init];
    haakje.key = @"#";
    haakje.value = @"menu niet verkrijgbaar in resto Boudewijn";
    haakje.options = @"";
    RestoLegend *frietjes = [[RestoLegend alloc] init];
    frietjes.key = @"";
    frietjes.value = @"Frietjes of kroketten: +0,20 euro bij menu";
    frietjes.options = @"";
    RestoLegend *snack = [[RestoLegend alloc] init];
    snack.key = @"";
    snack.value = @"In resto St. Jansvest, Diergeneeskunde en Boudewijn wordt dagelijks bijkomend een snackgerecht aangeboden.";
    snack.options = @"";

    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:aanbevolen, sterretje, haakje, frietjes, snack, nil];
    self.legends = array;
    [self reloadDate];
}

- (void)createView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // background
    UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:@"header-bg.png"] drawInRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.backgroundColor = [UIColor colorWithPatternImage:image];

    // logo
    UIImage *restoLogo = [UIImage imageNamed:@"resto-logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:restoLogo];
    [imageView setFrame:CGRectMake(90, 20, 100, 100)];

    [self addSubview:imageView];
    [self sendSubviewToBack:imageView];

    // resto info label
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 133, 240, 80)];
    infoLabel.text = @"De resto's van de UGent zijn elke weekdag open van 11u15 tot 14u. 's Avonds kan je ook terecht in resto De Brug van 17u30 tot 21u.";
    infoLabel.numberOfLines = 4;
    [self createLabel:infoLabel];
    [self addSubview:infoLabel];

    // resto legende label
    UILabel *legendeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,233,67,21)];
    legendeLabel.text = @"Legende";
    [self createLabel:legendeLabel];
    [legendeLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [legendeLabel sizeToFit];
    [self addSubview:legendeLabel];

    // tableview
    CGRect tableFrame = CGRectMake(0,250, self.bounds.size.width,self.bounds.size.height-250);
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    //tableView.rowHeight = 18;
    //tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.allowsSelection = NO;
    [self addSubview:tableView];
    self.tableView = tableView;

    //spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.center;
    [self addSubview:spinner];
    self.spinner = spinner;
}

- (void)reloadDate
{
    [self.tableView reloadData];
}
# pragma Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.legends count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    RestoLegend *legend;

    legend = (RestoLegend*)(self.legends)[indexPath.row];
    
    static NSString *cellIdentifier = @"RestoLegendViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self createLabelForInCell:cell.textLabel];
    [self createLabelForInCell:cell.detailTextLabel];


    legend = (RestoLegend*)(self.legends)[indexPath.row];

    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@\t%@",[legend key], [legend value]];
    if ([[legend options] isEqualToString:@"bold"]){
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:10]];
    }
    return cell;

}

- (void) createLabel:(UILabel* )label
{

    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label sizeToFit];
}

- (void) createLabelForInCell:(UILabel* )label
{

    [label setFont:[UIFont systemFontOfSize:10]];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label sizeToFit];
}
@end
