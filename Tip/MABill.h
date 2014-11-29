//
//  MABill.h
//  Tip
//
//  Created by Wade Spires on 9/8/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MABillDelegate;

@interface MABill : NSObject
<NSCoding, NSCopying>

// Bill after tax.
@property (strong, nonatomic) NSNumber *bill;

// Tip % to leave.
@property (strong, nonatomic) NSNumber *tipPercent;

// Tip amount to leave.
@property (strong, nonatomic) NSNumber *tip;

// Tax % on the bill.
@property (strong, nonatomic) NSNumber *taxPercent;

// Tax amount on the bill.
@property (strong, nonatomic) NSNumber *tax;

// Bill before tax applied.
@property (strong, nonatomic) NSNumber *billBeforeTax;

// Total bill after tip and tax.
@property (strong, nonatomic) NSNumber *total;

// Number of people to split the bill between.
@property (strong, nonatomic) NSNumber *split;

// Tip amount per person.
@property (strong, nonatomic) NSNumber *splitTip;

// Each person's portion of the bill after tip and tax.
@property (strong, nonatomic) NSNumber *splitTotal;

@property (weak, nonatomic) id <MABillDelegate> delegate;

+ (MABill *)sharedInstance;
+ (MABill *)reloadSharedInstance:(BOOL)reload;
+ (MABill *)loadSharedInstance;
+ (BOOL)saveSharedInstance;

- (instancetype)init;
- (instancetype)initWithBill:(NSNumber *)bill;
- (instancetype)initWithBill:(NSNumber *)bill tipPercent:(NSNumber *)tipPercent;

// Sets tax to 0 without invoking delegate update methods.
- (void)clearTax;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToProduct:(MABill *)aBill;

- (NSString *)formattedBill;
- (NSString *)formattedTipPercent;
- (NSString *)formattedTip;
- (NSString *)formattedTaxPercent;
- (NSString *)formattedTax;
- (NSString *)formattedBillBeforeTax;
- (NSString *)formattedTotal;
- (NSString *)formattedSplit;
- (NSString *)formattedSplitTip;
- (NSString *)formattedSplitTotal;

+ (NSString *)formatBill:(NSNumber *)bill;
+ (NSString *)formatTipPercent:(NSNumber *)tipPercent;
+ (NSString *)formatTip:(NSNumber *)tip;
+ (NSString *)formatTaxPercent:(NSNumber *)taxPercent;
+ (NSString *)formatTax:(NSNumber *)tax;
+ (NSString *)formatBillBeforeTax:(NSNumber *)billBeforeTax;
+ (NSString *)formatTotal:(NSNumber *)total;
+ (NSString *)formatSplit:(NSNumber *)split;
+ (NSString *)formatSplitTip:(NSNumber *)splitTip;
+ (NSString *)formatSplitTotal:(NSNumber *)splitTotal;

+ (NSString *)formatPrice:(NSNumber *)price;
+ (NSString *)formatCount:(NSNumber *)count;
+ (NSString *)formatPercent:(NSNumber *)percent;

+ (NSNumberFormatter *)priceFormatter;
+ (NSNumberFormatter *)countFormatter;
+ (NSNumberFormatter *)percentFormatter;

@end

@protocol MABillDelegate <NSObject>
@optional
- (void)willUpdateBill:(MABill *)bill;
- (void)didUpdateBill:(MABill *)bill;
- (void)errorUpdatingBill:(MABill *)bill;
@end
