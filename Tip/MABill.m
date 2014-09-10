//
//  MABill.m
//  Tip
//
//  Created by Wade Spires on 9/8/14.
//  Copyright (c) 2014 Minds Aspire LLC. All rights reserved.
//

#import "MABill.h"

static double const DefaultBill = 100.;
static double const DefaultTipPercent = 20.;
static double const DefaultTip = 20.;
static double const DefaultTaxPercent = 0.;
static double const DefaultTax = 0.;
static double const DefaultTotal = 120.;
static double const DefaultSplit = 1.;
static double const DefaultSplitTip = 20.;
static double const DefaultSplitTotal = 120.;

@implementation MABill
@synthesize bill = _bill;
@synthesize tipPercent = _tipPercent;
@synthesize tip = _tip;
@synthesize taxPercent = _taxPercent;
@synthesize tax = _tax;
@synthesize total = _total;
@synthesize split = _split;
@synthesize splitTip = _splitTip;
@synthesize splitTotal = _splitTotal;

@synthesize delegate = _delegate;

- (id)init
{
    return [self initWithBill:[NSNumber numberWithDouble:DefaultBill]];
}

- (id)initWithBill:(NSNumber *)bill
{
    return [self initWithBill:[NSNumber numberWithDouble:DefaultBill] tipPercent:[NSNumber numberWithDouble:DefaultTipPercent]];
}

- (id)initWithBill:(NSNumber *)bill tipPercent:(NSNumber *)tipPercent
{
    self = [super init];
    if (self)
    {
        // Copy or set each property.
        _bill = [bill copy];
        _tipPercent = [tipPercent copy];
        _tip = [NSNumber numberWithDouble:DefaultTip];
        _taxPercent = [NSNumber numberWithDouble:DefaultTaxPercent];
        _tax = [NSNumber numberWithDouble:DefaultTax];
        _split = [NSNumber numberWithDouble:DefaultSplit];
        _splitTip = [NSNumber numberWithDouble:DefaultSplitTip];
        _splitTotal = [NSNumber numberWithDouble:DefaultSplitTotal];
        
        // Re-calculates any properties given above as needed.
        [self updateBill];
    }
    return self;
}

- (void)delegateWillUpdateBill
{
    if (_delegate && [_delegate respondsToSelector:@selector(willUpdateBill:)])
    {
        [_delegate willUpdateBill:self];
    }
}

- (void)delegateDidUpdateBill
{
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdateBill:)])
    {
        [_delegate didUpdateBill:self];
    }
}

- (void)delegateErrorUpdatingBill
{
    if (_delegate && [_delegate respondsToSelector:@selector(errorUpdatingBill:)])
    {
        [_delegate errorUpdatingBill:self];
    }
}

#pragma mark Setters

- (void)setBill:(NSNumber *)bill
{
    if ( ! bill || bill.doubleValue == _bill.doubleValue)
    {
        return;
    }
    
    [self delegateWillUpdateBill];

    _bill = [bill copy];
    
    [self updateBill];
    [self delegateDidUpdateBill];
}

- (void)setTipPercent:(NSNumber *)tipPercent
{
    if ( ! tipPercent || tipPercent.doubleValue == _tipPercent.doubleValue)
    {
        return;
    }

    [self delegateWillUpdateBill];

    _tipPercent = [tipPercent copy];
    
    [self updateBill];
    [self delegateDidUpdateBill];
}

- (void)setTip:(NSNumber *)tip
{
    if ( ! tip || tip.doubleValue == _tip.doubleValue)
    {
        return;
    }
    
    [self delegateWillUpdateBill];
    
    _tip = [tip copy];
    _tipPercent = [MABill percentFromNumber:_bill percentageOfNumber:_tip];
    
    [self updateBill];
    [self delegateDidUpdateBill];
}

- (void)setTaxPercent:(NSNumber *)taxPercent
{
    if ( ! taxPercent || taxPercent.doubleValue == _taxPercent.doubleValue)
    {
        return;
    }
    
    [self delegateWillUpdateBill];
    
    _taxPercent = [taxPercent copy];
    
    [self updateBill];
    [self delegateDidUpdateBill];
}

- (void)setTax:(NSNumber *)tax
{
    if ( ! tax || tax.doubleValue == _tax.doubleValue)
    {
        return;
    }
    
    [self delegateWillUpdateBill];
    
    _tax = [tax copy];
    _taxPercent = [MABill percentFromNumber:_bill percentageOfNumber:_tax];
    
    [self updateBill];
    [self delegateDidUpdateBill];
}

- (void)setTotal:(NSNumber *)total
{
    if ( ! total || total.doubleValue == _total.doubleValue)
    {
        return;
    }
    
    [self delegateWillUpdateBill];
    
    _total = [total copy];
    _tip = [NSNumber numberWithDouble:(_total.doubleValue - _bill.doubleValue)];
    _tipPercent = [MABill percentFromNumber:_bill percentageOfNumber:_tip];
    
    [self updateBill];
    [self delegateDidUpdateBill];
}

- (void)setSplit:(NSNumber *)split
{
    if ( ! split || split.doubleValue == _split.doubleValue)
    {
        return;
    }
    
    if (split.doubleValue <= 0)
    {
        [self delegateErrorUpdatingBill];
        return;
    }
    
    [self delegateWillUpdateBill];

    _split = [split copy];
    
    [self updateBill];
    [self delegateDidUpdateBill];
}

- (void)setSplitTip:(NSNumber *)splitTip
{
    if ( ! splitTip || splitTip.doubleValue == _splitTip.doubleValue)
    {
        return;
    }
    
    [self delegateWillUpdateBill];

    _splitTip = [splitTip copy];
    _tip = [NSNumber numberWithDouble:(_split.doubleValue * _splitTip.doubleValue)];
    _tipPercent = [MABill percentFromNumber:_bill percentageOfNumber:_tip];

    [self updateBill];
    [self delegateDidUpdateBill];
}

- (void)setSplitTotal:(NSNumber *)splitTotal
{
    if ( ! splitTotal || splitTotal.doubleValue == _splitTotal.doubleValue)
    {
        return;
    }
    
    [self delegateWillUpdateBill];

    _splitTotal = [splitTotal copy];
    _total = [NSNumber numberWithDouble:(_splitTotal.doubleValue * _split.doubleValue)];
    _tip = [NSNumber numberWithDouble:(_total.doubleValue - _bill.doubleValue)];
    _tipPercent = [MABill percentFromNumber:_bill percentageOfNumber:_tip];
    
    [self updateBill];
    [self delegateDidUpdateBill];
}

// Update bill. Members bill, tipPercent, taxPercent, and split are assumed to be set already.
- (void)updateBill
{
    _tip = [MABill percentageOfNumber:_bill percent:_tipPercent];
    _tax = [MABill percentageOfNumber:_bill percent:_taxPercent];
    
    // TODO: Add flag on whether the tax is included or tacked on and whether the tax should be factored into the tip or not.
    _total = [NSNumber numberWithDouble:(_bill.doubleValue + _tip.doubleValue)];
    
    _splitTip = [NSNumber numberWithDouble:(_tip.doubleValue / _split.doubleValue)];
    _splitTotal = [NSNumber numberWithDouble:(_total.doubleValue / _split.doubleValue)];
}

+ (NSNumber *)percentageOfNumber:(NSNumber *)number percent:(NSNumber *)percent
{
    double const percentageOfNumber = number.doubleValue * (percent.doubleValue / 100.);
    return [NSNumber numberWithDouble:percentageOfNumber];
}

+ (NSNumber *)percentFromNumber:(NSNumber *)number percentageOfNumber:(NSNumber *)percentageOfNumber
{
    double const percent = 100. * (percentageOfNumber.doubleValue / number.doubleValue);
    return [NSNumber numberWithDouble:percent];
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

- (BOOL)isEqualToProduct:(MABill *)aBill
{
    if (self == aBill)
    {
        return YES;
    }
    
    if ( ! [self.bill isEqual:aBill.bill])
    {
        return NO;
    }
    
    if ( ! [self.tipPercent isEqual:aBill.tipPercent])
    {
        return NO;
    }
    
    if ( ! [self.tip isEqual:aBill.tip])
    {
        return NO;
    }

    if ( ! [self.taxPercent isEqual:aBill.taxPercent])
    {
        return NO;
    }
    
    if ( ! [self.tax isEqual:aBill.tax])
    {
        return NO;
    }
    
    if ( ! [self.total isEqual:aBill.total])
    {
        return NO;
    }
    
    if ( ! [self.split isEqual:aBill.split])
    {
        return NO;
    }
    
    if ( ! [self.splitTip isEqual:aBill.splitTip])
    {
        return NO;
    }
    
    if ( ! [self.splitTotal isEqual:aBill.splitTotal])
    {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash
{
    return [self.bill hash]
    ^ [self.tipPercent hash]
    ^ [self.tip hash]
    ^ [self.taxPercent hash]
    ^ [self.tax hash]
    ^ [self.total hash]
    ^ [self.split hash]
    ^ [self.splitTip hash]
    ^ [self.splitTotal hash]
    ;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MABill *copy = [[[self class] allocWithZone:zone] init];
    copy.bill = [self.bill copy];
    copy.tipPercent = [self.tipPercent copy];
    copy.tip = [self.tip copy];
    copy.taxPercent = [self.taxPercent copy];
    copy.tax = [self.tax copy];
    copy.total = [self.total copy];
    copy.split = [self.split copy];
    copy.splitTip = [self.splitTip copy];
    copy.splitTotal = [self.splitTotal copy];
    return copy;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bill forKey:@"bill"];
    [aCoder encodeObject:self.tipPercent forKey:@"tipPercent"];
    [aCoder encodeObject:self.tip forKey:@"tip"];
    [aCoder encodeObject:self.taxPercent forKey:@"taxPercent"];
    [aCoder encodeObject:self.tax forKey:@"tax"];
    [aCoder encodeObject:self.total forKey:@"total"];
    [aCoder encodeObject:self.split forKey:@"split"];
    [aCoder encodeObject:self.splitTip forKey:@"splitTip"];
    [aCoder encodeObject:self.splitTotal forKey:@"splitTotal"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _bill = [aDecoder decodeObjectForKey:@"bill"];
        if ( ! _bill)
        {
            _bill = [NSNumber numberWithDouble:DefaultBill];
        }

        _tipPercent = [aDecoder decodeObjectForKey:@"tipPercent"];
        if ( ! _tipPercent)
        {
            _tipPercent = [NSNumber numberWithDouble:DefaultTipPercent];
        }
        
        _tip = [aDecoder decodeObjectForKey:@"tip"];
        if ( ! _tip)
        {
            _tip = [NSNumber numberWithDouble:DefaultTip];
        }
        
        _taxPercent = [aDecoder decodeObjectForKey:@"taxPercent"];
        if ( ! _taxPercent)
        {
            _taxPercent = [NSNumber numberWithDouble:DefaultTaxPercent];
        }
        
        _tax = [aDecoder decodeObjectForKey:@"tax"];
        if ( ! _tax)
        {
            _tax = [NSNumber numberWithDouble:DefaultTax];
        }
        
        _total = [aDecoder decodeObjectForKey:@"total"];
        if ( ! _total)
        {
            _total = [NSNumber numberWithDouble:DefaultTotal];
        }
        
        _split = [aDecoder decodeObjectForKey:@"split"];
        if ( ! _split)
        {
            _split = [NSNumber numberWithDouble:DefaultSplit];
        }
        
        _splitTip = [aDecoder decodeObjectForKey:@"splitTip"];
        if ( ! _splitTip)
        {
            _splitTip = [NSNumber numberWithDouble:DefaultSplitTip];
        }
        
        _splitTotal = [aDecoder decodeObjectForKey:@"splitTotal"];
        if ( ! _splitTotal)
        {
            _splitTotal = [NSNumber numberWithDouble:DefaultSplitTotal];
        }
    }
    return self;
}

- (NSString *)formattedBill
{
    return [MABill formatBill:self.bill];
}

- (NSString *)formattedTipPercent
{
    return [MABill formatTipPercent:self.tipPercent];
}

- (NSString *)formattedTip
{
    return [MABill formatTip:self.tip];
}

- (NSString *)formattedTotal
{
    return [MABill formatTotal:self.total];
}

- (NSString *)formattedSplit
{
    return [MABill formatSplit:self.split];
}

- (NSString *)formattedSplitTip
{
    return [MABill formatSplitTip:self.splitTip];
}

- (NSString *)formattedSplitTotal
{
    return [MABill formatSplitTotal:self.splitTotal];
}

+ (NSString *)formatBill:(NSNumber *)bill
{
    return [MABill formatPrice:bill];
}

+ (NSString *)formatTipPercent:(NSNumber *)tipPercent
{
    return [MABill formatPercent:tipPercent];
}

+ (NSString *)formatTip:(NSNumber *)tip
{
    return [MABill formatPrice:tip];
}

+ (NSString *)formatTotal:(NSNumber *)total
{
    return [MABill formatPrice:total];
}

+ (NSString *)formatSplit:(NSNumber *)split
{
    return [MABill formatCount:split];
}

+ (NSString *)formatSplitTip:(NSNumber *)splitTip
{
    return [MABill formatPrice:splitTip];
}

+ (NSString *)formatSplitTotal:(NSNumber *)splitTotal
{
    return [MABill formatPrice:splitTotal];
}

+ (NSString *)formatPrice:(NSNumber *)price
{
    NSNumberFormatter *formatter = [MABill priceFormatter];
    return [formatter stringFromNumber:price];
}

+ (NSString *)formatCount:(NSNumber *)count
{
    // Prevent a signed 0. Sometimes we get a -0 as the result of some calculations, which looks weird to the user, so display as just 0.
    // Note: that '-0 == 0' is true.
    // http://en.wikipedia.org/wiki/Signed_zero
    double value = count.doubleValue;
    if (value == 0)
    {
        value = fabs(value);
    }
    
    NSNumberFormatter *formatter = [MABill countFormatter];
    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    return str;
}

+ (NSString *)formatPercent:(NSNumber *)percent
{
    NSNumberFormatter *formatter = [MABill percentFormatter];
    return [formatter stringFromNumber:percent];
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

+ (NSNumberFormatter *)countFormatter
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        [nf setPaddingCharacter:@" "];
        [nf setUsesGroupingSeparator:NO];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
        [nf setMaximumFractionDigits:2];
        [nf setRoundingMode:NSNumberFormatterRoundHalfUp];
    });
    return nf;
}

+ (NSNumberFormatter *)percentFormatter
{
    static dispatch_once_t once;
    static NSNumberFormatter *nf = nil;
    dispatch_once(&once, ^{
        nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterPercentStyle];
        [nf setPaddingCharacter:@" "];
        [nf setUsesGroupingSeparator:NO];
        [nf setLocale:[NSLocale autoupdatingCurrentLocale]];
        [nf setMaximumFractionDigits:2];
        [nf setRoundingMode:NSNumberFormatterRoundHalfUp];
        
        [nf setMaximumFractionDigits:0];
        [nf setMultiplier:@1];
    });
    return nf;
}

@end