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
#import "MAUserUtil.h"
#import "MAUtil.h"
#import "UIImage+ImageWithColor.h"

#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding, MABillDelegate>
@property (strong, nonatomic) MABill *bill;

@property (strong, nonatomic) NSDictionary *settings;

@property (strong, nonatomic) IBOutlet UIButton *billButton;
@property (strong, nonatomic) IBOutlet UIButton *tipButton;
@property (strong, nonatomic) IBOutlet UIButton *grandTotalButton;

@property (strong, nonatomic) IBOutlet UIStepper *dollarsStepper;
@property (strong, nonatomic) IBOutlet UIStepper *centsStepper;

@property (strong, nonatomic) IBOutlet UIButton *ratingButton1;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton2;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton3;

@property (strong, nonatomic) IBOutlet UILabel *billLabel;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UILabel *grandTotalLabel;
@end

@implementation TodayViewController
@synthesize bill = _bill;
@synthesize settings = _settings;

@synthesize billButton = _billButton;
@synthesize tipButton = _tipButton;
@synthesize grandTotalButton = _grandTotalButton;

@synthesize ratingButton1 = _ratingButton1;
@synthesize ratingButton2 = _ratingButton2;
@synthesize ratingButton3 = _ratingButton3;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.settings = [MAUserUtil loadSettingsFromSharedDefaults];
    [MAUserUtil sharedInstance].settings = [self.settings copy];
    [MAAppearance reloadAppearanceSettings];
    
    [self setImage:[MAFilePaths billImage] forButton:self.billButton];
    [self setImage:[MAFilePaths tipAmountImage] forButton:self.tipButton];
    [self setImage:[MAFilePaths totalImage] forButton:self.grandTotalButton];
    
    [[UIStepper appearance] setTintColor:[MAAppearance foregroundColor]];
    
    [self loadBill];
    [self setupSteppers];
    
    [self setCurrentRatingButton:self.ratingButton3];
    
    // Increase the today widget view's height.
    // Use 0 for the width; otherwise, the view resizes strangely when a button is first tapped.
    self.preferredContentSize = CGSizeMake(0., 180.);
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
        TLog(@"Failed to save bill");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)setupSteppers
{
    NSInteger dollars;
    NSInteger cents;
    [self splitDecimalNumber:self.bill.bill.doubleValue integer:&dollars fraction:&cents];

    self.dollarsStepper.value = dollars;
    self.centsStepper.value = cents;
}

- (void)setImagesForStepper:(UIStepper *)stepper isPlusButton:(BOOL)isPlusButton
{
    UIImage *clearImage = [UIImage imageWithColor:[UIColor clearColor]];
    
    if (isPlusButton)
    {
        [stepper setIncrementImage:[MAFilePaths plusImage] forState:UIControlStateNormal];
        [stepper setIncrementImage:[MAFilePaths plusImageSelected] forState:UIControlStateHighlighted];
        [stepper setIncrementImage:[MAFilePaths plusImageSelected] forState:UIControlStateSelected];
        
        [stepper setDecrementImage:clearImage forState:UIControlStateNormal];
        [stepper setDecrementImage:clearImage forState:UIControlStateHighlighted];
        [stepper setDecrementImage:clearImage forState:UIControlStateSelected];
    }
    else
    {
        [stepper setDecrementImage:[MAFilePaths minusImage] forState:UIControlStateNormal];
        [stepper setDecrementImage:[MAFilePaths minusImageSelected] forState:UIControlStateHighlighted];
        [stepper setDecrementImage:[MAFilePaths minusImageSelected] forState:UIControlStateSelected];
        
        [stepper setIncrementImage:clearImage forState:UIControlStateNormal];
        [stepper setIncrementImage:clearImage forState:UIControlStateHighlighted];
        [stepper setIncrementImage:clearImage forState:UIControlStateSelected];
    }
    
    [stepper setBackgroundImage:clearImage forState:UIControlStateNormal];
    [stepper setBackgroundImage:clearImage forState:UIControlStateHighlighted];
    [stepper setBackgroundImage:clearImage forState:UIControlStateSelected];
    [stepper setBackgroundImage:clearImage forState:UIControlStateDisabled];
    
    [stepper setDividerImage:clearImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    [stepper setDividerImage:clearImage forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateNormal];
    [stepper setDividerImage:clearImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateHighlighted];
    [stepper setDividerImage:clearImage forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateHighlighted];
    [stepper setDividerImage:clearImage forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateSelected];
    [stepper setDividerImage:clearImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected];
    [stepper setDividerImage:clearImage forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal];
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
        rating = [self.settings objectForKey:ServiceRatingFair];
        number = [NSNumber numberWithDouble:10.];
    }
    else if (currentRatingButton == self.ratingButton2)
    {
        rating = [self.settings objectForKey:ServiceRatingGood];
        number = [NSNumber numberWithDouble:15.];
    }
    else if (currentRatingButton == self.ratingButton3)
    {
        rating = [self.settings objectForKey:ServiceRatingGreat];
        number = [NSNumber numberWithDouble:20.];
    }
    
    if (rating)
    {
        number = [NSNumber numberWithDouble:[rating doubleValue]];
    }
    self.bill.tipPercent = number;
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
    self.billLabel.text = [self.bill formattedBill];
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

- (IBAction)stepperValueChanged:(id)sender
{
    NSInteger dollars = self.dollarsStepper.value;
    NSInteger cents = self.centsStepper.value;
    
    CGFloat centsFloat = (CGFloat)cents / 100.;
    CGFloat bill = (CGFloat)dollars + centsFloat;
    self.bill.bill = [NSNumber numberWithDouble:bill];
    [self saveBill];
}

@end
