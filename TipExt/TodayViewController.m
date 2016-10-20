//
//  TodayViewController.m
//  TipExt
//
//  Created by Wade Spires on 11/2/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "TodayViewController.h"

#import "MAAppearance.h"
#import "MAAppGroup.h"
#import "MABill.h"
#import "MAFilePaths.h"
#import "MARatingTableViewCell.h"
#import "MARounder.h"
#import "MATipPercentForRating.h"
#import "MAUserUtil.h"
#import "MAUtil.h"
#import "UIImage+ImageWithColor.h"

#import <NotificationCenter/NotificationCenter.h>
#import <QuartzCore/QuartzCore.h>

// Height of widget.
// Ideally, 2.5 table rows (2.5 * 44)
// https://developer.apple.com/ios/human-interface-guidelines/extensions/widgets/
static CGFloat const Height = 110.;

@interface TodayViewController () <NCWidgetProviding, MABillDelegate>
@property (strong, nonatomic) MABill *bill;

@property (weak, nonatomic) IBOutlet UIButton *hundredsButton;
@property (strong, nonatomic) NSNumber *hundredsNumber;
@property (weak, nonatomic) IBOutlet UIButton *teensButton;
@property (strong, nonatomic) NSNumber *teensNumber;
@property (weak, nonatomic) IBOutlet UIButton *onesButton;
@property (strong, nonatomic) NSNumber *onesNumber;
@property (weak, nonatomic) IBOutlet UIButton *tenthsButton;
@property (strong, nonatomic) NSNumber *tenthsNumber;
@property (weak, nonatomic) IBOutlet UIButton *hundredthsButton;
@property (strong, nonatomic) NSNumber *hundredthsNumber;

@property (weak, nonatomic) UIButton *selectedButton;
@property (weak, nonatomic) NSNumber *selectedNumber;

@property (strong, nonatomic) IBOutlet UIView *billView;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;

@property (strong, nonatomic) IBOutlet UIButton *billButton;
@property (strong, nonatomic) IBOutlet UIButton *tipButton;
@property (strong, nonatomic) IBOutlet UIButton *grandTotalButton;

@property (strong, nonatomic) IBOutlet UIView *ratingView;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton1;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton2;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton3;

@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UILabel *grandTotalLabel;
@end

@implementation TodayViewController
@synthesize bill = _bill;

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

@synthesize billView = _billView;
@synthesize selectedButton = _selectedButton;
@synthesize selectedNumber = _selectedNumber;

@synthesize billButton = _billButton;
@synthesize tipButton = _tipButton;
@synthesize grandTotalButton = _grandTotalButton;

@synthesize ratingView = _ratingView;
@synthesize ratingButton1 = _ratingButton1;
@synthesize ratingButton2 = _ratingButton2;
@synthesize ratingButton3 = _ratingButton3;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadSettings];
    [MAAppearance reloadAppearanceSettings];
    
    [self setImage:[MAFilePaths billImage] forButton:self.billButton];
    [self setImage:[MAFilePaths tipAmountImage] forButton:self.tipButton];
    [self setImage:[MAFilePaths totalImage] forButton:self.grandTotalButton];
    
    [[UIStepper appearance] setTintColor:[MAAppearance foregroundColor]];
    
    [self loadBill];
    
    [self setDigitButtonsWithBill];
    [self initSelectedButton];
    
    [self setCurrentRatingButton:self.ratingButton3];
    
    // Increase the today widget view's height.
    // Use 0 for the width; otherwise, the view resizes strangely when a button is first tapped.
    self.preferredContentSize = CGSizeMake(0., Height);
    
    // Can modify height by playing around with this on iOS 10 and also implementing widgetActiveDisplayModeDidChange
//    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
//    CGSize maxExpandedSize = [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeExpanded];
//    CGSize maxCompactSize = [self.extensionContext widgetMaximumSizeForDisplayMode:NCWidgetDisplayModeCompact];
//    LOG_S(@"maxExpandedSize: %f x %f", maxExpandedSize.width, maxExpandedSize.height);
//    LOG_S(@"maxCompactSize: %f x %f", maxCompactSize.width, maxCompactSize.height);
//    self.ratingView.hidden = YES;
}

- (void)loadSettings
{
    [MAUserUtil reloadSharedInstance:YES];
}

- (void)loadBill
{
    self.bill = [MABill reloadSharedInstance:YES];
//    self.bill = [MABill sharedInstance];
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
        TLog(@"Failed to save bill");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSelectedButton
{
    [self.hundredsButton setBackgroundColor:[self unselectedColor]];
    [self.teensButton setBackgroundColor:[self unselectedColor]];
    [self.onesButton setBackgroundColor:[self unselectedColor]];
    [self.tenthsButton setBackgroundColor:[self unselectedColor]];
    [self.hundredthsButton setBackgroundColor:[self unselectedColor]];
    
    CGFloat const cornerRadius = 6;
    self.hundredsButton.layer.cornerRadius = cornerRadius;
    self.hundredsButton.clipsToBounds = YES;
    self.teensButton.layer.cornerRadius = cornerRadius;
    self.teensButton.clipsToBounds = YES;
    self.onesButton.layer.cornerRadius = cornerRadius;
    self.onesButton.clipsToBounds = YES;
    self.tenthsButton.layer.cornerRadius = cornerRadius;
    self.tenthsButton.clipsToBounds = YES;
    self.hundredthsButton.layer.cornerRadius = cornerRadius;
    self.hundredthsButton.clipsToBounds = YES;

    [self selectButton:self.onesButton];
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

- (void)selectButton:(UIButton *)button
{
    if (self.selectedButton)
    {
        [self.selectedButton setBackgroundColor:[self unselectedColor]];
    }
    
    self.selectedButton = button;
    [self.selectedButton setBackgroundColor:[self selectedColor]];
    
    self.selectedNumber = [self numberForButton:self.selectedButton];
}

- (NSNumber *)numberForButton:(UIButton *)button
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

- (void)setTitleForDigitButton:(UIButton *)button number:(NSNumber *)number
{
    NSString *title = [MABill formatCount:number];
//    button.titleLabel.text = [MABill formatCount:number];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateApplication];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateReserved];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateDisabled];

//    [button setTitle:[MABill formatCount:number]];
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
- (void)updateNumber:(NSNumber *)number forButton:(UIButton *)button
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

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
//    return UIEdgeInsetsZero;
//    CGFloat const inset = 16.;
    CGFloat const inset = 10.;
    return UIEdgeInsetsMake(inset, inset, inset, inset);
}

- (IBAction)ratingButtonTapped:(id)sender
{
    [self setCurrentRatingButton:(UIButton *)sender];
}

- (void)setCurrentRatingButton:(UIButton *)currentRatingButton
{
    [self setImagesForRatingButtons:currentRatingButton];
    [self setTipForRatingButton:currentRatingButton];
}

- (void)setImagesForRatingButtons:(UIButton *)currentRatingButton
{
    UIImage *filledStarImage = [MAFilePaths filledStarImage];
    [self setImage:filledStarImage forButton:self.ratingButton1];
    [self setImage:filledStarImage forButton:self.ratingButton2];
    [self setImage:filledStarImage forButton:self.ratingButton3];

    UIImage *emptyStarImage = [MAFilePaths emptyStarImage];
    if (currentRatingButton == self.ratingButton1)
    {
        [self setImage:emptyStarImage forButton:self.ratingButton2];
        [self setImage:emptyStarImage forButton:self.ratingButton3];
    }
    else if (currentRatingButton == self.ratingButton2)
    {
        [self setImage:emptyStarImage forButton:self.ratingButton3];
    }
    else if (currentRatingButton == self.ratingButton3)
    {
    }
}

- (void)setImage:(UIImage *)image forButton:(UIButton *)button
{
    [button setImage:image forState:UIControlStateHighlighted];
    [button setImage:image forState:UIControlStateSelected];
    [button setImage:image forState:UIControlStateNormal];
}

- (void)setPlusImageForButton:(UIButton *)button
{
    [button setImage:[MAFilePaths plusImageSelected] forState:UIControlStateHighlighted];
    [button setImage:[MAFilePaths plusImageSelected] forState:UIControlStateSelected];
    [button setImage:[MAFilePaths plusImage] forState:UIControlStateNormal];
}

- (void)setMinusImageForButton:(UIButton *)button
{
    [button setImage:[MAFilePaths minusImageSelected] forState:UIControlStateHighlighted];
    [button setImage:[MAFilePaths minusImageSelected] forState:UIControlStateSelected];
    [button setImage:[MAFilePaths minusImage] forState:UIControlStateNormal];
}

- (void)setTipForRatingButton:(UIButton *)currentRatingButton
{
    // Get service rating tip % based on the button tapped and the current settings.
    // Use a default tip % just in case the rating in the settings is not set.
    NSNumber *number = nil;
    NSString *rating = nil;
    if (currentRatingButton == self.ratingButton1)
    {
        rating = [[MAUserUtil sharedInstance] objectForKey:ServiceRatingFair];
        number = [NSNumber numberWithDouble:10.];
    }
    else if (currentRatingButton == self.ratingButton2)
    {
        rating = [[MAUserUtil sharedInstance] objectForKey:ServiceRatingGood];
        number = [NSNumber numberWithDouble:15.];
    }
    else if (currentRatingButton == self.ratingButton3)
    {
        rating = [[MAUserUtil sharedInstance] objectForKey:ServiceRatingGreat];
        number = [NSNumber numberWithDouble:20.];
    }
    
    if (rating)
    {
        number = [NSNumber numberWithDouble:[rating doubleValue]];
    }
    
    self.bill.tipPercent = number;
    
    // ratingInt is the ID of the service rating, like 1, 2, 3, 4, 5, while the other "rating" variable is the actual tip percent. Needed to handle rounding.
    NSUInteger const ratingInt = [MATipPercentForRating ratingForTipPercent:number];
    NSString *ratingString = SFmt(@"%d", (int)ratingInt);
    [[MAUserUtil sharedInstance] saveSetting:ratingString forKey:LastSelectedServiceRating];

    [MARounder roundGrandTotalInBill:self.bill];
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

- (void)updateLabels
{
    self.tipLabel.text = [self.bill formattedTip];
    self.grandTotalLabel.text = [self.bill formattedTotal];
}

// Split a formatted price string like "$19.99" into an array of strings composed of just the dollars and cents, @[@"19", @"99"].
- (NSArray *)dollarsAndCentsFromFormattedPrice:(NSString *)formattedPrice
{
    NSMutableArray *dollarsAndCents = [[NSMutableArray alloc] init];
    
    NSNumberFormatter *priceFormatter = [MABill priceFormatter];
    NSString *billSeparator = priceFormatter.decimalSeparator;
    NSArray *billComponents = [formattedPrice componentsSeparatedByString:billSeparator];
    
    NSString *billDollars = @"0";
    if (billComponents.count >= 1)
    {
        billDollars = [billComponents objectAtIndex:0];
    }
    [dollarsAndCents addObject:billDollars];
    
    NSString *billCents = @"00";
    if (billComponents.count >= 2)
    {
        billCents = [billComponents objectAtIndex:1];
    }
    billCents = [NSString stringWithFormat:@"%@%@", billSeparator, billCents];
    [dollarsAndCents addObject:billCents];
    
    return dollarsAndCents;
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
    NSString *urlString = SFmt(@"Tipity://bill=%f;tipPercent=%f", self.bill.bill.doubleValue, self.bill.tipPercent.doubleValue);
    NSURL *url = [NSURL URLWithString:urlString];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        NSString *text = nil;
        if (success == YES)
        {
            text = @"YES";
        }
        else
        {
            text = @"NO";
        }
        DLog(@"openHostApp: %@", text);
    }];
}

/*
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
{
    if (activeDisplayMode == NCWidgetDisplayModeExpanded)
    {
        self.preferredContentSize = CGSizeMake(0.0, Height);
    }
    else if (activeDisplayMode == NCWidgetDisplayModeCompact)
    {
        self.preferredContentSize = maxSize;
    }
}
*/

@end
