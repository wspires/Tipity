//
//  TodayViewController.m
//  TipExt
//
//  Created by Wade Spires on 11/2/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "TodayViewController.h"

#import "MABill.h"
#import "MAFilePaths.h"
#import "MAUtil.h"
#import "UIImage+ImageWithColor.h"

#import <NotificationCenter/NotificationCenter.h>

static NSString *MATextFieldCellIdentifier = @"MATextFieldCellIdentifier";

@interface TodayViewController () <NCWidgetProviding, MABillDelegate>
@property (strong, nonatomic) MABill *bill;

@property (strong, nonatomic) IBOutlet UIButton *billButton;
@property (strong, nonatomic) IBOutlet UIButton *tipButton;
@property (strong, nonatomic) IBOutlet UIButton *grandTotalButton;

@property (strong, nonatomic) IBOutlet UIButton *incrementDollarsButton;
@property (strong, nonatomic) IBOutlet UIButton *decrementDollarsButton;
@property (strong, nonatomic) IBOutlet UIButton *incrementCentsButton;
@property (strong, nonatomic) IBOutlet UIButton *decrementCentsButton;
@property (strong, nonatomic) IBOutlet UIStepper *dollarsStepper;
@property (strong, nonatomic) IBOutlet UIStepper *centsStepper;
@property (strong, nonatomic) IBOutlet UIStepper *incrementDollarsStepper;
@property (strong, nonatomic) IBOutlet UIStepper *decrementDollarsStepper;
@property (strong, nonatomic) IBOutlet UIStepper *incrementCentsStepper;
@property (strong, nonatomic) IBOutlet UIStepper *decrementCentsStepper;

@property (strong, nonatomic) IBOutlet UIButton *ratingButton1;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton2;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton3;

@property (strong, nonatomic) IBOutlet UILabel *billDollarsLabel;
@property (strong, nonatomic) IBOutlet UILabel *billCentsLabel;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UILabel *grandTotalLabel;
@end

@implementation TodayViewController
@synthesize bill = _bill;

@synthesize billButton = _billButton;
@synthesize tipButton = _tipButton;
@synthesize grandTotalButton = _grandTotalButton;

@synthesize ratingButton1 = _ratingButton1;
@synthesize ratingButton2 = _ratingButton2;
@synthesize ratingButton3 = _ratingButton3;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.bill = [[MABill alloc] init];
    self.bill.delegate = self;
    
    [self setImage:[MAFilePaths billImage] forButton:self.billButton];
    [self setImage:[MAFilePaths tipAmountImage] forButton:self.tipButton];
    [self setImage:[MAFilePaths totalImage] forButton:self.grandTotalButton];

//    [self setPlusImageForButton:self.incrementCentsButton];
//    [self setPlusImageForButton:self.incrementDollarsButton];
//    [self setMinusImageForButton:self.decrementDollarsButton];
//    [self setMinusImageForButton:self.decrementCentsButton];
    
//    [self setImagesForStepper:self.incrementDollarsStepper isPlusButton:YES];
//    [self setImagesForStepper:self.decrementDollarsStepper isPlusButton:NO];
//    [self setImagesForStepper:self.incrementCentsStepper isPlusButton:YES];
//    [self setImagesForStepper:self.decrementCentsStepper isPlusButton:NO];

    [self setupSteppers];
    
    UILongPressGestureRecognizer *tapAndHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAndHold)];
    [tapAndHold setMinimumPressDuration:0.01];
    [self.incrementDollarsButton addGestureRecognizer:tapAndHold];

    CGFloat const defaultBill = 100.;
    self.bill.bill = [NSNumber numberWithDouble:defaultBill];
    [self setCurrentRatingButton:self.ratingButton3];

    // Increase the today widget view's height.
    // Use 0 for the width; otherwise, the view resizes strangely when a button is first tapped.
    self.preferredContentSize = CGSizeMake(0., 180.);
}

- (void)handleTapAndHold
{
    [self updateBillByDollars:+1 cents:0];
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
    if (currentRatingButton == self.ratingButton1)
    {
        self.bill.tipPercent = [NSNumber numberWithDouble:10.];
    }
    else if (currentRatingButton == self.ratingButton2)
    {
        self.bill.tipPercent = [NSNumber numberWithDouble:15.];
    }
    else if (currentRatingButton == self.ratingButton3)
    {
        self.bill.tipPercent = [NSNumber numberWithDouble:20.];
    }
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
    [self setBillLabels];
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

// Format dollar and cents labels.
- (void)setBillLabels
{
    NSArray *dollarsAndCents = [self dollarsAndCentsFromFormattedPrice:[self.bill formattedBill]];

    NSString *billDollars = [dollarsAndCents objectAtIndex:0];
    self.billDollarsLabel.text = billDollars;
    
    // Format using stepper value so don't have any weird floating point rounding issues where incrementing from .00 to .01 doesn't show any change.
//    NSString *billCents = [dollarsAndCents objectAtIndex:1];
//    self.billCentsLabel.text = billCents;
    NSNumberFormatter *priceFormatter = [MABill priceFormatter];
    NSString *billSeparator = priceFormatter.decimalSeparator;
    NSString *cents = [NSString stringWithFormat:@"%@%02d", billSeparator, (int)self.centsStepper.value];
    self.billCentsLabel.text = cents;
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
    if (sender == self.incrementDollarsStepper)
    {
        [self updateBillByDollars:+1 cents:0];
    }
    else if (sender == self.decrementDollarsStepper)
    {
        [self updateBillByDollars:-1 cents:0];
    }
    else if (sender == self.incrementCentsStepper)
    {
        [self updateBillByDollars:0 cents:+1];
    }
    else if (sender == self.decrementCentsStepper)
    {
        [self updateBillByDollars:0 cents:-1];
    }
    
    if (sender == self.dollarsStepper)
    {
    }
    else if (sender == self.centsStepper)
    {
    }
    
    NSInteger dollars = self.dollarsStepper.value;
    NSInteger cents = self.centsStepper.value;
    
    CGFloat centsFloat = (CGFloat)cents / 100.;
    CGFloat bill = (CGFloat)dollars + centsFloat;
    self.bill.bill = [NSNumber numberWithDouble:bill];

}

- (IBAction)incrementDollarsButtonTapped:(id)sender
{
    [self updateBillByDollars:+1 cents:0];
}

- (IBAction)decrementDollarsButtonTapped:(id)sender
{
    [self updateBillByDollars:-1 cents:0];
}

- (IBAction)incrementCentsButtonTapped:(id)sender
{
    [self updateBillByDollars:0 cents:+1];
}

- (IBAction)decrementCentsButtonTapped:(id)sender
{
    [self updateBillByDollars:0 cents:-1];
}

- (void)updateBillByDollars:(NSInteger)updateDollars cents:(NSInteger)updateCents
{
    NSInteger dollars;
    NSInteger cents;
    [self splitDecimalNumber:self.bill.bill.doubleValue integer:&dollars fraction:&cents];
    
    if ((dollars + updateDollars) >= 0)
    {
        dollars += updateDollars;
    }
    
    // 1.50 + .01 -> 1.51
    // 1.99 + .01 -> 1.00 (not 2.00)
    // 1.00 - .01 -> 1.99 (not 0.99)
    if ((cents + updateCents) >= 100)
    {
        cents = 0;
    }
    else if ((cents + updateCents) < 0)
    {
        cents = 99;
    }
    else
    {
        cents += updateCents;
    }
    
    CGFloat centsFloat = (CGFloat)cents / 100.;
    CGFloat bill = (CGFloat)dollars + centsFloat;
    self.bill.bill = [NSNumber numberWithDouble:bill];
}

@end
