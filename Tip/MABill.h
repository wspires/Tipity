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

@property (strong, nonatomic) NSNumber *bill;
@property (strong, nonatomic) NSNumber *tipPercent;
@property (strong, nonatomic) NSNumber *tip;
@property (strong, nonatomic) NSNumber *taxPercent;
@property (strong, nonatomic) NSNumber *tax;
@property (strong, nonatomic) NSNumber *total;
@property (strong, nonatomic) NSNumber *split;
@property (strong, nonatomic) NSNumber *splitTip;
@property (strong, nonatomic) NSNumber *splitBill;

@property (weak, nonatomic) id <MABillDelegate> delegate;

- (id)init;
- (id)initWithBill:(NSNumber *)bill;
- (id)initWithBill:(NSNumber *)bill tipPercent:(NSNumber *)tipPercent;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToProduct:(MABill *)aBill;

- (NSString *)formattedBill;
- (NSString *)formattedSplit;

+ (NSString *)formatBill:(NSNumber *)bill;
+ (NSString *)formatSplit:(NSNumber *)split;

+ (NSString *)formatPrice:(NSNumber *)price;
+ (NSString *)formatCount:(NSNumber *)count;

+ (NSNumberFormatter *)priceFormatter;
+ (NSNumberFormatter *)countFormatter;

@end

@protocol MABillDelegate <NSObject>
@optional
- (void)willUpdateBill:(MABill *)bill;
- (void)didUpdateBill:(MABill *)bill;
@end
