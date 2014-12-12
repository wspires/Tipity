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

@property (weak, nonatomic) IBOutlet WKInterfaceSlider *dollarSlider;
@property (strong, nonatomic) NSNumber *dollars;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *centSlider;
@property (strong, nonatomic) NSNumber *cents;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *billLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *tipLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *grandTotalLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *openButton;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;
@end

@implementation InterfaceController
@synthesize bill = _bill;
@synthesize settings = _settings;
@synthesize dollarSlider = _dollarSlider;
@synthesize dollars = _dollars;
@synthesize centSlider = _centSlider;
@synthesize cents = _cents;
@synthesize billLabel = _billLabel;
@synthesize tipLabel = _tipLabel;
@synthesize grandTotalLabel = _grandTotalLabel;

- (instancetype)initWithContext:(id)context
{
    self = [super initWithContext:context];
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
        
        // TODO: Would be better to not use sliders to select the $ and cents. However, there is no API for accessing the digital crown.
        
        [self setupSliders];
        
        //[self.image setImageNamed:@"BillImage"];
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

    [self updateLabels];

//    MAAppDelegate* myDelegate = (((MAAppDelegate*) [UIApplication sharedApplication].delegate));
//    if (myDelegate.todayViewBill)
//    {
//        self.bill.bill = myDelegate.todayViewBill.bill;
//        self.bill.tipPercent = myDelegate.todayViewBill.tipPercent;
//        myDelegate.todayViewBill = nil;
//    }
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

#pragma mark - #pragma mark - Shared Data Changed


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
    [self setupSliders];
    [self updateLabels];
}

@end
