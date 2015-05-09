//
//  InterfaceController.m
//  Tipity WatchKit Extension
//
//  Created by Wade Spires on 11/19/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "InterfaceController.h"

#import "MAAppearance.h"
#import "MAAppGroupNotifier.h"
#import "MAAppGroup.h"
#import "MABill.h"
#import "MAKeyboardController.h"
#import "MARatingTableViewCell.h"
#import "MARounder.h"
#import "MAUserUtil.h"

#include <CoreFoundation/CoreFoundation.h>

// Whether to display the group for changing the tip amount via individual digit buttons and +/-.
static BOOL const hideBillButtonGroup = YES;

@interface InterfaceController() <MABillDelegate>
@property (strong, nonatomic) MABill *bill;
@property (strong, nonatomic) NSDictionary *settings;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *billButtonGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *hundredsButton;
@property (strong, nonatomic) NSNumber *hundredsNumber;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *teensButton;
@property (strong, nonatomic) NSNumber *teensNumber;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *onesButton;
@property (strong, nonatomic) NSNumber *onesNumber;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *tenthsButton;
@property (strong, nonatomic) NSNumber *tenthsNumber;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *hundredthsButton;
@property (strong, nonatomic) NSNumber *hundredthsNumber;

@property (weak, nonatomic) WKInterfaceButton *selectedButton;
@property (weak, nonatomic) NSNumber *selectedNumber;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *plusButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *minusButton;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *billGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *billImage;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *billButton;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *tipLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *grandTotalLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *openButton;

@property (strong, nonatomic) NSMutableDictionary *billKeyboardDict;
@end

@implementation InterfaceController
@synthesize bill = _bill;

@synthesize billButtonGroup = _billButtonGroup;
@synthesize hundredsButton = _hundredsButton;
@synthesize hundredsNumber = _hundredsNumber;
@synthesize teensButton = _teensButton;
@synthesize teensNumber = _teensNumber;
@synthesize onesButton = _onesButton;
@synthesize onesNumber = _onesNumber;
@synthesize tenthsButton = _tenthsButton;
@synthesize tenthsNumber = _tenthsNumber;
@synthesize hundredthsButton = _hundredthsButton;
@synthesize hundredthsNumber = _hundredthsNumber;

@synthesize selectedButton = _selectedButton;
@synthesize selectedNumber = _selectedNumber;

@synthesize billImage = _billImage;
@synthesize tipLabel = _tipLabel;
@synthesize grandTotalLabel = _grandTotalLabel;

@synthesize billKeyboardDict = _billKeyboardDict;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ initWithContext", self);
        
        [self loadSettings];
        [MAAppearance reloadAppearanceSettings];
        
//        [self setImage:[MAFilePaths billImage] forButton:self.billButton];
//        [self setImage:[MAFilePaths tipAmountImage] forButton:self.tipButton];
//        [self setImage:[MAFilePaths totalImage] forButton:self.grandTotalButton];
        
//        [[UIStepper appearance] setTintColor:[MAAppearance foregroundColor]];
        
        [self loadBill];
        
        [self setDigitButtonsWithBill];
        [self initSelectedButton];
        
        //[self.billImage setImageNamed:@"BillImage"];
//        [self setCurrentRatingButton:self.ratingButton3];
        
        [self registerForSharedDataChangedNotifications];
    }
    return self;
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
    
    [self.billGroup setHidden: ! hideBillButtonGroup];
    [self.billButtonGroup setHidden:hideBillButtonGroup];

    [self loadBillFromKeyboard];
    [self updateLabels];

    [self configureMenuItems];

//    [self hideUIForLaunchImages];
    
//    MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
//    if (myDelegate.todayViewBill)
//    {
//        self.bill.bill = myDelegate.todayViewBill.bill;
//        self.bill.tipPercent = myDelegate.todayViewBill.tipPercent;
//        myDelegate.todayViewBill = nil;
//    }
}

- (void)hideUIForLaunchImages
{
    [self.hundredsButton setTitle:@""];
    [self.teensButton setTitle:@""];
    [self.onesButton setTitle:@""];
    [self.tenthsButton setTitle:@""];
    [self.hundredthsButton setTitle:@""];
    [self.tipLabel setText:@""];
    [self.grandTotalLabel setText:@""];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
}

- (void)loadBill
{
    self.bill = [MABill reloadSharedInstance:YES];
    self.bill.delegate = self;
    
    if ( ! [[MAUserUtil sharedInstance] enableTax])
    {
        [self.bill clearTax];
    }
}

- (void)saveBill
{
    BOOL saved = [MABill saveSharedInstance];
    if ( ! saved)
    {
        NSLog(@"Failed to save bill");
    }
    [MAAppGroupNotifier postNotificationForKey:@"bill"];
}

- (void)loadBillFromKeyboard
{
    if ( ! self.billKeyboardDict)
    {
        return;
    }
    
    NSString *billStr = [self.billKeyboardDict objectForKey:[MAKeyboardController keyboardValueKey]];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterCurrencyStyle;
    NSNumber *bill = [f numberFromString:billStr];
    if (bill)
    {
        self.bill.bill = bill;
        [MARounder roundGrandTotalInBill:self.bill];
        [self saveBill];
    }

    self.billKeyboardDict = nil;
    
    [self setDigitButtonsWithBill];
}

- (void)updateLabels
{
    [self.billButton setTitle:[self.bill formattedBill]];
    self.tipLabel.text = [self.bill formattedTip];
    self.grandTotalLabel.text = [self.bill formattedTotal];
}

#pragma mark - MABillDelegate

- (void)willUpdateBill:(MABill *)bill
{
}

- (void)didUpdateBill:(MABill *)bill
{
    [self updateLabels];
}

- (void)errorUpdatingBill:(MABill *)bill
{
}

- (void)newDollarsValue:(NSNumber *)dollarsNumber centsValue:(NSNumber *)centsNumber
{
    NSInteger dollars = dollarsNumber.integerValue;
    NSInteger cents = centsNumber.integerValue;
    
    CGFloat centsFloat = (CGFloat)cents / 100.;
    CGFloat bill = (CGFloat)dollars + centsFloat;
    self.bill.bill = [NSNumber numberWithDouble:bill];
    [self saveBill];
}

- (void)splitDecimalNumber:(CGFloat)number integer:(NSInteger *)integer fraction:(NSInteger *)fraction
{
    *integer = (NSInteger)number;
    *fraction = (NSInteger)roundf(100 * (number - *integer)); // Multiply by 100 to convert to cents.
}

- (CGFloat)decimalNumberFromInteger:(NSInteger)integer fraction:(NSInteger)fraction
{
    CGFloat fractionFloat = (CGFloat)fraction / 100.;
    CGFloat decimal = (CGFloat)integer + fractionFloat;
    return decimal;
}

- (IBAction)openButtonTapped:(id)sender
{
    [self openHostApp];
}

- (void)openHostApp
{
    NSData *encodedBill = [NSKeyedArchiver archivedDataWithRootObject:self.bill];
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:encodedBill forKey:@"bill"];
    

    BOOL const wasSent = [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
        NSData *encodedBill = [replyInfo objectForKey:@"bill"];
        if (encodedBill)
        {
            MABill *bill = [NSKeyedUnarchiver unarchiveObjectWithData:encodedBill];
            NSLog(@"Reply from openParentApplication: %@", bill.bill);
        }
        else
        {
            NSLog(@"Reply from openParentApplication: No bill");
        }
    }];
    NSLog(@"openParentApplication: %d", wasSent);

//    NSString *type = @"com.mindsaspire.Tip.bill";

    
//    [self updateUserActivity:type userInfo:userInfo];
//    NSLog(@"openHostApp");
    
    // Apple Watch does not have an extension context.
//    NSString *urlString = SFmt(@"Tipity://bill=%f;tipPercent=%f", self.bill.bill.doubleValue, self.bill.tipPercent.doubleValue);
//    NSURL *url = [NSURL URLWithString:urlString];
//    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
//        NSString *text = nil;
//        if (success == YES)
//        {
//            text = @"YES";
//        }
//        else
//        {
//            text = @"NO";
//        }
//        DLog(@"openHostApp: %@", text);
//    }];
}

#pragma mark - Shared Data Changed

- (void)registerForSharedDataChangedNotifications
{
    [[MAAppGroupNotifier sharedInstance] addObserver:self selector:@selector(billChanged:) key:[MABill sharedContainerKey]];
    [[MAAppGroupNotifier sharedInstance] addObserver:self selector:@selector(settingsChanged:) key:[MAUserUtil sharedContainerKey]];
}

- (void)unregisterForSharedDataChangedNotifications
{
    [[MAAppGroupNotifier sharedInstance] removeObserver:self key:[MABill sharedContainerKey]];
    [[MAAppGroupNotifier sharedInstance] removeObserver:self key:[MAUserUtil sharedContainerKey]];
}

- (void)billChanged:(NSNotification *)notification
{
    self.bill = [MABill reloadSharedInstance:YES];
    self.bill.delegate = self;
    
    [self setDigitButtonsWithBill];
    [self updateLabels];
}

- (void)settingsChanged:(NSNotification *)settingsChanged
{
    [self loadSettings];
}

- (void)loadSettings
{
    [MAUserUtil reloadSharedInstance:YES];
}

#pragma mark - Bill digit buttons

- (UIColor *)unselectedColor
{
    return [UIColor darkGrayColor];
}

- (UIColor *)selectedColor
{
    return [MAAppearance foregroundColor];
}

- (void)setDigitButtonsWithBill
{
    [self numberToDigitButtons:self.bill.bill];
}

- (void)initSelectedButton
{
    [self.hundredsButton setBackgroundColor:[self unselectedColor]];
    [self.teensButton setBackgroundColor:[self unselectedColor]];
    [self.onesButton setBackgroundColor:[self unselectedColor]];
    [self.tenthsButton setBackgroundColor:[self unselectedColor]];
    [self.hundredthsButton setBackgroundColor:[self unselectedColor]];

    [self selectButton:self.onesButton];
}

- (IBAction)hundredsButtonTapped:(id)sender
{
    [self selectButton:self.hundredsButton];
}
- (IBAction)teensButtonTapped:(id)sender
{
    [self selectButton:self.teensButton];
}
- (IBAction)onesButtonTapped:(id)sender
{
    [self selectButton:self.onesButton];
}
- (IBAction)tenthsButtonTapped:(id)sender
{
    [self selectButton:self.tenthsButton];
}
- (IBAction)hundredthsButtonTapped:(id)sender
{
    [self selectButton:self.hundredthsButton];
}

- (void)selectButton:(WKInterfaceButton *)button
{
    if (self.selectedButton)
    {
        [self.selectedButton setBackgroundColor:[self unselectedColor]];
    }
    
    self.selectedButton = button;
    [self.selectedButton setBackgroundColor:[self selectedColor]];
    
    self.selectedNumber = [self numberForButton:self.selectedButton];
}

- (NSNumber *)numberForButton:(WKInterfaceButton *)button
{
    if (button == self.hundredsButton)
    {
        return self.hundredsNumber;
    }
    else if (button == self.teensButton)
    {
        return self.teensNumber;
    }
    else if (button == self.onesButton)
    {
        return self.onesNumber;
    }
    else if (button == self.tenthsButton)
    {
        return self.tenthsNumber;
    }
    else if (button == self.hundredthsButton)
    {
        return self.hundredthsNumber;
    }
 
    return nil;
}

- (NSNumber *)digitButtonsToNumber
{
    double value = 0;
    value += 100 * self.hundredsNumber.intValue;
    value += 10 * self.teensNumber.intValue;
    value += 1 * self.onesNumber.intValue;
    value += 1 / 10. * self.tenthsNumber.intValue;
    value += 1 / 100. * self.hundredthsNumber.intValue;
    NSNumber *number = [NSNumber numberWithDouble:value];
    return number;
}

- (void)numberToDigitButtons:(NSNumber *)number
{
    double value = number.doubleValue;
    int intPart = (int)value;
    int fracPart = (int)(100 * (value - intPart)); // Fraction part: x100 because we only want cents.
    
    self.hundredsNumber = [NSNumber numberWithInt:[self digit:2 integer:intPart]];
    NSLog(@"%d %@", [self digit:2 integer:intPart], self.hundredsNumber);
    self.teensNumber = [NSNumber numberWithInt:[self digit:1 integer:intPart]];
    self.onesNumber = [NSNumber numberWithInt:[self digit:0 integer:intPart]];
    self.tenthsNumber = [NSNumber numberWithInt:[self digit:1 integer:fracPart]];
    self.hundredthsNumber = [NSNumber numberWithInt:[self digit:0 integer:fracPart]];
    
    [self setTitleForDigitButton:self.hundredsButton number:self.hundredsNumber];
    [self setTitleForDigitButton:self.teensButton number:self.teensNumber];
    [self setTitleForDigitButton:self.onesButton number:self.onesNumber];
    [self setTitleForDigitButton:self.tenthsButton number:self.tenthsNumber];
    [self setTitleForDigitButton:self.hundredthsButton number:self.hundredthsNumber];
}

- (int)digit:(int)digit integer:(int)integer
{
    double p = pow(10, digit);
    int i = (int)(integer / p);
    int d = i % 10;
    return d;
}

- (void)setTitleForDigitButton:(WKInterfaceButton *)button number:(NSNumber *)number
{
    [button setTitle:[MABill formatCount:number]];
}

- (IBAction)plusButtonTapped:(id)sender
{
    [self incrementSelectButtonWithValue:+1];
}

- (IBAction)minusButtonTapped:(id)sender
{
    [self incrementSelectButtonWithValue:-1];
}

- (void)incrementSelectButtonWithValue:(int)incrementValue
{
    // The new value must be a single digit [0,9], so wraparound if go passed either end.
    int value = self.selectedNumber.intValue;
    int newValue = value + incrementValue;
    if (newValue < 0)
    {
        newValue = 9;
    }
    else if (newValue > 9)
    {
        newValue = 0;
    }
    
    self.selectedNumber = [NSNumber numberWithInt:newValue];
    [self updateNumber:self.selectedNumber forButton:self.selectedButton];
    [self setTitleForDigitButton:self.selectedButton number:self.selectedNumber];
    [self updateBill];
}

// Use this function to reassign the number that is paired with the given button.
// Must use this when changing the self.selectedNumber since NSNumber is immutable.
- (void)updateNumber:(NSNumber *)number forButton:(WKInterfaceButton *)button
{
    if (button == self.hundredsButton)
    {
        self.hundredsNumber = number;
    }
    else if (button == self.teensButton)
    {
        self.teensNumber = number;
    }
    else if (button == self.onesButton)
    {
        self.onesNumber = number;
    }
    else if (button == self.tenthsButton)
    {
        self.tenthsNumber = number;
    }
    else if (button == self.hundredthsButton)
    {
        self.hundredthsNumber = number;
    }
}

- (void)updateBill
{
    NSNumber *bill = [self digitButtonsToNumber];
    self.bill.bill = bill;
    [MARounder roundGrandTotalInBill:self.bill];
    [self saveBill];
}

#pragma mark - Menu items

- (void)configureMenuItems
{
    [self clearAllMenuItems];

    NSString *title = nil;

    if ( ! hideBillButtonGroup)
    {
        //    title = [NSString stringWithFormat:@"Enter Bill"];
        //    title = [NSString stringWithFormat:@"Keyboard"];
        //    title = [NSString stringWithFormat:@"Check Total"];
        title = [NSString stringWithFormat:@"Enter Total"];
        //    title = [NSString stringWithFormat:@"Type Total"];
        [self addMenuItemWithImageNamed:@"KeyboardImage" title:title action:@selector(doMenuItemAction1)];
        //    [self addMenuItemWithImageNamed:@"BillImage" title:title action:@selector(doMenuItemAction1)];
    }

    title = [NSString stringWithFormat:@"Fair"];
    [self addMenuItemWithImageNamed:@"FairServiceRatingImage" title:title action:@selector(doMenuItemAction2)];

    title = [NSString stringWithFormat:@"Good"];
    [self addMenuItemWithImageNamed:@"GoodServiceRatingImage" title:title action:@selector(doMenuItemAction3)];
    
    title = [NSString stringWithFormat:@"Great"];
    [self addMenuItemWithImageNamed:@"GreatServiceRatingImage" title:title action:@selector(doMenuItemAction4)];
}

- (void)doMenuItemAction1
{
    [self showBillKeyboard];
}

- (void)doMenuItemAction2
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingFair];
    [self setTipPercent:tipPercent];
}

- (void)doMenuItemAction3
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingGood];
    [self setTipPercent:tipPercent];
}

- (void)doMenuItemAction4
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingGreat];
    [self setTipPercent:tipPercent];
}

- (void)setTipPercent:(NSNumber *)tipPercent
{
    self.bill.tipPercent = tipPercent;

    // ratingInt is the ID of the service rating, like 1, 2, 3, 4, 5, while the other "rating" variable is the actual tip percent. Needed to handle rounding.
    NSUInteger const rating = [MARatingTableViewCell ratingForTipPercent:tipPercent];
    NSString *ratingString = [NSString stringWithFormat:@"%d", (int)rating];
    [[MAUserUtil sharedInstance] saveSetting:ratingString forKey:LastSelectedServiceRating];
    
    [MARounder roundGrandTotalInBill:self.bill];

    [self saveBill];
}

- (IBAction)billButtonTapped:(id)sender
{
    [self showBillKeyboard];
}

- (void)showBillKeyboard
{
    self.billKeyboardDict = [[NSMutableDictionary alloc] init];
    
    NSString *unit = @""; // No unit.

    // Start with an empty bill to make easier to enter.
    NSNumberFormatter *formatter = [MABill priceFormatter];
    NSString *billStr = [formatter currencySymbol];
//    NSString *billStr = [MABill formatBill:self.bill.bill];
    
    [self.billKeyboardDict setObject:billStr forKey:[MAKeyboardController keyboardValueKey]];
    [self.billKeyboardDict setObject:unit forKey:[MAKeyboardController unitKey]];
    
    [self presentControllerWithName:@"MAKeyboardController" context:self.billKeyboardDict];
}

@end
