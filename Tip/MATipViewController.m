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

DECL_TABLE_IDX(NUM_SECTIONS, 3);

DECL_TABLE_IDX(BILL_SECTION, 0);
DECL_TABLE_IDX(BILL_ROW, 0);
DECL_TABLE_IDX(BILL_SECTION_ROWS, 1);

DECL_TABLE_IDX(PRODUCTS_SECTION, 1);

DECL_TABLE_IDX(CLEAR_SECTION, 2);
DECL_TABLE_IDX(CLEAR_ROW, 0);
DECL_TABLE_IDX(CLEAR_SECTION_ROWS, 1);

static NSString *MATextFieldCellIdentifier = @"MATextFieldCellIdentifier";
static NSString *MAProductTableViewCellIdentifier = @"MAProductTableViewCellIdentifier";

@interface MATipViewController () <MABillDelegate, MAProductDelegate, MAProductCellDelegate, UITextFieldDelegate, UIActionSheetDelegate, ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MABill *bill;
@property (weak, nonatomic) UITextField *billTextField;

@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSMutableArray *cheapestProducts;
@property (strong, nonatomic) UIActionSheet *deleteActionSheet;
@property (assign, nonatomic) BOOL didInsertCell;
@property (strong, nonatomic) ADBannerView *adBanner;
@property (weak, nonatomic) NSLayoutConstraint *adBannerBottomSizeConstraint;
@property (weak, nonatomic) NSLayoutConstraint *adBannerHeightConstraint;
@property (assign, nonatomic) BOOL bannerIsVisible;
@property (assign, nonatomic) NSUInteger pricePerUnitFractionDigits;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@end

@implementation MATipViewController
@synthesize tableView = _tableView;
@synthesize bill = _bill;
@synthesize products = _products;
@synthesize cheapestProducts = _cheapestProducts;
@synthesize deleteActionSheet = _deleteActionSheet;
@synthesize didInsertCell = _didInsertCell;
@synthesize adBanner = _adBanner;
@synthesize adBannerBottomSizeConstraint = _adBannerBottomSizeConstraint;
@synthesize adBannerHeightConstraint = _adBannerHeightConstraint;
@synthesize bannerIsVisible = _bannerIsVisible;
@synthesize pricePerUnitFractionDigits = _pricePerUnitFractionDigits;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self registerNibs];

    [[self view] setBackgroundColor:[MAAppearance backgroundColor]];
    [MAUtil setAdjustableNavTitle:self.navigationItem.title withNavigationItem:self.navigationItem];
    
    // Make the table background clear, so that this view's background shows.
    [MAAppearance clearBackgroundForTableView:self.tableView];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:Localize(@"Edit")
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(toggleEdit)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    self.pricePerUnitFractionDigits = [MAProduct unitPriceFormatter].maximumFractionDigits;
    
    self.didInsertCell = NO;
    [self loadBill];
    [self loadProducts];
    
    [self setupAdBanner];

    //self.tableView.estimatedRowHeight = 89;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self saveProducts];
}

- (void)registerNibs
{
    UINib *nib = nil;
    
    nib = [UINib nibWithNibName:@"MATextFieldCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MATextFieldCellIdentifier];

    nib = [UINib nibWithNibName:@"MAProductTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MAProductTableViewCellIdentifier];
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

- (void)loadProducts
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *encodedProducts = [defaults objectForKey:@"products"];
    if (encodedProducts)
    {
        // Decode each product.
        NSMutableArray *products = [[NSMutableArray alloc] init];
        for (NSData *encodedProduct in encodedProducts)
        {
            MAProduct *product = [NSKeyedUnarchiver unarchiveObjectWithData:encodedProduct];
            if (product)
            {
                [products addObject:product];
            }
        }
        
        self.products = products;
    }
    else // First run, no products yet.
    {
        self.products = [[NSMutableArray alloc] init];
        
        // Create initial set of products.
        MAProduct *product = nil;
        
        product = [[MAProduct alloc] initWithPrice:[NSNumber numberWithDouble:18.99] quantity:[NSNumber numberWithDouble:12] size:[NSNumber numberWithDouble:1]];
        [self.products addObject:product];

        product = [[MAProduct alloc] initWithPrice:[NSNumber numberWithDouble:17.99] quantity:[NSNumber numberWithDouble:10] size:[NSNumber numberWithDouble:1]];
        [self.products addObject:product];
        
        product = [[MAProduct alloc] initWithPrice:[NSNumber numberWithDouble:16.99] quantity:[NSNumber numberWithDouble:8] size:[NSNumber numberWithDouble:1]];
        [self.products addObject:product];
    }
    
    if ( ! self.cheapestProducts)
    {
        self.cheapestProducts = [[NSMutableArray alloc] init];
    }
    if (self.products.count != 0)
    {
        [self updateCheapestProducts];
        [self updatePricePerUnitFractionDigits];
    }
}

- (void)saveProducts
{
    if ( ! self.products)
    {
        return;
    }
    
    // Encode each product before saving them.
    NSMutableArray *encodedProducts = [[NSMutableArray alloc] init];
    for (MAProduct *product in self.products)
    {
        NSData *encodedProduct = [NSKeyedArchiver archivedDataWithRootObject:product];
        [encodedProducts addObject:encodedProduct];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedProducts forKey:@"products"];
    BOOL saved = [defaults synchronize];
    if ( ! saved)
    {
        TLog(@"Failed to save products");
    }
}

- (IBAction)toggleEdit
{
    BOOL editing = ! self.tableView.editing;
    [self.tableView setEditing:editing animated:YES];
    
    if (editing)
    {
        [self.navigationItem.rightBarButtonItem setTitle:Localize(@"Done")];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:Localize(@"Edit")];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
}

- (BOOL)isProductRow:(NSUInteger)row
{
    return (row < self.products.count);
}

- (BOOL)isAddProductRow:(NSUInteger)row
{
    return (row == self.products.count);
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
    
    if (self.editingIndexPath)
    {
        // Scroll cell to the top so that it's visible when entering input.
        [self.tableView scrollToRowAtIndexPath:self.editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
        //return Localize(@"Products");
    }
    else if (section == PRODUCTS_SECTION)
    {
        //return Localize(@"Products");
    }
    else if (section == CLEAR_SECTION)
    {
        //return Localize(@"Clear");
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == BILL_SECTION)
    {
        return BILL_SECTION_ROWS;
    }
    else if (section == PRODUCTS_SECTION)
    {
        return self.products.count + 1;
    }
    else if (section == CLEAR_SECTION)
    {
        return CLEAR_SECTION_ROWS;
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
    else if (indexPath.section == PRODUCTS_SECTION)
    {
        if ([self isAddProductRow:indexPath.row])
        {
            return [self tableView:tableView addProductCellForRowAtIndexPath:indexPath];
        }
        return [self tableView:tableView productCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == CLEAR_SECTION)
    {
        if (indexPath.row == CLEAR_ROW)
        {
            return [self tableView:tableView clearCellForRowAtIndexPath:indexPath];            
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
    
    NSString *unit = @""; //[self.settings objectForKey:WeightLogUnit];
    cell.label.text = SFmt(@" %@", unit); // Insert a space char because the text field and label have 0 space separating them.
    
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    self.billTextField = cell.textField; // Save reference to text field so it's easier to access.
    
    cell.textLabel.text = Localize(@"Bill");
    
    NSString *billStr = [self.bill formattedBill];
    if (billStr && billStr.length != 0)
    {
        cell.textField.text = billStr;
    }
    else
    {
        billStr = Localize(@"-");
    }
    cell.textField.text = billStr;
    
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView addProductCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MAAddProductCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    UIImage *image = [MAFilePaths circlePlusImage];
    NSInteger tag = [MAUtil toTag:indexPath];
    [MAUtil setImage:image forCell:cell withTag:tag];

    cell.textLabel.text = Localize(@"Add Item");
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (MAProductTableViewCell *)tableView:(UITableView *)tableView productCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAProductTableViewCell *cell = (MAProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MAProductTableViewCellIdentifier];
    if (cell == nil)
    {
        cell = [[MAProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MAProductTableViewCellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    [self configureProductCell:cell atIndexPath:indexPath];
    
    // When a new cell is inserted, immediately bring up the keyboard with focus on the first text field so that the user can quickly enter in a value.
    if (self.didInsertCell && indexPath.row == (self.products.count - 1))
    {
        self.didInsertCell = NO;
        [self showKeyboardForCell:cell];
    }

    return cell;
}

- (void)configureProductCell:(MAProductTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = @"";

    cell.pricePerUnitFractionDigits = self.pricePerUnitFractionDigits;
    
    MAProduct *product = [self.products objectAtIndex:indexPath.row];
    [cell configureWithProduct:product];
    cell.delegate = self;
    
    UIImage *image = nil;
    if ([self.cheapestProducts containsObject:product])
    {
        image = [MAFilePaths starFilledImage];
    }
    NSInteger tag = [MAUtil toTag:indexPath];
    [MAUtil setImage:image forCell:cell withTag:tag];
    
    BOOL enableSizeField = [[MAUserUtil sharedInstance] enableSizeField];
    BOOL const hideSizeField = ! enableSizeField;
    cell.hideSizeField = hideSizeField;
    
    BOOL enableDesc = [[MAUserUtil sharedInstance] enableDescription];
    BOOL const hideDesc = ! enableDesc;
    cell.hideDescription = hideDesc;
}

- (void)showKeyboardForCell:(MAProductTableViewCell *)cell
{
    // Default to editing price.
    [self showKeyboardForCell:cell tag:PriceTag];
}

- (void)showKeyboardForCell:(MAProductTableViewCell *)cell tag:(NSInteger)tag
{
    // Note that a small time delay is required before calling becomeFirstResponder to give the current first responder time to resign.
    // Also, use the main queue since an UI control is being accessed, so a background queue should not be used.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 4), dispatch_get_main_queue(), ^{
        if (cell)
        {
            UITextField *textField = [cell textFieldForTag:tag];
            if (textField && [textField canBecomeFirstResponder])
            {
                BOOL accepted = [textField becomeFirstResponder];
                if ( ! accepted)
                {
                    // Had some issues before with the textField returning NO and not becoming the first responder, so log it if it happens again.
                    TLog(@"[textField becomeFirstResponder]: %d (tag=%d)", accepted, (int)tag);
                }
            }
        }
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView clearCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MAClearCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [MAAppearance setAppearanceForCell:cell tableStyle:tableView.style];
    
    cell.textLabel.text = Localize(@"Clear");
    cell.textLabel.textColor = [MAAppearance foregroundColor];
    
    UIImage *image = [MAFilePaths redCircleCrossImage];
    NSInteger tag = [MAUtil toTag:indexPath];
    [MAUtil setImage:image forCell:cell withTag:tag];

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (self.products.count == 0)
    {
        cell.textLabel.enabled = NO;
    }
    else
    {
        cell.textLabel.enabled = YES;
    }
    
    return cell;
}

- (void)reloadClearRow
{
    NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:CLEAR_ROW inSection:CLEAR_SECTION], nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (MAProductTableViewCell *)sizingCell
{
    static MAProductTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:MAProductTableViewCellIdentifier];
    });
    
    return sizingCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == PRODUCTS_SECTION)
    {
        if ([self isProductRow:indexPath.row])
        {
            MAProductTableViewCell *sizingCell = [self sizingCell];
            [self configureProductCell:sizingCell atIndexPath:indexPath];
            CGFloat rowHeight = sizingCell.rowHeight;
            return rowHeight;
        }
    }
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
    else if (indexPath.section == PRODUCTS_SECTION)
    {
        if ([self isAddProductRow:indexPath.row])
        {
            [self addProduct];
        }
    }
    else if (indexPath.section == CLEAR_SECTION)
    {
        if (indexPath.row == CLEAR_ROW)
        {
            if (self.products.count == 0)
            {
                return;
            }
            [self showDeleteActionSheet];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView)
    {
        return NO;
    }

    if (indexPath.section == PRODUCTS_SECTION)
    {
        if ([self isProductRow:indexPath.row])
        {
            return YES;
        }
    }
    else if (indexPath.section == CLEAR_SECTION)
    {
        return NO;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Disable swipe to delete unless in edit mode.
    if (tableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        MAProduct *product = [self.products objectAtIndex:indexPath.row];
        [self.products removeObjectAtIndex:indexPath.row];
        [self saveProducts];
        
        // Delete from the tableview, possibly sliding in an insert row cell.
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        if ([self.cheapestProducts containsObject:product])
        {
            [self.cheapestProducts removeObject:product];
            if (self.cheapestProducts.count == 0)
            {
                [self updateCheapestProducts];
                [self updatePricePerUnitFractionDigits];
                [self reloadClearRow];
            }
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView)
    {
        return NO;
    }

    if (indexPath.section == PRODUCTS_SECTION)
    {
        if ([self isProductRow:indexPath.row])
        {
            return YES;
        }
    }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // Prevent moving custom user cell over the default user cell.
    if (proposedDestinationIndexPath.section == PRODUCTS_SECTION)
    {
        if ([self isProductRow:proposedDestinationIndexPath.row])
        {
            return proposedDestinationIndexPath;
        }
    }
    return sourceIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (toIndexPath.section != PRODUCTS_SECTION)
    {
        return;
    }
    else if ( ! [self isProductRow:toIndexPath.row])
    {
        return;
    }
    
    NSUInteger fromRow = [fromIndexPath row];
    NSUInteger toRow = [toIndexPath row];
    if (fromRow == toRow)
    {
        return;
    }
    
    id object = [self.products objectAtIndex:fromRow];
    [self.products removeObjectAtIndex:fromRow];
    [self.products insertObject:object atIndex:toRow];
    [self saveProducts];

    [tableView reloadData];
}

- (void)selectBillAtPath:(NSIndexPath *)indexPath
{
    [self.billTextField becomeFirstResponder];
}

- (void)addProduct
{
    if (Unlimited_Items_Iap && [MATipIAPHelper checkAndAlertForIAPWithProductCount:self.products.count])
    {
        return;
    }
    
    // Update the model by copying the last product (if exists) to use as the initial new product.
    MAProduct *product = nil;
    if (self.products.count == 0)
    {
        product = [[MAProduct alloc] init];
        [self.cheapestProducts addObject:product];
    }
    else
    {
        MAProduct *lastProduct = [self.products lastObject];
        product = [lastProduct copy];
        if ([self.cheapestProducts containsObject:lastProduct])
        {
            [self.cheapestProducts addObject:product];
        }
    }
    product.delegate = self;
    [self.products addObject:product];
    [self saveProducts];

    // Update table view.
    self.didInsertCell = YES; // Set flag so that text field starts accepting user input.
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.products.count - 1) inSection:PRODUCTS_SECTION];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (self.products.count == 1)
    {
        // Enable the clear row since have a product now.
        [self reloadClearRow];
    }
    [self.tableView endUpdates];
}

#pragma mark - MAProductDelegate

- (void)didEndEditing:(MAProduct *)product
{
    //TLog(@"%@ / %@ = %@", product.price, product.quantity, [product pricePerUnit]);
    //[self updateCheapestProducts];
}

#pragma mark - MAProductCellDelegate

- (void)didBeginEditingCell:(MAProductTableViewCell *)productCell
{
    // Do not call scrollToRowAtIndexPath here. It gets called in keyboardOnScreen with self.editingIndexPath because didBeginEditingCell gets called before gets called. Otherwise, the tableview scrolls up again if you switch from one text field to another, which looks weird.
    NSIndexPath *indexPath = [self.tableView indexPathForCell:productCell];
    if ( ! indexPath)
    {
        return;
    }
    
    if ( ! self.editingIndexPath)
    {
        // No previous index path, so just assign it.
        self.editingIndexPath = indexPath;
        return;
    }

    if (indexPath.section == self.editingIndexPath.section && indexPath.row == self.editingIndexPath.row)
    {
        // Still editing in the same row (just a different text field in the same row), so nothing extra to do.
        return;
    }
    
    // Switched from editing a text field in one row to editing in a different row.
    self.editingIndexPath = indexPath;
    
    // Update the other cells as the cheapest product, etc. might have changed. This may cause a reloading of cells in the table view which could then cause this productCell to no longer be actually visible with a no longer valid text field and first responder. So, save the path and text field info prior to updating the table so that we can make the corresponding text field in the new cell the first responder.
    NSInteger tagForFirstResponder = [productCell tagForFirstResponder];
    UITextField *textField = [productCell textFieldForTag:tagForFirstResponder];
    if (textField)
    {
        [textField resignFirstResponder];
    }
    UIToolbar *keyboardAccessoryView = productCell.keyboardAccessoryView;

    [self saveProducts];
    [self updateCheapestProducts];
    [self updatePricePerUnitFractionDigits];
    
    MAProductTableViewCell *activeProductCell = (MAProductTableViewCell *)[self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    textField = [activeProductCell textFieldForTag:tagForFirstResponder];
    if (textField)
    {
        [textField becomeFirstResponder];
    }
    productCell.keyboardAccessoryView = keyboardAccessoryView;
}

- (void)didEndEditingCell:(MAProductTableViewCell *)productCell
{
    //TLog(@"%@ / %@ = %@", product.price, product.quantity, [product pricePerUnit]);
    [self saveProducts];
    [self updateCheapestProducts];
    [self updatePricePerUnitFractionDigits];
    
    // Get the current active cell and dismiss the keyboard since productCell might have been invalidated.
    MAProductTableViewCell *activeProductCell = (MAProductTableViewCell *)[self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    [activeProductCell dismissKeyboard];

    self.editingIndexPath = nil;
}

#pragma mark - Fraction digits

- (void)updatePricePerUnitFractionDigits
{
    NSUInteger pricePerUnitFractionDigits = [self calculatePricePerUnitFractionDigits];
    if (pricePerUnitFractionDigits != self.pricePerUnitFractionDigits)
    {
        self.pricePerUnitFractionDigits = pricePerUnitFractionDigits;
        
        for (NSUInteger row = 0; row != self.products.count; ++row)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:PRODUCTS_SECTION];
            MAProductTableViewCell *cell = (MAProductTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
            cell.pricePerUnitFractionDigits = self.pricePerUnitFractionDigits;
        }
//        [self.tableView reloadData];
    }
}

- (NSUInteger)calculatePricePerUnitFractionDigits
{
    // Create a list of all the prices per unit.
    NSMutableArray *pricesPerUnit = [[NSMutableArray alloc] init];
    for (MAProduct *product in self.products)
    {
        NSNumber *unitPrice = [product pricePerUnit];
        [pricesPerUnit addObject:unitPrice];
    }
    
    NSInteger pricePerUnitFractionDigits = [self calculateFractionDigitsForPrices:pricesPerUnit];
    return pricePerUnitFractionDigits;
}

- (NSUInteger)calculateFractionDigitsForPrices:(NSArray *)prices
{
    // Create our own price formatter since MAProduct's formatter where actually generate the formatted label with its maximumFractionDigits property changed according to the return value of this function.
    static dispatch_once_t once;
    static NSNumberFormatter *priceFormatter = nil;
    dispatch_once(&once, ^{
        priceFormatter = [[NSNumberFormatter alloc] init];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [priceFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        
        // Ensure have a substantial length of fraction digits.
        [priceFormatter setMaximumFractionDigits:20];
        [priceFormatter setMinimumFractionDigits:2];
        
        [priceFormatter setAlwaysShowsDecimalSeparator:YES];
    });
    NSString *decimalSymbol = [priceFormatter decimalSeparator];
    
    // Create a list of all the prices per unit with only the decimal digit portions of the formatted strings.
    NSMutableArray *decimalDigitsForPrices = [[NSMutableArray alloc] init];
    for (NSNumber *price in prices)
    {
        NSString *formattedPrice = [priceFormatter stringFromNumber:price];
        
        NSArray *priceComponents = [formattedPrice componentsSeparatedByString:decimalSymbol];
        assert(priceComponents.count >= 2); // formatter should set minimum fraction digits.
        NSString *decimalDigits = [priceComponents lastObject];
//        NSLog(@"%@ -> %@", formattedPrice, decimalDigits);
        [decimalDigitsForPrices addObject:decimalDigits];
    }

    // Minimum digits to show in the fraction. Use 2 for cents.
    static NSInteger const minFractionDigits = 2;
    
    // Calculate the maximum number of leading 0s to appear in a string. For example:
    // '0123'
    // '0001' -> Max of 3 since 3 leading 0s.
    // '1230'
    NSInteger maxLeadingZeroDigits = -1;
    for (NSUInteger i = 0; i != decimalDigitsForPrices.count; ++i)
    {
        NSString *digits = [decimalDigitsForPrices objectAtIndex:i];
        for (NSInteger k = 0; k != digits.length; ++k)
        {
            unichar ch = [digits characterAtIndex:k];
            if (ch != '0')
            {
//                NSLog(@"%@: %d -> %c", digits, k, ch);
                maxLeadingZeroDigits = MAX(k, maxLeadingZeroDigits);
                break;
            }
        }
    }
//    NSLog(@"maxLeadingZeroDigits: %d", maxLeadingZeroDigits);
    
    // Calculate the maximum number of digits that are the same and differ by at least one character. For example:
    // '78902'
    // '78912' -> Max of 3 since 78902 and 78912 have first 3 digits the same and differ at digit 4.
    // '1230'
    // '1230' -> Not the max since 1230 and 1230 have no different digits (we don't really care how these get formatted as long as leading 0s appear).
    NSInteger maxDigitDifference = -1;
    for (NSUInteger i = 0; i != decimalDigitsForPrices.count; ++i)
    {
        NSString *firstDigits = [decimalDigitsForPrices objectAtIndex:i];
        if (firstDigits.length <= minFractionDigits)
        {
            continue;
        }
        
        for (NSUInteger j = i + 1; j != decimalDigitsForPrices.count; ++j)
        {
            NSString *secondDigits = [decimalDigitsForPrices objectAtIndex:j];
            if (secondDigits.length <= minFractionDigits)
            {
                continue;
            }
            
            NSInteger digitDifference = -1;
            NSUInteger const minLength = MIN(firstDigits.length, secondDigits.length);
            for (NSUInteger k = 0; k != minLength; ++k)
            {
                unichar firstChar = [firstDigits characterAtIndex:k];
                unichar secondChar = [secondDigits characterAtIndex:k];
                if (firstChar != secondChar)
                {
                    digitDifference = k;
                    break;
                }
            }
            
            if (digitDifference >= 0)
            {
                maxDigitDifference = MAX(digitDifference, maxDigitDifference);
            }
        }
    }
//    NSLog(@"maxDigitDifference: %d", maxDigitDifference);
    
    // Calculate how many fraction digits to show.
    // Note: add 1 to maxLeadingZeroDigits and maxDigitDifference since they are 0-based, and we need a count of how many digits to show.
    NSInteger priceFractionDigits = MAX(minFractionDigits, MAX(maxLeadingZeroDigits + 1, maxDigitDifference + 1));
//    NSLog(@"priceFractionDigits: %d", priceFractionDigits);
    
//    for (NSUInteger i = 0; i != prices.count; ++i)
//    {
//        NSString *digits = [prices objectAtIndex:i];
//        
//        NSInteger loc = 0;
//        NSInteger len = MIN(digits.length, pricePerUnitFractionDigits);
//        NSRange digitRange = NSMakeRange(loc, len);
//        NSString *truncatedDigits = [digits substringWithRange:digitRange];
//        NSLog(@"%@ -> %@", digits, truncatedDigits);
//    }

    return priceFractionDigits;
}

#pragma mark - Cheapest products

- (NSArray *)updateCheapestProducts
{
    if (self.products.count == 0)
    {
        return nil;
    }
    
    // Determine the lowest price per unit.
    NSMutableArray *pricesPerUnit = [[NSMutableArray alloc] init];
    for (MAProduct *product in self.products)
    {
        [pricesPerUnit addObject:[product pricePerUnit]];
    }
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [pricesPerUnit sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    NSNumber *lowestPricePerUnitNumber = [pricesPerUnit objectAtIndex:0];
    double const lowestPricePerUnit = lowestPricePerUnitNumber.doubleValue;
    
    // Generate a list of the cheapest products.
    // Also, generate a list of the index paths in the table that changed: either a product that is now the cheapest or a product that is no longer the cheapest.
    NSMutableArray *cheapestProducts = [[NSMutableArray alloc] init];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i != self.products.count; ++i)
    {
        MAProduct *product = [self.products objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:PRODUCTS_SECTION];

        double const pricePerUnit = [product pricePerUnit].doubleValue;
        BOOL const wasCheapestProduct = [self.cheapestProducts containsObject:product];
        BOOL const isCheapestProduct = pricePerUnit <= lowestPricePerUnit;

        if (isCheapestProduct)
        {
            [cheapestProducts addObject:product];
            
            if ( ! wasCheapestProduct)
            {
                [indexPaths addObject:indexPath];
            }
        }
        else // ! isNewCheapestProduct
        {
            if (wasCheapestProduct)
            {
                [indexPaths addObject:indexPath];
            }
        }
    }

    // Update the model and view.
    self.cheapestProducts = cheapestProducts;
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    return indexPaths;
    
//    for (NSUInteger row = 0; row != self.products.count; ++row)
//    {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:PRODUCTS_SECTION];
//        MAProductTableViewCell *cell = (MAProductTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
//        [self configureProductCell:cell atIndexPath:indexPath];
////        cell.pricePerUnitFractionDigits = self.pricePerUnitFractionDigits;
//    }
}

#pragma mark - Action sheet

- (void)showDeleteActionSheet
{
    NSString *buttonTitle = nil;
    if (self.products.count == 1)
    {
        buttonTitle = [NSString stringWithFormat:Localize(@"Delete Item")];
    }
    else
    {
        buttonTitle = [NSString stringWithFormat:Localize(@"Delete Items")];
    }
    
    if (self.deleteActionSheet && self.deleteActionSheet.visible)
    {
        [self.deleteActionSheet dismissWithClickedButtonIndex:[self.deleteActionSheet cancelButtonIndex] animated:NO];
    }
    
    self.deleteActionSheet = [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:Localize(@"No")
                              destructiveButtonTitle:buttonTitle
                              otherButtonTitles:nil
                              ];
    [self.deleteActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [sheet cancelButtonIndex])
    {
        return;
    }
    
    if (sheet == self.deleteActionSheet)
    {
        [self clearAllProducts];
    }
}

- (void)clearAllProducts
{
    NSUInteger const rows = self.products.count;
    self.products = [[NSMutableArray alloc] init];
    [self saveProducts];

    self.cheapestProducts = [[NSMutableArray alloc] init];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSUInteger row = 0; row != rows; ++row)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:PRODUCTS_SECTION];
        [indexPaths addObject:indexPath];
    }
    
    if (indexPaths.count != 0)
    {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self reloadClearRow];
        [self.tableView endUpdates];
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

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)sender
{
    if ( ! self.editingIndexPath)
    {
        return;
    }
    
    // Update with new product value.
    [self saveProducts];
    [self updateCheapestProducts];
    [self updatePricePerUnitFractionDigits];

    // Stop editing when user starts scrolling.
    MAProductTableViewCell *activeProductCell = (MAProductTableViewCell *)[self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    [activeProductCell dismissKeyboard];
    self.editingIndexPath = nil;
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
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    self.savedWeightGoal = textField.text;
    [self selectBillAtPath:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.billTextField)
    {
        NSNumber *number = [NSNumber numberWithDouble:[self.billTextField.text doubleValue]];
        self.bill.bill = number;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.billTextField)
    {
        BOOL const shouldChangeChars = [MAUtil numTextField:textField shouldChangeCharactersInRange:range replacementString:string];
        return shouldChangeChars;
    }
    
    return YES;
}

- (IBAction)dismissInput
{
    [self dismissKeyboard];
//    [self dismissDatePicker];
}

- (IBAction)dismissKeyboard
{
    if ([self.billTextField isFirstResponder])
    {
        [self.billTextField resignFirstResponder];
    }
}

@end
