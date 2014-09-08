//
//  MAProduct.m
//  Gym Log
//
//  Created by Wade Spires on 8/26/14.
//
//

#import "MAProduct.h"

#import "MAUtil.h"

static double const DefaultPrice = 9.99;
static double const DefaultQuantity = 10;
static double const DefaultSize = 1;

@implementation MAProduct
@synthesize quantity = _quantity;
@synthesize price = _price;
@synthesize size = _size;
@synthesize delegate = _delegate;

- (id)init
{
    return [self initWithPrice:[NSNumber numberWithDouble:DefaultPrice] quantity:[NSNumber numberWithDouble:DefaultQuantity]];
}

- (id)initWithPrice:(NSNumber *)price quantity:(NSNumber *)quantity
{
    return [self initWithPrice:[NSNumber numberWithDouble:DefaultPrice] quantity:[NSNumber numberWithDouble:DefaultQuantity] size:[NSNumber numberWithDouble:DefaultSize]];
}

- (id)initWithPrice:(NSNumber *)price quantity:(NSNumber *)quantity size:(NSNumber *)size
{
    self = [super init];
    if (self) {
        // Initialization code
        _price = [price copy];
        _quantity = [quantity copy];
        _size = [size copy];
    }
    return self;
}

- (void)setPrice:(NSNumber *)price
{
    if ( ! price || price.doubleValue == _price.doubleValue)
    {
        return;
    }
    
    _price = [price copy];
    if (_delegate)
    {
        [_delegate didEndEditing:self];
    }
}

- (void)setQuantity:(NSNumber *)quantity
{
    if ( ! quantity || quantity.doubleValue == _quantity.doubleValue)
    {
        return;
    }
    
    _quantity = [quantity copy];
    if (_delegate)
    {
        [_delegate didEndEditing:self];
    }
}

- (void)setSize:(NSNumber *)size
{
    if ( ! size || size.doubleValue == _size.doubleValue)
    {
        return;
    }
    
    _size = [size copy];
    if (_delegate)
    {
        [_delegate didEndEditing:self];
    }
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
    {
        return YES;
    }
    if ( ! other || ! [other isKindOfClass:[self class]])
    {
        return NO;
    }
    return [self isEqualToProduct:other];
}

- (BOOL)isEqualToProduct:(MAProduct *)aProduct
{
    if (self == aProduct)
    {
        return YES;
    }
    
    if ( ! [self.price isEqual:aProduct.price])
    {
        return NO;
    }
    
    if ( ! [self.quantity isEqual:aProduct.quantity])
    {
        return NO;
    }
  
    if ( ! [self.size isEqual:aProduct.size])
    {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash
{
    return [self.price hash] ^ [self.quantity hash] ^ [self.size hash];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAProduct *copy = [[[self class] allocWithZone:zone] init];
    copy.price = [self.price copy];
    copy.quantity = [self.quantity copy];
    copy.size = [self.size copy];
    return copy;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.quantity forKey:@"quantity"];
    [aCoder encodeObject:self.size forKey:@"size"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _price = [aDecoder decodeObjectForKey:@"price"];
        if ( ! _price)
        {
            _price = [NSNumber numberWithDouble:DefaultPrice];
        }
        
        _quantity = [aDecoder decodeObjectForKey:@"quantity"];
        if ( ! _quantity)
        {
            _quantity = [NSNumber numberWithDouble:DefaultQuantity];
        }

        _size = [aDecoder decodeObjectForKey:@"size"];
        if ( ! _size)
        {
            _size = [NSNumber numberWithDouble:DefaultSize];
        }
    }
    return self;
}

- (NSNumber *)pricePerUnit
{
    double quantityTimesSize = self.quantity.doubleValue * self.size.doubleValue;
    if (quantityTimesSize == 0)
    {
        return self.price;
    }
    return [NSNumber numberWithDouble:(self.price.doubleValue / quantityTimesSize)];
}

- (NSString *)formattedPrice
{
    return [MAProduct formatPrice:self.price];
}

- (NSString *)formattedQuantity
{
    return [MAProduct formatQuantity:self.quantity];
}

- (NSString *)formattedSize
{
    return [MAProduct formatSize:self.size];
}

- (NSString *)formattedUnitPrice
{
    return [MAProduct formatUnitPrice:[self pricePerUnit]];
}

+ (NSString *)formatPrice:(NSNumber *)price
{
    NSNumberFormatter *formatter = [MAProduct priceFormatter];
    return [formatter stringFromNumber:price];
}

+ (NSString *)formatQuantity:(NSNumber *)quantity
{
    return [MAUtil formatDouble:quantity.doubleValue];
}

+ (NSString *)formatSize:(NSNumber *)size
{
    return [MAUtil formatDouble:size.doubleValue];
}

+ (NSString *)formatUnitPrice:(NSNumber *)unitPrice
{
    NSNumberFormatter *formatter = [MAProduct unitPriceFormatter];
    return [formatter stringFromNumber:unitPrice];
}

+ (NSNumberFormatter *)priceFormatter
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
        
        [nf setMaximumFractionDigits:2];
        [nf setMinimumFractionDigits:2];
        [nf setAlwaysShowsDecimalSeparator:YES];
    });
    return nf;
}

+ (NSNumberFormatter *)unitPriceFormatter
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
        
        // Unit price may be a small fraction, so show several digits.
        [nf setMaximumFractionDigits:20];
        [nf setMinimumFractionDigits:2];
        //        [nf setMinimumSignificantDigits:2];
        //        [nf setMaximumSignificantDigits:3];
        //        [nf setUsesSignificantDigits:YES];
        //        [nf setMaximumSignificantDigits:5];
        //        [nf setMaximumFractionDigits:2];
        //        [nf setRoundingMode:NSNumberFormatterRoundCeiling];
        
        [nf setAlwaysShowsDecimalSeparator:YES];
    });
    return nf;
}

@end
