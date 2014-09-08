//
//  MAProduct.h
//  Gym Log
//
//  Created by Wade Spires on 8/26/14.
//
//

#import <Foundation/Foundation.h>

@protocol MAProductDelegate;

@interface MAProduct : NSObject
<NSCoding, NSCopying>

@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSNumber *size;
@property (weak, nonatomic) id <MAProductDelegate> delegate;

- (id)init;
- (id)initWithPrice:(NSNumber *)price quantity:(NSNumber *)quantity;
- (id)initWithPrice:(NSNumber *)price quantity:(NSNumber *)quantity size:(NSNumber *)size;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToProduct:(MAProduct *)aProduct;

- (NSNumber *)pricePerUnit;
- (NSString *)formattedPrice;
- (NSString *)formattedQuantity;
- (NSString *)formattedSize;
- (NSString *)formattedUnitPrice;

+ (NSString *)formatPrice:(NSNumber *)price;
+ (NSString *)formatQuantity:(NSNumber *)quantity;
+ (NSString *)formatSize:(NSNumber *)size;
+ (NSString *)formatUnitPrice:(NSNumber *)unitPrice;

+ (NSNumberFormatter *)priceFormatter;
+ (NSNumberFormatter *)unitPriceFormatter;

@end

@protocol MAProductDelegate <NSObject>
@optional
- (void)didEndEditing:(MAProduct *)product;
@end
