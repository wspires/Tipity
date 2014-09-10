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
#import "MAProductTableViewCell.h"
#import "MAProduct.h"
#import "MATextFieldCell.h"
#import "MAUserUtil.h"
#import "MAUtil.h"
#import "MATipIAPHelper.h"

#import <iAd/iAd.h>

DECL_TABLE_IDX(NUM_SECTIONS, 4);

DECL_TABLE_IDX(BILL_SECTION, 0);
DECL_TABLE_IDX(BILL_ROW, 0);
DECL_TABLE_IDX(BILL_SECTION_ROWS, 1);

DECL_TABLE_IDX(TIP_SECTION, 1);
DECL_TABLE_IDX(TIP_PERCENT_ROW, 0);
DECL_TABLE_IDX(TIP_ROW, 1);
DECL_TABLE_IDX(TIP_SECTION_ROWS, 2);

DECL_TABLE_IDX(TOTAL_SECTION, 2);
DECL_TABLE_IDX(TOTAL_ROW, 0);
DECL_TABLE_IDX(TOTAL_SECTION_ROWS, 1);

DECL_TABLE_IDX(SPLIT_SECTION, 3);
DECL_TABLE_IDX(SPLIT_COUNT_ROW, 0);
DECL_TABLE_IDX(SPLIT_TIP_ROW, 1);
DECL_TABLE_IDX(SPLIT_TOTAL_ROW, 2);
DECL_TABLE_IDX(SPLIT_SECTION_ROWS, 3);

static NSString *MATextFieldCellIdentifier = @"MATextFieldCellIdentifier";

@interface MATipViewController () <MABillDelegate, UITextFieldDelegate, UIActionSheetDelegate, ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MABill *bill;
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) UITextField *billTextField;
@property (strong, nonatomic) UITextField *tipPercentTextField;
@property (strong, nonatomic) UITextField *tipTextField;
@property (strong, nonatomic) UITextField *totalTextField;

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
@synthesize activeTextField = _activeTextField;
@synthesize billTextField = _billTextField;
@synthesize tipPercentTextField = _tipPercentTextField;
@synthesize tipTextField = _tipTextField;
@synthesize totalTextField = _totalTextField;

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
    [self registerNibs];

    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];
    
    // Make the table background clear, so that this view's background shows.
    [MAAppearance clearBackgroundForTableView:self.tableView];

    [self loadBill];
    
    [self setupAdBanner];

    //[self hideUIToMakeLaunchImages];
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

    [self.tableView reloadData];
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
        TLog(@"Failed to save bill");
    }
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
        //return Localize(@"Bill");
    }
    else if (section == TIP_SECTION)
    {
        return Localize(@"Tip");
    }
    else if (section == TOTAL_SECTION)
    {
//        return Localize(@"Total");
    }
    else if (section == SPLIT_SECTION)
    {
        return Localize(@"Split");
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
//        if (indexPath.row == TIP_ROW)
        {
            return [self tableView:tableView tipCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == TOTAL_SECTION)
    {
        if (indexPath.row == TOTAL_ROW)
        {
            return [self tableView:tableView totalCellForRowAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == SPLIT_SECTION)
    {
//        if (indexPath.row == SPLIT_COUNT_ROW)
        {
            return [self tableView:tableView splitCellForRowAtIndexPath:indexPath];
        }
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
    
//    NSString *unit = @""; //[self.settings objectForKey:WeightLogUnit];
    cell.label.text = @""; // SFmt(@" %@", unit); // Insert a space char because the text field and label have 0 space separating them.
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    self.billTextField = cell.textField; // Save reference to text field so it's easier to access.
    
    NSString *labelText = Localize(@"Bill");
    cell.textLabel.text = labelText;

    NSString *textFieldText = [self.bill formattedBill];
    cell.textField.text = textFieldText;

    [cell.textField setInputAccessoryView:self.keyboardAccessoryView];

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
    
    NSString *unit = @""; //[self.settings objectForKey:WeightLogUnit];
    cell.label.text = SFmt(@" %@", unit); // Insert a space char because the text field and label have 0 space separating them.
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    
    NSString *labelText = @"";
    NSString *textFieldText = @"";
    if (indexPath.row == TIP_PERCENT_ROW)
    {
        labelText = Localize(@"Percent");
        textFieldText = [self.bill formattedTipPercent];
        self.tipPercentTextField = cell.textField;
    }
    else if (indexPath.row == TIP_ROW)
    {
        labelText = Localize(@"Amount");
        textFieldText = [self.bill formattedTip];
        self.tipTextField = cell.textField;
    }
    cell.textLabel.text = labelText;
    cell.textField.text = textFieldText;
    
    [cell.textField setInputAccessoryView:self.keyboardAccessoryView];

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
    
    //    NSString *unit = @""; //[self.settings objectForKey:WeightLogUnit];
    cell.label.text = @""; // SFmt(@" %@", unit); // Insert a space char because the text field and label have 0 space separating them.
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    self.totalTextField = cell.textField; // Save reference to text field so it's easier to access.
    
    NSString *labelText = Localize(@"Total");
    cell.textLabel.text = labelText;
    
    NSString *textFieldText = [self.bill formattedTotal];
    cell.textField.text = textFieldText;
    
    [cell.textField setInputAccessoryView:self.keyboardAccessoryView];

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
    
    NSString *unit = @""; //[self.settings objectForKey:WeightLogUnit];
    cell.label.text = SFmt(@" %@", unit); // Insert a space char because the text field and label have 0 space separating them.
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    
    NSString *labelText = @"";
    NSString *textFieldText = @"";
    if (indexPath.row == SPLIT_COUNT_ROW)
    {
        labelText = Localize(@"People");
        textFieldText = [self.bill formattedSplit];
//        self.tipPercentTextField = cell.textField;
    }
    else if (indexPath.row == SPLIT_TIP_ROW)
    {
        labelText = Localize(@"Tip Per Person");
        textFieldText = [self.bill formattedSplitTip];
//        self.tipTextField = cell.textField;
    }
    else if (indexPath.row == SPLIT_TOTAL_ROW)
    {
        labelText = Localize(@"Total Per Person");
        textFieldText = [self.bill formattedSplitTotal];
        //        self.tipTextField = cell.textField;
    }
    
    cell.textLabel.text = labelText;
    cell.textField.text = textFieldText;
    
    [cell.textField setInputAccessoryView:self.keyboardAccessoryView];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = [MAUtil rowHeightForTableView:tableView];
    return rowHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.tableView.editing)
    {
        return;
    }

    if (indexPath.section == BILL_SECTION)
    {
        if (indexPath.row == BILL_ROW)
        {
            [self selectBillAtPath:indexPath];
        }
    }
    else if (indexPath.section == TIP_SECTION)
    {
        if (indexPath.row == TIP_PERCENT_ROW)
        {
            [self selectTipPercentAtPath:indexPath];
        }
        else if (indexPath.row == TIP_ROW)
        {
            [self selectTipAtPath:indexPath];
        }
    }
    else if (indexPath.section == TOTAL_SECTION)
    {
        if (indexPath.row == TOTAL_ROW)
        {
            [self selectTotalAtPath:indexPath];
        }
    }
    else if (indexPath.section == SPLIT_SECTION)
    {
        if (indexPath.row == SPLIT_COUNT_ROW)
        {
            [self selectSplitAtPath:indexPath];
        }
        else if (indexPath.row == SPLIT_TIP_ROW)
        {
            [self selectSplitTipAtPath:indexPath];
        }
        else if (indexPath.row == SPLIT_TOTAL_ROW)
        {
            [self selectSplitTotalAtPath:indexPath];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)selectBillAtPath:(NSIndexPath *)indexPath
{
    [self makeFirstResponderForTextFieldCellAtIndexPath:indexPath];
}

- (void)selectTipPercentAtPath:(NSIndexPath *)indexPath
{
    [self makeFirstResponderForTextFieldCellAtIndexPath:indexPath];
}

- (void)selectTipAtPath:(NSIndexPath *)indexPath
{
    [self makeFirstResponderForTextFieldCellAtIndexPath:indexPath];
}

- (void)selectTotalAtPath:(NSIndexPath *)indexPath
{
    [self makeFirstResponderForTextFieldCellAtIndexPath:indexPath];
}

- (void)selectSplitAtPath:(NSIndexPath *)indexPath
{
    [self makeFirstResponderForTextFieldCellAtIndexPath:indexPath];
}

- (void)selectSplitTipAtPath:(NSIndexPath *)indexPath
{
    [self makeFirstResponderForTextFieldCellAtIndexPath:indexPath];
}

- (void)selectSplitTotalAtPath:(NSIndexPath *)indexPath
{
    [self makeFirstResponderForTextFieldCellAtIndexPath:indexPath];
}

- (void)makeFirstResponderForTextFieldCellAtIndexPath:(NSIndexPath *)indexPath
{
    MATextFieldCell *cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell)
    {
        [cell.textField becomeFirstResponder];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)sender
{
    [self dismissInput];
}

#pragma mark - MABillDelegate

- (void)didUpdateBill:(MABill *)bill
{
    [self saveBill];
    [self.tableView reloadData];
}

#pragma mark - Text field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.placeholder = textField.text;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    [textField setInputAccessoryView:self.keyboardAccessoryView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    MATextFieldCell *cell = nil;
    NSIndexPath *indexPath = nil;
    
    if (textField.text.length == 0)
    {
        [self.tableView reloadData];
        return;
    }
    
    NSNumber *number = [NSNumber numberWithDouble:[textField.text doubleValue]];
    
    indexPath = [NSIndexPath indexPathForRow:BILL_ROW inSection:BILL_SECTION];
    cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && textField == cell.textField)
    {
        self.bill.bill = number;
    }
    
    indexPath = [NSIndexPath indexPathForRow:TIP_PERCENT_ROW inSection:TIP_SECTION];
    cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && textField == cell.textField)
    {
        self.bill.tipPercent = number;
    }
    
    indexPath = [NSIndexPath indexPathForRow:TIP_ROW inSection:TIP_SECTION];
    cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && textField == cell.textField)
    {
        self.bill.tip = number;
    }
    
    indexPath = [NSIndexPath indexPathForRow:TOTAL_ROW inSection:TOTAL_SECTION];
    cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && textField == cell.textField)
    {
        self.bill.total = number;
    }
    
    indexPath = [NSIndexPath indexPathForRow:SPLIT_COUNT_ROW inSection:SPLIT_SECTION];
    cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && textField == cell.textField)
    {
        self.bill.split = number;
    }

    indexPath = [NSIndexPath indexPathForRow:SPLIT_TIP_ROW inSection:SPLIT_SECTION];
    cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && textField == cell.textField)
    {
        self.bill.splitTip = number;
    }

    indexPath = [NSIndexPath indexPathForRow:SPLIT_TOTAL_ROW inSection:SPLIT_SECTION];
    cell = (MATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && textField == cell.textField)
    {
        self.bill.splitTotal = number;
    }

    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //    if (textField == self.billTextField)
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
    if ([self.tipPercentTextField isFirstResponder])
    {
        [self resetTextInTextView:self.tipPercentTextField];
        [self.billTextField becomeFirstResponder];
    }
    else if ([self.tipTextField isFirstResponder])
    {
        [self resetTextInTextView:self.tipTextField];
        [self.tipPercentTextField becomeFirstResponder];
    }
}

- (IBAction)forwardBarButtonTapped
{
    if ([self.billTextField isFirstResponder])
    {
        [self resetTextInTextView:self.billTextField];
        [self.tipPercentTextField becomeFirstResponder];
    }
    else if ([self.tipPercentTextField isFirstResponder])
    {
        [self resetTextInTextView:self.tipPercentTextField];
        [self.tipTextField becomeFirstResponder];
    }
}

- (void)resetTextInTextView:(UITextField *)textView
{
    // Replace text in the text view with its placeholder text if the text field is empty but the placeholder text is non-empty.
    if ([textView isFirstResponder])
    {
        if ( ! textView.text || textView.text.length == 0)
        {
            NSString *text = textView.placeholder;
            double currentValue = [MAUtil parseDouble:text];
            if (currentValue != 0)
            {
                textView.text = text;
            }
        }
    }
}

- (IBAction)doneBarButtonTapped
{
    if ([self.billTextField isFirstResponder])
    {
        [self resetTextInTextView:self.tipTextField];
    }
    else if ([self.tipPercentTextField isFirstResponder])
    {
        [self resetTextInTextView:self.tipPercentTextField];
    }
    else if ([self.tipTextField isFirstResponder])
    {
        [self resetTextInTextView:self.tipTextField];
    }
    else
    {
        // Note: this is expected behavior if this cell's text field has focus but the table is reloaded, which might cause this cell to be discarded.
        //        NSLog(@"No first responder!");
    }
    
    [self dismissKeyboard];
}

- (IBAction)updateBarButtonTapped:(UIBarButtonItem *)button
{
    double updateAmount = 0;
    UITextField *textField = nil;
    
    if ([self.billTextField isFirstResponder])
    {
        updateAmount = 1;
        textField = self.billTextField;
    }
    else if ([self.tipPercentTextField isFirstResponder])
    {
        updateAmount = 1;
        textField = self.tipPercentTextField;
    }
    else if ([self.tipTextField isFirstResponder])
    {
        updateAmount = 1;
        textField = self.tipTextField;
    }
    
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
    
    if ([self.billTextField isFirstResponder])
    {
        self.backBarButton.enabled = NO;
        self.update1BarButton.title = Localize(@"+1");
        self.update2BarButton.title = Localize(@"-1");
    }
    else if ([self.tipPercentTextField isFirstResponder])
    {
        self.update1BarButton.title = Localize(@"+1");
        self.update2BarButton.title = Localize(@"-1");
    }
    else if ([self.tipTextField isFirstResponder])
    {
        self.forwardBarButton.enabled = NO;
        self.update1BarButton.title = Localize(@"+1");
        self.update2BarButton.title = Localize(@"-1");
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
