//
//  MAFraudDetector.m
//  Tip
//
//  Created by Wade Spires on 12/7/17.
//  Copyright © 2017 Minds Aspire LLC. All rights reserved.
//

#import "MAFraudDetector.h"

#import "MATipPercentForRating.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

@implementation MAFraudDetector

- (instancetype)init
{
    return [self initWithMode:FraudModeNone];
}
- (instancetype)initWithMode:(NSString *)mode
{
    self = [super init];
    if (self)
    {
        // Copy or set each property.
        self.mode = mode;
    }
    return self;
}

- (void)setMode:(NSString *)mode
{
    if ( ! mode)
    {
        _mode = FraudModeNone;
    }

    BOOL isValidMode = [mode isEqualToString:FraudModeNone]
    || [mode isEqualToString:FraudModeChecksum]
    || [mode isEqualToString:FraudModeMirror]
    || [mode isEqualToString:FraudModePairs];
    if ( ! isValidMode)
    {
        return;
    }

    _mode = [mode copy];
}

- (NSNumber *)adjustNumber:(NSNumber *)number
{
    double const f = number.doubleValue;
    double adjustedFloat = [self adjustFloat:f];
    NSNumber *adjustedNumber = [NSNumber numberWithFloat:adjustedFloat];
    return adjustedNumber;
}
- (double)adjustFloat:(double)f
{
    if ([_mode isEqualToString:FraudModeNone])
    {
        return f;
    }

    // 123.45 -> 123
    int dollars = (int)f;
    int cents = 0;

    if ([_mode isEqualToString:FraudModeChecksum])
    {
        // dollars = ab -> cents = a + b
        cents = 0;
        int n = dollars;
        while (n != 0)
        {
            cents += (n % 10);
            n /= 10;
        }
    }
    else if ([_mode isEqualToString:FraudModeMirror])
    {
        // dollars = ab -> cents = ba
        // abc -> cents = ba (palindrome if odd and not 1 digit).
        if (dollars < 10)
        {
            // 9 -> 9.90
            cents = dollars * 10;
        }
        else // if (dollars >= 10)
        {
            // 123. -> 123.321
            // Make reversed dollar string. Efficiency is not important because will only be a few characters long.
            NSString *dollarStr = [NSString stringWithFormat:@"%d", dollars];

            // Palindrome if odd number of digits: abc -> abc.ba
            if ((dollarStr.length % 2) == 1)
            {
                NSRange range = NSMakeRange(0, dollarStr.length - 1);
                dollarStr = [dollarStr substringWithRange:range];
            }

            NSMutableString *reverseDollarStr = [NSMutableString stringWithCapacity:dollarStr.length];
            [dollarStr enumerateSubstringsInRange:NSMakeRange(0, dollarStr.length)
                                         options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                                      usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                          [reverseDollarStr appendString:substring];
                                      }];
            cents = (int)reverseDollarStr.integerValue;
        }
    }
    else if ([_mode isEqualToString:FraudModePairs])
    {
        // dollars = ab -> cents = ab
        cents = dollars;
    }

    // 123 -> 12
    while (cents > 100)
    {
        cents /= 10;
    }

//    double centsFloat = 1 / 100. * cents;
//    f = dollars + centsFloat;
    NSString *decimalSep = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleDecimalSeparator];
    NSString *f_str = [NSString stringWithFormat:@"%d%@%02d", dollars, decimalSep, cents];
    LOG_S(@"Original: %lf", f);
    f = f_str.doubleValue;
    NSString *priceStr = [MABill formatPrice:[NSNumber numberWithDouble:f]];
    LOG_S(@"%lf -> %@ (f_str=%@)", f, priceStr, f_str);

    return f;
}

- (NSString *)printableName
{
    return [MAFraudDetector printableNameForMode:_mode];
}
+ (NSString *)printableNameForMode:(NSString *)mode
{
    if ([mode isEqualToString:FraudModeNone])
    {
        return Localize(@"Off");
    }
    else if ([mode isEqualToString:FraudModeChecksum])
    {
        return Localize(@"Add");
//        return Localize(@"Checksum");
//        return Localize(@"✓ Checksum");
//        return Localize(@"+ Checksum");
//        return Localize(@"⥅ Checksum");
//        return Localize(@"✓⥅ Checksum");
//        return Localize(@"✓+ Checksum");
    }
    else if ([mode isEqualToString:FraudModeMirror])
    {
        return Localize(@"Mirror");
//        return Localize(@"⇹ Mirror");
//        return Localize(@"⟷ Mirror");
//        return Localize(@"←→ Mirror");
    }
    else if ([mode isEqualToString:FraudModePairs])
    {
        return Localize(@"Repeat");
//        return Localize(@"Pairs");
//        return Localize(@"⥤ Pairs");
//        return Localize(@"↠ Pairs");
//        return Localize(@"→→ Pairs");
    }
    return Localize(@"Off");
}

+ (void)adjustGrandTotalInBill:(MABill *)bill
{
    if ([[MAUserUtil sharedInstance] fraudDetectionOff])
    {
        return;
    }

    // Must first reset the tip percent to the last selected rating.
    NSString *lastSelectedServiceRating = [[MAUserUtil sharedInstance] objectForKey:LastSelectedServiceRating];
    if (lastSelectedServiceRating && ! [lastSelectedServiceRating isEqualToString:NoLastSelectedServiceRating])
    {
        NSUInteger const rating = lastSelectedServiceRating.integerValue;
        NSNumber *tipPercent = [MATipPercentForRating tipPercentForRating:rating];
        bill.tipPercent = tipPercent;
    }

    // Adjust the grand total.
    NSString *fraudMode = [[MAUserUtil sharedInstance] objectForKey:FraudMode];
    MAFraudDetector *detector = [[MAFraudDetector alloc] initWithMode:fraudMode];
    NSNumber *adjustedTotal = [detector adjustNumber:bill.total];
    bill.total = adjustedTotal;
}

@end
