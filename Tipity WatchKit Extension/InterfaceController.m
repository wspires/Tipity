//
//  InterfaceController.m
//  Tipity WatchKit Extension
//
//  Created by Wade Spires on 11/19/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "InterfaceController.h"

#import "MAAppearance.h"
#import "MASharedDataChangedNotifier.h"
#import "MAAppGroup.h"
#import "MABill.h"
//#import "MAFilePaths.h"
#import "MAUserUtil.h"
//#import "MAUtil.h"
//#import "UIImage+ImageWithColor.h"

#include <CoreFoundation/CoreFoundation.h>

// Must also set the steps for the slider in the storyboard. Cannot do programmatically yet.
static CGFloat const DollarSliderMax = 200.;

@interface InterfaceController() <MABillDelegate>
@property (strong, nonatomic) MABill *bill;
@property (strong, nonatomic) NSDictionary *settings;

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


@property (weak, nonatomic) IBOutlet WKInterfaceSlider *dollarSlider;
@property (strong, nonatomic) NSNumber *dollars;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *centSlider;
@property (strong, nonatomic) NSNumber *cents;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *billGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *billImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *billLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *tipLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *grandTotalLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *openButton;
@end

@implementation InterfaceController
@synthesize bill = _bill;
@synthesize settings = _settings;

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

@synthesize dollarSlider = _dollarSlider;
@synthesize dollars = _dollars;
@synthesize centSlider = _centSlider;
@synthesize cents = _cents;
@synthesize billImage = _billImage;
@synthesize billLabel = _billLabel;
@synthesize tipLabel = _tipLabel;
@synthesize grandTotalLabel = _grandTotalLabel;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ initWithContext", self);
        
        self.settings = [MAUserUtil loadSettingsFromSharedDefaults];
        [MAUserUtil sharedInstance].settings = [self.settings copy];
        [MAAppearance reloadAppearanceSettings];
        
//        [self setImage:[MAFilePaths billImage] forButton:self.billButton];
//        [self setImage:[MAFilePaths tipAmountImage] forButton:self.tipButton];
//        [self setImage:[MAFilePaths totalImage] forButton:self.grandTotalButton];
        
//        [[UIStepper appearance] setTintColor:[MAAppearance foregroundColor]];
        
        [self loadBill];
        
        [self setDigitButtonsWithBill];
        [self initSelectedButton];
        
        // TODO: Would be better to not use sliders to select the $ and cents. However, there is no API for accessing the digital crown.
        
        [self setupSliders];
        
        //[self.billImage setImageNamed:@"BillImage"];
//        [self setCurrentRatingButton:self.ratingButton3];
        
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
        
        [self registerForSharedDataChangedNotifications];
    }
    return self;
}

-(void)userDefaultsChanged:(NSNotification *)notification
{
    NSLog(@"userDefaultsChanged");
    return;
    
    MABill *bill = [MABill reloadSharedInstance:YES];
    if ( ! [bill isEqual:self.bill])
    {
        NSLog(@"Bill changed");
        self.bill = [MABill sharedInstance];
    }
    bill.delegate = self;
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
    
    [self.dollarSlider setHidden:YES];
    [self.billImage setHidden:YES];
    [self.centSlider setHidden:YES];
    [self.billLabel setHidden:YES];
    [self.billGroup setHidden:YES];
    
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
    self.bill = [MABill sharedInstance];
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
    [MASharedDataChangedNotifier postNotification];
}

- (void)updateLabels
{
    self.billLabel.text = [self.bill formattedBill];
    self.tipLabel.text = [self.bill formattedTip];
    self.grandTotalLabel.text = [self.bill formattedTotal];
}

- (void)setupSliders
{
    NSInteger dollars;
    NSInteger cents;
    [self splitDecimalNumber:self.bill.bill.doubleValue integer:&dollars fraction:&cents];
    
    self.dollars = [NSNumber numberWithInteger:dollars];
    self.cents = [NSNumber numberWithInteger:cents];

    self.dollarSlider.value = self.dollars.integerValue / DollarSliderMax;
    self.centSlider.value = self.cents.integerValue / 100.;

    NSLog(@"Initial bill values: dollars=%@, cents=%@", self.dollars, self.cents);
    
    UIColor *color = [MAAppearance foregroundColor];
    [self.dollarSlider setColor:color];
    [self.centSlider setColor:color];
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

- (IBAction)dollarSliderAction:(float)value
{
    NSInteger dollars = (NSInteger) roundf(DollarSliderMax * value);
    self.dollars = [NSNumber numberWithInteger:dollars];
    [self newDollarsValue:self.dollars centsValue:self.cents];

    NSLog(@"Dollar slider value is now: %f (%@)", value, self.dollars);
}

- (IBAction)centSliderAction:(float)value
{
    // Wrap around the slider value if necessary.
    static float const sliderMin = 0.;
    static float const centsMin = 100 * sliderMin;
    static float const sliderMax = .99;
    static float const centsMax = 100 * sliderMax;
    if (self.cents.integerValue == centsMax && value >= sliderMax)
    {
        value = sliderMin;
        self.centSlider.value = value;
    }
    else if (self.cents.integerValue == centsMin && value <= sliderMin)
    {
        value = sliderMax;
        self.centSlider.value = value;
    }

    NSInteger cents = (NSInteger) roundf(100 * value);
    if (cents >= centsMax)
    {
        cents = centsMax;
    }
    self.cents = [NSNumber numberWithInteger:cents];
    [self newDollarsValue:self.dollars centsValue:self.cents];
    
    NSLog(@"Cent slider value is now: %f (%@)", value, self.cents);
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
    [[MASharedDataChangedNotifier sharedInstance] registerForSharedDataChangedNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharedDataChanged:) name:MASharedDataChangedNotification object:nil];
}

- (void)unregisterForSharedDataChangedNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MASharedDataChangedNotification object:nil];
}

- (void)sharedDataChanged:(NSNotification *)notification
{
    self.bill = [MABill reloadSharedInstance:YES];
    self.bill.delegate = self;
    
    [self setDigitButtonsWithBill];
    [self setupSliders];
    [self updateLabels];
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
    [self saveBill];
}

#pragma mark - Menu items

- (void)configureMenuItems
{
    [self clearAllMenuItems];
    
    NSString *title = [NSString stringWithFormat:@"Fair"];
    [self addMenuItemWithImageNamed:@"FairServiceRatingImage" title:title action:@selector(doMenuItemAction1)];

    title = [NSString stringWithFormat:@"Good"];
    [self addMenuItemWithImageNamed:@"GoodServiceRatingImage" title:title action:@selector(doMenuItemAction2)];
    
    title = [NSString stringWithFormat:@"Great"];
    [self addMenuItemWithImageNamed:@"GreatServiceRatingImage" title:title action:@selector(doMenuItemAction3)];
}

- (void)doMenuItemAction1
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingFair];
    self.bill.tipPercent = tipPercent;
    [self saveBill];
}

- (void)doMenuItemAction2
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingGood];
    self.bill.tipPercent = tipPercent;
    [self saveBill];
}

- (void)doMenuItemAction3
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingGreat];
    self.bill.tipPercent = tipPercent;
    [self saveBill];
}

@end
