//
//  MAUpgradeAlertViewController.m
//  Gym Log
//
//  Created by Wade Spires on 6/16/14.
//
//

#import "MAUpgradeAlertViewController.h"

#import "MAAccessoryView.h"
#import "MAAppDelegate.h"
#import "MAAppearance.h"
#import "MADeviceUtil.h"
#import "MAFilePaths.h"
#import "MAUIUtil.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

#import "MATipIAPHelper.h"

DECL_TABLE_IDX(NUM_SECTIONS, 1);

DECL_TABLE_IDX(IAP_LIST_SECTION, 0);

@interface MAUpgradeAlertViewController ()
@property (strong, nonatomic) NSArray *iapList;

// In-App Purchase.
@property (strong, nonatomic) NSMutableArray *products;
@end

@implementation MAUpgradeAlertViewController
@synthesize titleLabel = _titleLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize tableView = _tableView;

@synthesize iapList = _iapList;
@synthesize products = _products;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //NSAttributedString *title = [self formatTitle:Localize(@"Upgrade Required") description:Localize(@"Upgrade to unlock all features:")];
        //_titleLabel.attributedText = title;
        //_titleLabel.text = nil;
        //_titleLabel.numberOfLines = 0;
    }
    return self;
}

/*
- (NSAttributedString *)formatTitle:(NSString *)title description:(NSString *)description
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    
    [attrStr appendAttributedString:[self formatTitle:title]];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [attrStr appendAttributedString:[self formatDescription:description]];
    
    return attrStr;
}

- (NSAttributedString *)formatTitleLabel:(NSString *)title
{
    UIFont *font = nil;
    if (ABOVE_IOS7)
    {
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
    else
    {
        font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    }
    NSDictionary *textDict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title attributes:textDict];
    
    return attrStr;
}

- (NSAttributedString *)formatDescription:(NSString *)description
{
    UIFont *font = nil;
    if (ABOVE_IOS7)
    {
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }
    else
    {
        font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    }
    NSDictionary *textDict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:description attributes:textDict];
    
    [attrStr addAttribute:NSForegroundColorAttributeName value:[MAAppearance detailLabelTextColor] range:NSMakeRange(0, description.length)];
    
    return attrStr;
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUIUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];
    
    // Make the table background clear, so that this view's background shows.
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    [MAAppearance setSeparatorStyleForTable:self.tableView];
    
    [self registerNibs];
    
    [self loadProducts];
}

// Register custom cells with the table view.
- (void)registerNibs
{
    //UINib *nib = nil;
    
    //nib = [UINib nibWithNibName:@"MAWeightGoalTextFieldCell" bundle:nil];
    //[self.tableView registerNib:nib forCellReuseIdentifier:MAWeightGoalTextFieldCellIdentifier];
}

- (void)loadProducts
{
    // Try to load the products again in case did not have network access when the app first started.
    self.products = [[MATipIAPHelper sharedInstance] products];
    if ( ! self.products)
    {
        [[MATipIAPHelper sharedInstance] loadProducts:^(BOOL success, NSArray *products)
         {
             if (!success)
             {
                 return;
             }
             
             self.products = [products copy];
             
             //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:BUY_ROW inSection:BUY_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUIUtil updateNavItem:self.navigationItem withTitle:self.title];
    
    self.iapList = [MATipIAPHelper iapList];
    
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == IAP_LIST_SECTION)
    {
        //return Localize(@"Features");
    }
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == IAP_LIST_SECTION)
    {
        return self.iapList.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == IAP_LIST_SECTION)
    {
        return [self tableView:tableView iapItemCellForRowAtIndexPath:indexPath];
    }
    
    DLog(@"Error: Not returning a cell!");
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView iapItemCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MAIapItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    
    NSDictionary *feature = [self.iapList objectAtIndex:indexPath.row];
    NSString *title = [feature objectForKey:Feature_Title_Key];
    //NSString *description = [feature objectForKey:Feature_Description_Key];
    UIImage *image = [feature objectForKey:Feature_Image_Key];
    
    NSAttributedString *attrStr = [self formatTitle:title];
    cell.textLabel.attributedText = attrStr;
    cell.textLabel.numberOfLines = 0;
    
    if ((NSNull *)image != [NSNull null])
    {
        cell.imageView.image = image;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    return cell;
}

- (NSAttributedString *)formatTitle:(NSString *)title
{
    UIFont *font = nil;
    if (ABOVE_IOS7)
    {
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    else
    {
        font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    }
    NSDictionary *textDict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title attributes:textDict];
    
    return attrStr;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [MAUIUtil rowHeightForTableView:tableView];
    if (indexPath.section == IAP_LIST_SECTION)
    {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        height = [MAAppearance heightForRowInTableView:tableView withAttributedTextInView:cell.textLabel];
    }
    
    return height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == IAP_LIST_SECTION)
    {
        // Do nothing.
    }
}

@end
