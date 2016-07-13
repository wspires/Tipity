//
//  InterfaceController.m
//  nativewatchkitapp Extension
//
//  Created by Wade Spires on 6/23/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import "InterfaceController.h"

#import "MAAppGroupNotifier.h"
#import "MABill.h"
#import "MALogUtil.h"
#import "MANotificationNames.h"
#import "MARounder.h"
#import "MATipPercentForRating.h"
#import "MAUserUtil.h"

@interface InterfaceController() <MABillDelegate>
@property (strong, nonatomic) MABill *bill;

@property (weak, nonatomic) IBOutlet WKInterfacePicker *dollarPicker;
@property (strong, nonatomic) NSNumber *dollarNumber;

@property (weak, nonatomic) IBOutlet WKInterfacePicker *centPicker;
@property (strong, nonatomic) NSNumber *centNumber;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *serviceRatingLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *tipLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *grandTotalLabel;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];

//    LOG
    
    [self loadSettings];
    [self loadBill];
    [self configurePickers];
    [self updateLabels];
    [self configureMenuItems];

    // Configure interface objects here.
    [self registerForSharedDataChangedNotifications];
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)loadSettings
{
    [MAUserUtil reloadSharedInstance:YES];
    
    if ( self.bill && ! [[MAUserUtil sharedInstance] enableTax])
    {
        [self.bill clearTax];
    }
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

- (void)configurePickers
{
    static int const Min_Dollar = 0;
    static int const Max_Dollar = 10000;
    NSMutableArray *items = [NSMutableArray array];
    for (int i = Min_Dollar; i != Max_Dollar; ++i)
    {
        WKPickerItem *item = [[WKPickerItem alloc] init];
        item.title = [NSString stringWithFormat:@"%d", i];
        [items addObject:item];
    }
    [self.dollarPicker setItems:items];

    static int const Min_Cent = 0;
    static int const Max_Cent = 100;
    items = [NSMutableArray array];
    for (int i = Min_Cent; i != Max_Cent; ++i)
    {
        WKPickerItem *item = [[WKPickerItem alloc] init];
        item.title = [NSString stringWithFormat:@"%02d", i];
        [items addObject:item];
    }
    [self.centPicker setItems:items];
    
    [self setSelectedPickerIndexFromBill];
}

- (void)setSelectedPickerIndexFromBill
{
    [self setBillComponentsFromNumber:self.bill.bill];
    [self.dollarPicker setSelectedItemIndex:self.dollarNumber.integerValue];
    [self.centPicker setSelectedItemIndex:self.centNumber.integerValue];
}

- (IBAction)dollarPickerAction:(NSInteger)index
{
//    LOG_I(index);
    self.dollarNumber = [NSNumber numberWithInteger:index];
    [self updateBill];
}

- (IBAction)centPickerAction:(NSInteger)index
{
    self.centNumber = [NSNumber numberWithInteger:index];
    [self updateBill];
}

- (NSNumber *)billComponentsToNumber
{
    double dollars = self.dollarNumber.integerValue;
    double cents = 1 / 100. * self.centNumber.intValue;
    double value = dollars + cents;
    NSNumber *number = [NSNumber numberWithDouble:value];
    return number;
}

- (void)setBillComponentsFromNumber:(NSNumber *)number
{
    float value = number.doubleValue;
    int intPart = (int)value;
    int fracPart = (int)(100 * (value - intPart)); // Fraction part: x100 because we only want cents.

    self.dollarNumber = [NSNumber numberWithInteger:intPart];
    self.centNumber = [NSNumber numberWithInteger:fracPart];
}

- (void)updateBill
{
    NSNumber *bill = [self billComponentsToNumber];
    self.bill.bill = bill;
    [MARounder roundGrandTotalInBill:self.bill];
    [self saveBill];
}

- (void)saveBill
{
    BOOL saved = [MABill saveSharedInstance];
    if ( ! saved)
    {
        TLog(@"Failed to save bill");
    }
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Shared Data Changed

- (void)registerForSharedDataChangedNotifications
{
    [[MAAppGroupNotifier sharedInstance] addObserver:self selector:@selector(billDidChange:) key:[MABill sharedContainerKey]];
    [[MAAppGroupNotifier sharedInstance] addObserver:self selector:@selector(settingsDidChange:) key:[MAUserUtil sharedContainerKey]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(billDidChange:) name:BillChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDidChange:) name:SettingsChangedNotification object:nil];
}

- (void)unregisterForSharedDataChangedNotifications
{
//    [[MAAppGroupNotifier sharedInstance] removeObserver:self key:[MABill sharedContainerKey]];
//    [[MAAppGroupNotifier sharedInstance] removeObserver:self key:[MAUserUtil sharedContainerKey]];
}

- (void)billDidChange:(NSNotification *)notification
{
//    LOG
    [self loadBillAndUpdateUI];
}

- (void)loadBillAndUpdateUI
{
    [self loadBill];
    [self setSelectedPickerIndexFromBill];
    [self updateLabels];
}

- (void)settingsDidChange:(NSNotification *)notification
{
//    LOG
    [self loadSettings];
    [self loadBillAndUpdateUI];
//    [self updateLabels];
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
    [self updateServiceRatingLabel];
    self.tipLabel.text = [self.bill formattedTip];
    self.grandTotalLabel.text = [self.bill formattedTotal];
}

- (void)updateServiceRatingLabel
{
    NSString *serviceRatingText = @"★★★";
    NSUInteger const rating = [MATipPercentForRating ratingForTipPercent:self.bill.tipPercent];
    if (rating == 1)
    {
        serviceRatingText = @"☆";
    }
    else if (rating == 2)
    {
        serviceRatingText = @"★";
    }
    else if (rating == 3)
    {
        serviceRatingText = @"★★";
    }
    else // if (rating > 3)
    {
        serviceRatingText = @"★★★";
    }
    self.serviceRatingLabel.text = serviceRatingText;
}

#pragma mark - Menu items

- (void)configureMenuItems
{
    [self clearAllMenuItems];
    
    NSString *title = nil;
    
    title = [NSString stringWithFormat:@"Fair"];
    [self addMenuItemWithImageNamed:@"FairServiceRatingImage" title:title action:@selector(doMenuItemAction1)];
    
    title = [NSString stringWithFormat:@"Good"];
    [self addMenuItemWithImageNamed:@"GoodServiceRatingImage" title:title action:@selector(doMenuItemAction2)];
    
    title = [NSString stringWithFormat:@"Great"];
    [self addMenuItemWithImageNamed:@"GreatServiceRatingImage" title:title action:@selector(doMenuItemAction3)];
}

- (void)doMenuItemAction1
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingFair];
    [self setTipPercent:tipPercent];
}

- (void)doMenuItemAction2
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingGood];
    [self setTipPercent:tipPercent];
}

- (void)doMenuItemAction3
{
    NSNumber *tipPercent = [[MAUserUtil sharedInstance] serviceRatingGreat];
    [self setTipPercent:tipPercent];
}

- (void)setTipPercent:(NSNumber *)tipPercent
{
    if (tipPercent.doubleValue == self.bill.tipPercent.doubleValue)
    {
        return;
    }
    else if (tipPercent.doubleValue < self.bill.tipPercent.doubleValue)
    {
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeDirectionDown];
    }
    else // if (tipPercent.doubleValue > self.bill.tipPercent.doubleValue)
    {
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeDirectionUp];
    }

    self.bill.tipPercent = tipPercent;
    
    // ratingInt is the ID of the service rating, like 1, 2, 3, 4, 5, while the other "rating" variable is the actual tip percent. Needed to handle rounding.
    NSUInteger const rating = [MATipPercentForRating ratingForTipPercent:tipPercent];
    NSString *ratingString = [NSString stringWithFormat:@"%d", (int)rating];
    [[MAUserUtil sharedInstance] saveSetting:ratingString forKey:LastSelectedServiceRating];
    [MARounder roundGrandTotalInBill:self.bill];

    [self updateServiceRatingLabel];

    [self saveBill];
}

@end
