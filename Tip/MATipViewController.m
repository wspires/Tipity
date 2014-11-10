//
//  MATipViewController.m
//  Gym Log
//
//  Created by Wade Spires on 8/20/14.
//
//

#import "MATipViewController.h"

#import "MAAppDelegate.h"
#import "MAAppearance.h"
#import "MABill.h"
#import "MAFilePaths.h"
#import "MARatingTableViewCell.h"
#import "MATextFieldCell.h"
#import "MAUserUtil.h"
#import "MAUtil.h"
#import "MATipIAPHelper.h"

#import <iAd/iAd.h>

DECL_TABLE_IDX(DISABLED_SECTION, 9999);
DECL_TABLE_IDX(DISABLED_ROW, 9999);

DECL_TABLE_IDX_VAR(NUM_SECTIONS, 3);

DECL_TABLE_IDX_VAR(BILL_SECTION, 0);
DECL_TABLE_IDX(BILL_ROW, 0);
DECL_TABLE_IDX(BILL_SECTION_ROWS, 1);

DECL_TABLE_IDX_VAR(TIP_SECTION, 1);
DECL_TABLE_IDX_VAR(TIP_RATING_ROW, 0);
DECL_TABLE_IDX_VAR(TIP_PERCENT_ROW, 1);
DECL_TABLE_IDX_VAR(TIP_ROW, 2);
DECL_TABLE_IDX_VAR(TIP_SECTION_ROWS, 3);

DECL_TABLE_IDX_VAR(TOTAL_SECTION, 2);
DECL_TABLE_IDX(TOTAL_ROW, 0);
DECL_TABLE_IDX(TOTAL_SECTION_ROWS, 1);

DECL_TABLE_IDX_VAR(SPLIT_SECTION, 3);
DECL_TABLE_IDX(SPLIT_COUNT_ROW, 0);
DECL_TABLE_IDX(SPLIT_TIP_ROW, 1);
DECL_TABLE_IDX(SPLIT_TOTAL_ROW, 2);
DECL_TABLE_IDX(SPLIT_SECTION_ROWS, 3);

DECL_TABLE_IDX_VAR(TAX_SECTION, 4);
DECL_TABLE_IDX(TAX_PERCENT_ROW, 0);
DECL_TABLE_IDX(TAX_ROW, 1);
DECL_TABLE_IDX(BILL_BEFORE_TAX_ROW, DISABLED_ROW);
DECL_TABLE_IDX(TAX_SECTION_ROWS, 2);

static NSString *AppGroup = @"group.com.mindsaspire.Tip";

static NSString *MATextFieldCellIdentifier = @"MATextFieldCellIdentifier";
static NSString *MARatingTableViewCellIdentifier = @"MARatingTableViewCellIdentifier";

@interface MATipViewController () <MABillDelegate, MARatingDelegate, UITextFieldDelegate, UIActionSheetDelegate, ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MABill *bill;
@property (strong, nonatomic) NSArray *textFieldIndexPaths;
@property (strong, nonatomic) NSDictionary *indexPathToBillKeyDict;
@property (strong, nonatomic) NSIndexPath *activeIndexPath;
@property (strong, nonatomic) UITextField *activeTextField;

@property (strong, nonatomic) UIToolbar *keyboardAccessoryView;
@property (strong, nonatomic) UIBarButtonItem *backBarButton;
@property (strong, nonatomic) UIBarButtonItem *forwardBarButton;
@property (strong, nonatomic) UIBarButtonItem *doneBarButton;
@property (strong, nonatomic) UIBarButtonItem *update1BarButton;
@property (strong, nonatomic) UIBarButtonItem *update2BarButton;

@property (strong, nonatomic) ADBannerView *adBanner;
@property (weak, nonatomic) NSLayoutConstraint *adBannerBottomSizeConstraint;
@property (weak, nonatomic) NSLayoutConstraint *adBannerHeightConstraint;
@property (assign, nonatomic) BOOL bannerIsVisible;
@end

@implementation MATipViewController
@synthesize tableView = _tableView;
@synthesize bill = _bill;
@synthesize textFieldIndexPaths = _textFieldIndexPaths;
@synthesize indexPathToBillKeyDict = _indexPathToBillKeyDict;
@synthesize activeIndexPath = _activeIndexPath;
@synthesize activeTextField = _activeTextField;

@synthesize keyboardAccessoryView = _keyboardAccessoryView;
@synthesize backBarButton = _backBarButton;
@synthesize forwardBarButton = _forwardBarButton;
@synthesize doneBarButton = _doneBarButton;
@synthesize update1BarButton = _update1BarButton;
@synthesize update2BarButton = _update2BarButton;

@synthesize adBanner = _adBanner;
@synthesize adBannerBottomSizeConstraint = _adBannerBottomSizeConstraint;
@synthesize adBannerHeightConstraint = _adBannerHeightConstraint;
@synthesize bannerIsVisible = _bannerIsVisible;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Row height. Having some issues with automatic sizes. Getting warning:
    // Warning once only: Detected a case where constraints ambiguously suggest a height of zero for a tableview cell's content view. We're considering the collapse unintentional and using standard height instead.
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    if (BELOW_IOS8)
    {
        self.tableView.rowHeight = 44;
    }
    
    [self registerNibs];

    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];
    
    // Make the table background clear, so that this view's background shows.
    [MAAppearance clearBackgroundForTableView:self.tableView];

    [self loadBill];
    
    [self setupAdBanner];

//    [self hideUIToMakeLaunchImages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];

    [self hideAdBannerIfPurchased];
    
    // Need to add insets to the table view when the keyboard appears.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];

    if ( ! [[MAUserUtil sharedInstance] enableTax])
    {
        [self.bill clearTax];
    }

    MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
    if (myDelegate.todayViewBill)
    {
        self.bill.bill = myDelegate.todayViewBill.bill;
        self.bill.tipPercent = myDelegate.todayViewBill.tipPercent;
        myDelegate.todayViewBill = nil;
    }

    [self configureTableSections];
    [self.tableView reloadData];
    
    
//    [self testCurrency];
}

- (void)testCurrency
{
    NSLocale *locale = [NSLocale currentLocale];

    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
    NSLog( @"%@", [nf currencySymbol]);

    for (NSString *code in [NSLocale ISOCurrencyCodes])
    {
        NSString *currencyCodeDisplayName = [locale displayNameForKey:NSLocaleCurrencyCode value:code];
        NSString *currencySymbol = [locale displayNameForKey:NSLocaleCurrencySymbol value:code];
        
        if (currencySymbol.length == 0 || [currencySymbol isEqualToString:code])
        {
            continue;
        }
        
        [nf setCurrencyCode:code];

        //        currencySymbol = [currencySymbol substringFromIndex:currencySymbol.length - 1];
        NSLog(@"%@ : %@ (%@) (%@, %@)", code, currencyCodeDisplayName, currencySymbol, [nf currencySymbol], [nf stringFromNumber:[NSNumber numberWithDouble:10]]);
    }
    
    
    
    NSLocale *lcl = [[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"];
    NSNumberFormatter *fmtr = [[NSNumberFormatter alloc] init];
    [fmtr setNumberStyle:NSNumberFormatterCurrencyStyle];
    [fmtr setLocale:lcl];
    //    NSLog( @"%@", [lcl displayNameForKey:NSLocaleCurrencySymbol value:@"AUD"] );
    //    NSLog( @"%@", [fmtr currencySymbol] );
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self configureInputAccessoryView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self saveBill];
}

- (void)registerNibs
{
    UINib *nib = nil;
    
    nib = [UINib nibWithNibName:@"MATextFieldCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MATextFieldCellIdentifier];
    
    nib = [UINib nibWithNibName:@"MARatingTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MARatingTableViewCellIdentifier];
}

- (void)loadBill
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedBill = [defaults objectForKey:@"bill"];
    if (encodedBill)
    {
        MABill *bill = [NSKeyedUnarchiver unarchiveObjectWithData:encodedBill];
        if (bill)
        {
            self.bill = bill;
        }
    }
    else // First run.
    {
        self.bill = [[MABill alloc] init];
    }
    
    self.bill.delegate = self;
}

- (void)saveBill
{
    if ( ! self.bill)
    {
        return;
    }
    
    NSData *encodedBill = [NSKeyedArchiver archivedDataWithRootObject:self.bill];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedBill forKey:@"bill"];
    BOOL saved = [defaults synchronize];
    if ( ! saved)
    {
        TLog(@"Failed to save bill to standardUserDefaults");
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:AppGroup];
    [sharedDefaults setObject:encodedBill forKey:@"bill"];
    saved = [sharedDefaults synchronize];
    if ( ! saved)
    {
        TLog(@"Failed to save bill to sharedDefaults");
    }
}

// Update the number and position of the table sections.
- (void)configureTableSections
{
    NUM_SECTIONS = 3;

    BILL_SECTION = 0;
    TIP_SECTION = BILL_SECTION + 1;
    TOTAL_SECTION = TIP_SECTION + 1;

    TAX_SECTION = DISABLED_SECTION;
    if ([[MAUserUtil sharedInstance] enableTax])
    {
        ++NUM_SECTIONS;
        
        TAX_SECTION = BILL_SECTION + 1;
        TIP_SECTION = TAX_SECTION + 1;
        TOTAL_SECTION = TIP_SECTION + 1;
    }

    SPLIT_SECTION = DISABLED_SECTION;
    if ([[MAUserUtil sharedInstance] enableSplit])
    {
        ++NUM_SECTIONS;
        
        SPLIT_SECTION = TOTAL_SECTION + 1;
    }
    
    if ([[MAUserUtil sharedInstance] enableServiceRating])
    {
        TIP_RATING_ROW = 0;
        TIP_PERCENT_ROW = 1;
        TIP_ROW = 2;
        TIP_SECTION_ROWS = 3;
    }
    else
    {
        TIP_RATING_ROW = DISABLED_ROW;
        TIP_PERCENT_ROW = 0;
        TIP_ROW = 1;
        TIP_SECTION_ROWS = 2;
    }
    
    [self makeTextFieldIndexPaths];
    [self makeIndexPathToBillKeyDict];
}

// List of index paths that contain text fields.
- (void)makeTextFieldIndexPaths
{
    NSMutableArray *textFieldIndexPaths = [[NSMutableArray alloc] init];
    
    [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:BILL_ROW inSection:BILL_SECTION]];
    [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:TIP_PERCENT_ROW inSection:TIP_SECTION]];
    [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:TIP_ROW inSection:TIP_SECTION]];
    [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:TOTAL_ROW inSection:TOTAL_SECTION]];

    if ([[MAUserUtil sharedInstance] enableTax])
    {
        [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:TAX_PERCENT_ROW inSection:TAX_SECTION]];
        [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:TAX_ROW inSection:TAX_SECTION]];
        [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:BILL_BEFORE_TAX_ROW inSection:TAX_SECTION]];
    }

    if ([[MAUserUtil sharedInstance] enableSplit])
    {
        [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:SPLIT_COUNT_ROW inSection:SPLIT_SECTION]];
        [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:SPLIT_TIP_ROW inSection:SPLIT_SECTION]];
        [textFieldIndexPaths addObject:[NSIndexPath indexPathForRow:SPLIT_TOTAL_ROW inSection:SPLIT_SECTION]];
    }
    
    self.textFieldIndexPaths = textFieldIndexPaths;
}

- (void)makeIndexPathToBillKeyDict
{
    NSMutableDictionary *indexPathToBillKeyDict = [[NSMutableDictionary alloc] init];
    [indexPathToBillKeyDict setObject:@"bill" forKey:[NSIndexPath indexPathForRow:BILL_ROW inSection:BILL_SECTION]];
    [indexPathToBillKeyDict setObject:@"tipPercent" forKey:[NSIndexPath indexPathForRow:TIP_PERCENT_ROW inSection:TIP_SECTION]];
    [indexPathToBillKeyDict setObject:@"tip" forKey:[NSIndexPath indexPathForRow:TIP_ROW inSection:TIP_SECTION]];
    [indexPathToBillKeyDict setObject:@"total" forKey:[NSIndexPath indexPathForRow:TOTAL_ROW inSection:TOTAL_SECTION]];
    [indexPathToBillKeyDict setObject:@"taxPercent" forKey:[NSIndexPath indexPathForRow:TAX_PERCENT_ROW inSection:TAX_SECTION]];
    [indexPathToBillKeyDict setObject:@"tax" forKey:[NSIndexPath indexPathForRow:TAX_ROW inSection:TAX_SECTION]];
    [indexPathToBillKeyDict setObject:@"billBeforeTax" forKey:[NSIndexPath indexPathForRow:BILL_BEFORE_TAX_ROW inSection:TAX_SECTION]];
    [indexPathToBillKeyDict setObject:@"split" forKey:[NSIndexPath indexPathForRow:SPLIT_COUNT_ROW inSection:SPLIT_SECTION]];
    [indexPathToBillKeyDict setObject:@"splitTip" forKey:[NSIndexPath indexPathForRow:SPLIT_TIP_ROW inSection:SPLIT_SECTION]];
    [indexPathToBillKeyDict setObject:@"splitTotal" forKey:[NSIndexPath indexPathForRow:SPLIT_TOTAL_ROW inSection:SPLIT_SECTION]];
    
    self.indexPathToBillKeyDict = indexPathToBillKeyDict;
}

- (void)hideUIToMakeLaunchImages
{
    MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
    UITabBarController *tabBarController = (UITabBarController *)myDelegate.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    for (UITabBarItem *tabBarItem in tabBar.items)
    {
        tabBarItem.title = @"";
    }
    [tabBar setNeedsDisplay];
    [tabBar setNeedsLayout];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.tableView.hidden = YES;
}

#pragma mark - Keyboard notification

-(void)keyboardOnScreen:(NSNotification *)notification
{
    // Add space to bottom of tableview so that rows at the bottom can slide up instead of being covered by the keyboard.
    NSDictionary *info  = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0)];
    
//    if (self.editingIndexPath)
//    {
//        // Scroll cell to the top so that it's visible when entering input.
//        [self.tableView scrollToRowAtIndexPath:self.editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
}

-(void)keyboardOffScreen:(NSNotification *)notification
{
    // Remove bottom space.
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

#pragma mark - Table view source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == BILL_SECTION)
    {
//        return Localize(@"Check");
    }
    else if (section == TIP_SECTION)
    {
        return Localize(@"Gratuity");
    }
    else if (section == TOTAL_SECTION)
    {
//        return Localize(@"Total");
    }
    else if (section == TAX_SECTION)
    {
//        return Localize(@"Tax");
        return Localize(@"Deduct Tax");
    }
    else if (section == SPLIT_SECTION)
    {
//        return Localize(@"Split");
        return Localize(@"Split Check");
    }

    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == BILL_SECTION)
    {
        return BILL_SECTION_ROWS;
    }
    else if (section == TIP_SECTION)
    {
        return TIP_SECTION_ROWS;
    }
    else if (section == TOTAL_SECTION)
    {
        return TOTAL_SECTION_ROWS;
    }
    else if (section == TAX_SECTION)
    {
        return TAX_SECTION_ROWS;
    }
    else if (section == SPLIT_SECTION)
    {
        return SPLIT_SECTION_ROWS;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BILL_SECTION)
    {
        if (indexPath.row == BILL_ROW)
        {
            return [self tableView:tableView billCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == TIP_SECTION)
    {
        if (indexPath.row == TIP_RATING_ROW)
        {
            return [self tableView:tableView ratingCellForRowAtIndexPath:indexPath];
        }
        return [self tableView:tableView tipCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == TOTAL_SECTION)
    {
        if (indexPath.row == TOTAL_ROW)
        {
            return [self tableView:tableView totalCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == TAX_SECTION)
    {
        return [self tableView:tableView taxCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == SPLIT_SECTION)
    {
        return [self tableView:tableView splitCellForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView billCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MATextFieldCell *cell = (MATextFieldCell *)[tableView dequeueReusableCellWithIdentifier:MATextFieldCellIdentifier];
    if (cell == nil)
    {
        cell = [[MATextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MATextFieldCellIdentifier];
    }
    [cell setAppearanceInTable:tableView];
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    cell.textField.clearsOnBeginEditing = YES;

    NSString *labelText = Localize(@"Total");
    if ([[MAUserUtil sharedInstance] enableTax])
    {
//        labelText = Localize(@"Total After Tax");
    }
    cell.textLabel.text = labelText;

    NSString *textFieldText = [self.bill formattedBill];
    cell.textField.text = textFieldText;
    
    UIImage *image = [MAFilePaths billImage];
    cell.imageView.image = image;
//    UIImage *image = [MAFilePaths appearanceImage];
//    NSInteger tag = [MAUtil toTag:indexPath];
//    [MAUtil setImage:image forCell:cell withTag:tag];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView ratingCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MARatingTableViewCell *cell = (MARatingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MARatingTableViewCellIdentifier];
    if (cell == nil)
    {
        cell = [[MARatingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MARatingTableViewCellIdentifier];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setAppearanceInTable:tableView];
    
    NSString *labelText = @"";
    cell.textLabel.text = labelText;
    
    cell.threeStars = YES;
    NSUInteger rating = [cell ratingForTipPercent:self.bill.tipPercent];
    cell.rating = rating;
    cell.delegate = self;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView tipCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MATextFieldCell *cell = (MATextFieldCell *)[tableView dequeueReusableCellWithIdentifier:MATextFieldCellIdentifier];
    if (cell == nil)
    {
        cell = [[MATextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MATextFieldCellIdentifier];
    }
    [cell setAppearanceInTable:tableView];
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    cell.textField.clearsOnBeginEditing = YES;

    NSString *labelText = @"";
    NSString *textFieldText = @"";
    UIImage *image = nil;
    if (indexPath.row == TIP_PERCENT_ROW)
    {
        labelText = Localize(@"Percent");
        textFieldText = [self.bill formattedTipPercent];
        image = [MAFilePaths tipPercentImage];
    }
    else if (indexPath.row == TIP_ROW)
    {
        labelText = Localize(@"Amount");
        textFieldText = [self.bill formattedTip];
        image = [MAFilePaths tipAmountImage];
    }
    cell.textLabel.text = labelText;
    cell.textField.text = textFieldText;
    cell.imageView.image = image;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView totalCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MATextFieldCell *cell = (MATextFieldCell *)[tableView dequeueReusableCellWithIdentifier:MATextFieldCellIdentifier];
    if (cell == nil)
    {
        cell = [[MATextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MATextFieldCellIdentifier];
    }
    [cell setAppearanceInTable:tableView];
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    cell.textField.clearsOnBeginEditing = YES;

    NSString *labelText = Localize(@"Grand Total");
    cell.textLabel.text = labelText;
    
    NSString *textFieldText = [self.bill formattedTotal];
    cell.textField.text = textFieldText;

    UIImage *image = [MAFilePaths totalImage];
    cell.imageView.image = image;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView taxCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MATextFieldCell *cell = (MATextFieldCell *)[tableView dequeueReusableCellWithIdentifier:MATextFieldCellIdentifier];
    if (cell == nil)
    {
        cell = [[MATextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MATextFieldCellIdentifier];
    }
    [cell setAppearanceInTable:tableView];
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    cell.textField.clearsOnBeginEditing = YES;

    NSString *labelText = @"";
    NSString *textFieldText = @"";
    UIImage *image = nil;
    if (indexPath.row == TAX_PERCENT_ROW)
    {
        labelText = Localize(@"Percent");
        textFieldText = [self.bill formattedTaxPercent];
        image = [MAFilePaths taxPercentImage];
    }
    else if (indexPath.row == TAX_ROW)
    {
        labelText = Localize(@"Amount");
        textFieldText = [self.bill formattedTax];
        image = [MAFilePaths taxAmountImage];
    }
    else if (indexPath.row == BILL_BEFORE_TAX_ROW)
    {
        labelText = Localize(@"Total Before Tax");
        textFieldText = [self.bill formattedBillBeforeTax];
        image = [MAFilePaths billImage];
    }
    cell.textLabel.text = labelText;
    cell.textField.text = textFieldText;
    cell.imageView.image = image;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView splitCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MATextFieldCell *cell = (MATextFieldCell *)[tableView dequeueReusableCellWithIdentifier:MATextFieldCellIdentifier];
    if (cell == nil)
    {
        cell = [[MATextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MATextFieldCellIdentifier];
    }
    [cell setAppearanceInTable:tableView];
        
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    cell.textField.clearsOnBeginEditing = YES;

    NSString *labelText = @"";
    NSString *textFieldText = @"";
    UIImage *image = nil;
    if (indexPath.row == SPLIT_COUNT_ROW)
    {
        labelText = Localize(@"Party Size");
        textFieldText = [self.bill formattedSplit];
        image = [MAFilePaths peopleImage];
    }
    else if (indexPath.row == SPLIT_TIP_ROW)
    {
        labelText = Localize(@"Gratuity Per Person");
        textFieldText = [self.bill formattedSplitTip];
        image = [MAFilePaths splitTipImage];
    }
    else if (indexPath.row == SPLIT_TOTAL_ROW)
    {
        labelText = Localize(@"Total Per Person");
        image = [MAFilePaths splitTotalImage];
        textFieldText = [self.bill formattedSplitTotal];
    }
    
    cell.textLabel.text = labelText;
    cell.textField.text = textFieldText;
    cell.imageView.image = image;

    return cell;
}

// On iOS 7, get exception with 0 height cell unless force the heigh to 44. I could implement heightForRowAtIndexPath, but then the cell sizes do not auto-update with Dynamic Type.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [MAUtil rowHeightForTableView:tableView];    
    return height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.tableView.editing)
    {
        return;
    }

    if (indexPath.section == TIP_SECTION && indexPath.row == TIP_RATING_ROW)
    {
        return;
    }
    
    UITextField *textField = [self textFieldForIndexPath:indexPath];
    if (textField)
    {
        [textField becomeFirstResponder];
        return;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)sender
{
    [self dismissInput];
}

#pragma mark - MABillDelegate

- (void)willUpdateBill:(MABill *)bill
{
}

- (void)didUpdateBill:(MABill *)bill
{
    [self saveBill];
    [self.tableView reloadData];
}

- (void)errorUpdatingBill:(MABill *)bill
{
    // For instance, 0 was enter in for the split count, so just reload the table to refresh the invalid text field value.
    [self.tableView reloadData];
}

#pragma mark - MARatingDelegate

- (void)ratingDidChange:(MARatingTableViewCell *)ratingCell
{
    NSNumber *tipPercent = [ratingCell tipPercentForRating:ratingCell.rating];
    self.bill.tipPercent = tipPercent;
}

#pragma mark - Text field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.placeholder = textField.text;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeIndexPath = [self indexPathForTextField:textField];
    self.activeTextField = textField;
    
    [textField setInputAccessoryView:self.keyboardAccessoryView];
    [self checkAndSetEnabledBarButtons];
}

- (UITextField *)textFieldForIndexPath:(NSIndexPath *)indexPath
{
    if ( ! indexPath)
    {
        return nil;
    }
    
    MATextFieldCell *cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell)
    {
        return cell.textField;
    }
    
    return nil;
}

- (NSIndexPath *)indexPathForTextField:(UITextField *)textField
{
    if ( ! textField)
    {
        return nil;
    }

    for (NSIndexPath *indexPath in self.textFieldIndexPaths)
    {
        UITextField *textFieldForIndexPath = [self textFieldForIndexPath:indexPath];
        if (textFieldForIndexPath && textField == textFieldForIndexPath)
        {
            return indexPath;
        }
    }
    
    return nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0)
    {
        [self.tableView reloadData];
        return;
    }
    
    NSIndexPath *textFieldIndexPath = [self indexPathForTextField:textField];
    if ( ! textFieldIndexPath)
    {
        return;
    }
    NSString *billKey = [self.indexPathToBillKeyDict objectForKey:textFieldIndexPath];
    if ( ! billKey)
    {
        return;
    }
    
    NSNumber *billValue = [NSNumber numberWithDouble:[textField.text doubleValue]];

    [self.bill setValue:billValue forKey:billKey];

    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // if (textField == self.someTextField)
    {
        BOOL const shouldChangeChars = [MAUtil numTextField:textField shouldChangeCharactersInRange:range replacementString:string];
        return shouldChangeChars;
    }
    
    return YES;
}

- (IBAction)dismissInput
{
    [self dismissKeyboard];
}

- (IBAction)dismissKeyboard
{
    if (self.activeTextField && [self.activeTextField isFirstResponder])
    {
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }
}

#pragma mark - Input accessory view

- (UIToolbar *)makeInputAccessoryView
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    self.backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"❮" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonTapped)];
    [items addObject:self.backBarButton];
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = 42;
    [items addObject:fixedItem];
    
    self.forwardBarButton = [[UIBarButtonItem alloc] initWithTitle:@"❯" style:UIBarButtonItemStylePlain target:self action:@selector(forwardBarButtonTapped)];
    [items addObject:self.forwardBarButton];
    
    fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = 42;
    [items addObject:fixedItem];
    
    self.update1BarButton = [[UIBarButtonItem alloc] initWithTitle:@"+1" style:UIBarButtonItemStylePlain target:self action:@selector(updateBarButtonTapped:)];
    [items addObject:self.update1BarButton];
    
    fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedItem.width = 21;
    [items addObject:fixedItem];
    
    self.update2BarButton = [[UIBarButtonItem alloc] initWithTitle:@"-1" style:UIBarButtonItemStylePlain target:self action:@selector(updateBarButtonTapped:)];
    [items addObject:self.update2BarButton];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [items addObject:flexibleItem];
    
    self.doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonTapped)];
    [items addObject:self.doneBarButton];
    
    [toolbar setItems:items animated:NO];
    
    return toolbar;
}

- (void)configureInputAccessoryView
{
    self.keyboardAccessoryView = [self makeInputAccessoryView];
    
    // http://unicode-search.net/unicode-namesearch.pl?term=angle
    self.backBarButton.title = @"❮";
    self.forwardBarButton.title = @"❯";
}

- (void)updateInputAccessoryView
{
    // Button text defaults to blue, so set to black to match the regular keyboard button title colors.
    UIColor *barButtonColor = [UIColor blackColor];
    DLog(@"updateInputAccessoryView - 1a");
    self.backBarButton.tintColor = barButtonColor;
    self.forwardBarButton.tintColor = barButtonColor;
    self.doneBarButton.tintColor = barButtonColor;
    self.update1BarButton.tintColor = barButtonColor;
    self.update2BarButton.tintColor = barButtonColor;
    DLog(@"updateInputAccessoryView - 1b");
    
    // Or, set to foreground color.
    //self.backBarButton.tintColor = [MAAppearance foregroundColor];
    //self.forwardBarButton.tintColor = [MAAppearance foregroundColor];
    //self.doneBarButton.tintColor = [MAAppearance foregroundColor];
    
    // Set font for backBarButton and forwardBarButton to make arrows larger and also to support dynamic text.
    if (ABOVE_IOS7)
    {
        NSString *textStyle = UIFontTextStyleBody;
        UIFont *font = [UIFont preferredFontForTextStyle:textStyle];
        NSDictionary *textAttr = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        DLog(@"updateInputAccessoryView - 2a");
        [self.backBarButton setTitleTextAttributes:textAttr forState:UIControlStateNormal];
        [self.backBarButton setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
        [self.forwardBarButton setTitleTextAttributes:textAttr forState:UIControlStateNormal];
        [self.forwardBarButton setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
        [self.update1BarButton setTitleTextAttributes:textAttr forState:UIControlStateNormal];
        [self.update1BarButton setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
        [self.update2BarButton setTitleTextAttributes:textAttr forState:UIControlStateNormal];
        [self.update2BarButton setTitleTextAttributes:textAttr forState:UIControlStateDisabled];
        DLog(@"updateInputAccessoryView - 2b");
    }
}

- (IBAction)backBarButtonTapped
{
    static NSInteger const offset = -1;
    [self activateTextFieldAtOffset:offset];
}

- (IBAction)forwardBarButtonTapped
{
    static NSInteger const offset = +1;
    [self activateTextFieldAtOffset:offset];
}

- (void)activateTextFieldAtOffset:(NSInteger)offset
{
    if ( ! [self.activeTextField isFirstResponder])
    {
        return;
    }
    
    NSInteger index = [self.textFieldIndexPaths indexOfObject:self.activeIndexPath];
    index += offset;
    if (index < 0 || index >= self.textFieldIndexPaths.count)
    {
        return;
    }
    
    NSIndexPath *indexPath = [self.textFieldIndexPaths objectAtIndex:index];
    if ( ! indexPath)
    {
        return;
    }
    
    [self dismissKeyboard];

    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (IBAction)doneBarButtonTapped
{
    [self dismissKeyboard];
}

- (IBAction)updateBarButtonTapped:(UIBarButtonItem *)button
{
    double updateAmount = 1;
    UITextField *textField = self.activeTextField;
    
    if (button == self.update2BarButton)
    {
        updateAmount = -updateAmount;
    }
    
    double currentValue = 0;
    NSString *text = textField.text;
    if (text && text.length != 0)
    {
        currentValue = [MAUtil parseDouble:text];
    }
    else
    {
        // Use the placeholder text.
        // Note: if textField.placeholder is not set or is a string like "Weight", then 0 will be returned.
        text = textField.placeholder;
        currentValue = [MAUtil parseDouble:text];
    }
    
    // If rounding is enabled and, say, +1 is pressed, then convert 15.25 to 16, then 17, 18, etc. If -1 is pressed, then convert 15.25 to 15, then 14, 13, etc. So, the button rounds the first time and then adds/subtracts 1 each subsequent time. This keeps the rounding intuitive and work the way the user likely wants when rounding to the nearest $1, while also keeping the UI clean by not having to add an extra button.
    static BOOL const enableRounding = YES;
    if (enableRounding)
    {
        double fraction = fabs((int)currentValue - currentValue);
        if (fraction > 0)
        {
            if (updateAmount == -1)
            {
                updateAmount = -fraction;
            }
            else if (updateAmount == 1)
            {
                updateAmount = 1 - fraction;
            }
        }
    }
    
    double newValue = currentValue + updateAmount;
    if (newValue < 0)
    {
        newValue = 0;
    }
    NSString *newValueStr = [MAUtil formatDouble:newValue];
    textField.text = newValueStr;
}

- (void)checkAndSetEnabledBarButtons
{
    self.backBarButton.enabled = YES;
    self.forwardBarButton.enabled = YES;
    
    self.update1BarButton.enabled = YES;
    self.update2BarButton.enabled = YES;

    self.update1BarButton.title = Localize(@"+1");
    self.update2BarButton.title = Localize(@"-1");

    NSUInteger index = [self.textFieldIndexPaths indexOfObject:self.activeIndexPath];
    BOOL isFirstTextField = (index == 0);
    BOOL isLastTextField = (index == (self.textFieldIndexPaths.count - 1));
    
    if (isFirstTextField)
    {
        self.backBarButton.enabled = NO;
    }
    else if (isLastTextField)
    {
        self.forwardBarButton.enabled = NO;
    }
}

#pragma mark - iAd

- (void)setupAdBanner
{
    if ( ! No_Ads_Iap)
    {
        self.adBanner = nil;
        return;
    }
    
    BOOL const purchased = ! [MATipIAPHelper checkForIAP];
    if (purchased)
    {
        self.adBanner = nil;
        return;
    }
    
    self.adBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.adBanner];

    // Setup constraints for the banner.
    self.adBanner.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = nil;
    
    // Leading.
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.adBanner
                  attribute:NSLayoutAttributeLeading
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.view
                  attribute:NSLayoutAttributeLeading
                  multiplier:1.0
                  constant:0.0];
    [self.view addConstraint:constraint];
    
    // Trailing.
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.adBanner
                  attribute:NSLayoutAttributeTrailing
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.view
                  attribute:NSLayoutAttributeTrailing
                  multiplier:1.0
                  constant:0.0];
    [self.view addConstraint:constraint];

    // Bottom.
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.adBanner
                  attribute:NSLayoutAttributeBottom
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.view
                  attribute:NSLayoutAttributeBottom
                  multiplier:1.0
                  constant:0.0];
    self.adBannerBottomSizeConstraint = constraint;
    [self.view addConstraint:constraint];

    // Height.
    // Note: Ad banner's height seems pegged to 50 in portrait mode regardless of this constraint.
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.adBanner
                  attribute:NSLayoutAttributeHeight
                  relatedBy:NSLayoutRelationEqual
                  toItem:nil
                  attribute:NSLayoutAttributeNotAnAttribute
                  multiplier:1.0
                  constant:50.];
    self.adBannerHeightConstraint = constraint;
    [self.view addConstraint:constraint];

    self.adBannerBottomSizeConstraint.constant = self.adBannerHeightConstraint.constant;

    self.adBanner.delegate = self;
    self.bannerIsVisible = NO;
}

- (void)hideAdBannerIfPurchased
{
    // If purchased, hide and remove the banner.
    BOOL const purchased = ! [MATipIAPHelper checkForIAP];
    if (purchased)
    {
        [self showAdBanner:NO];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
//    TLog(@"");
    [self showAdBanner:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
//    TLog(@"%@", error);
    [self showAdBanner:NO];
}

- (void)showAdBanner:(BOOL)show
{
    // Check if already showing or hiding the banner.
    if (show && self.bannerIsVisible)
    {
        return;
    }
    else if ( ! show && ! self.bannerIsVisible)
    {
        return;
    }
    
//    TLog(@"%d", show);

    CGFloat constraintConstant = 0;
    if ( ! show)
    {
        constraintConstant = self.adBannerHeightConstraint.constant;
    }
    
    self.adBannerBottomSizeConstraint.constant = constraintConstant;
    [UIView animateWithDuration:.3
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.adBanner.superview layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                     }];
    
    self.bannerIsVisible = show;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
//    TLog(@"Banner view is beginning an ad action: %d", willLeave);
    BOOL shouldExecuteAction = YES;
    if ( ! willLeave && shouldExecuteAction)
    {
        // Stop all interactive processes.
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
//    TLog(@"%@", banner);
    // Resume stopped processes.
    // [video resume];
    // [audio resume];
}

@end
