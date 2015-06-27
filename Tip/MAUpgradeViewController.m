//
//  MAUpgradeViewController.m
//  Gym Log
//
//  Created by Wade Spires on 4/23/14.
//
//

#import "MAUpgradeViewController.h"

#import "MAAccessoryView.h"
#import "MAAppDelegate.h"
#import "MAAppearance.h"
#import "MADeviceUtil.h"
#import "MAFilePaths.h"
#import "MATipIAPHelper.h"
#import "MAUIUtil.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

DECL_TABLE_IDX(NUM_SECTIONS, 2);

DECL_TABLE_IDX(IAP_LIST_SECTION, 0);

DECL_TABLE_IDX(BUY_SECTION, 1);
DECL_TABLE_IDX(BUY_ROW, 0);
DECL_TABLE_IDX(BUY_SECTION_ROWS, 1);

@interface MAUpgradeViewController ()
@property (strong, nonatomic) NSArray *iapList;

// In-App Purchase.
@property (strong, nonatomic) NSMutableArray *products;
@end

@implementation MAUpgradeViewController
@synthesize tableView = _tableView;

@synthesize iapList = _iapList;
@synthesize products = _products;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    UIBarButtonItem *restoreButton = [[UIBarButtonItem alloc]
                                   initWithTitle:Localize(@"Restore")
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(restoreButtonTapped:)];
    self.navigationItem.rightBarButtonItem = restoreButton;

    [self loadProducts];
}

// Register custom cells with the table view.
- (void)registerNibs
{
    //UINib *nib = nil;
    
    //nib = [UINib nibWithNibName:@"MAWeightGoalTextFieldCell" bundle:nil];
    //[self.tableView registerNib:nib forCellReuseIdentifier:MAWeightGoalTextFieldCellIdentifier];
}

- (void)restoreButtonTapped:(id)sender
{
    NSLog(@"Restoring purchases...");
    [[MATipIAPHelper sharedInstance] restoreCompletedTransactions];
    [self.tableView reloadData];
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
             
             [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:BUY_ROW inSection:BUY_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
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

    // Get notified when upgrade is purchased or restored.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(receivedProductPurchaseNotification) name:IAPHelperProductPurchasedNotification object:nil];

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
    if (section == BUY_SECTION)
    {
        //return Localize(@"Purchase");
    }
    else if (section == IAP_LIST_SECTION)
    {
        return Localize(@"Features");
    }
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == BUY_SECTION)
    {
        return BUY_SECTION_ROWS;
    }
    else if (section == IAP_LIST_SECTION)
    {
        return self.iapList.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BUY_SECTION)
    {
        if (indexPath.row == BUY_ROW)
        {
            return [self tableView:tableView buyCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == IAP_LIST_SECTION)
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
    NSString *description = [feature objectForKey:Feature_Description_Key];
    UIImage *image = [feature objectForKey:Feature_Image_Key];
    
    NSAttributedString *attrStr = [self formatTitle:title description:description];
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

- (NSAttributedString *)formatTitle:(NSString *)title description:(NSString *)description
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];

    [attrStr appendAttributedString:[self formatTitle:title]];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [attrStr appendAttributedString:[self formatDescription:description]];

    return attrStr;
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

- (UITableViewCell *)tableView:(UITableView *)tableView buyCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MABuyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];

    cell.textLabel.textColor = [MAAppearance foregroundColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;

    UIImage *image = [MAFilePaths upgradeImage];
    NSInteger tag = [MAUIUtil toTag:indexPath];
    [MAUIUtil setImage:image forCell:cell withTag:tag];

    static dispatch_once_t once;
    static NSNumberFormatter *priceFormatter = nil;
    dispatch_once(&once, ^{
        priceFormatter = [[NSNumberFormatter alloc] init];
        [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    });

    
    /*
    {   // TODO: for testing, remove/comment out.
        cell.textLabel.text = Localize(@"Upgrade");
        cell.detailTextLabel.text = @"$4.99";
        return cell;
    }
     */

    
    BOOL const productPurchased = [MATipIAPHelper ProProductPurchased];
    if (!productPurchased && ( ! self.products || indexPath.row >= self.products.count))
    {
        cell.textLabel.text = Localize(@"Loading...");
        cell.detailTextLabel.text = @"";;

        UIActivityIndicatorView *anActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = anActivityIndicator;
        [anActivityIndicator startAnimating];

        return cell;
    }

    if (productPurchased)
    {
        cell.textLabel.text = Localize(@"Purchased");
        cell.detailTextLabel.text = @"";;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.textLabel.text = Localize(@"Upgrade");

        SKProduct *product = self.products[PRO_PRODUCT_IDX];
        [priceFormatter setLocale:product.priceLocale];
        NSString *price = [priceFormatter stringFromNumber:product.price];
        cell.detailTextLabel.text = price;
    }
    cell.accessoryView = nil;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [MAUIUtil rowHeightForTableView:tableView];
    if (indexPath.section == BUY_SECTION)
    {
    }
    else if (indexPath.section == IAP_LIST_SECTION)
    {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        height = [MAAppearance heightForRowInTableView:tableView withAttributedTextInView:cell.textLabel];
    }
    
    return height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BUY_SECTION)
    {
        if (indexPath.row == BUY_ROW)
        {
            [self selectBuyRow:indexPath];
        }
    }
    else if (indexPath.section == IAP_LIST_SECTION)
    {
        // Do nothing.
    }
}

- (void)selectBuyRow:(NSIndexPath *)indexPath
{
    if ( ! self.products || indexPath.row >= self.products.count)
    {
        return;
    }

    SKProduct *product = self.products[PRO_PRODUCT_IDX];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[MATipIAPHelper sharedInstance] buyProduct:product];
}

- (void)receivedProductPurchaseNotification
{
    // Only thing to do is to remove this tab since the product is internally stored as having been purchased for when the user wants to access the relevant feature/setting elsewhere.
    [self removeUpgradeTab];
}

- (void)removeUpgradeTab
{
    static NSUInteger const settingsTabIdx = 2;
    static NSUInteger const upgradeTabIdx = 3;

    [self.tabBarController setSelectedIndex:settingsTabIdx];

    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
    if (upgradeTabIdx >= viewControllers.count)
    {
        NSLog(@"Upgrade tab index %d >= tab view controllers %d", (int)upgradeTabIdx, (int)viewControllers.count);
        return;
    }
	[viewControllers removeObjectAtIndex:upgradeTabIdx];
	[self.tabBarController setViewControllers:viewControllers];
}

@end
