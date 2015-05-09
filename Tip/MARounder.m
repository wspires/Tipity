//
//  MARounder.m
//  Tip
//
//  Created by Wade Spires on 5/8/15.
//  Copyright (c) 2015 Minds Aspire LLC. All rights reserved.
//

#import "MARounder.h"

#import "MARatingTableViewCell.h"
#import "MAUserUtil.h"
#import "MAUtil.h"

@implementation MARounder

- (instancetype)init
{
    return [self initWithMode:RoundingModeNone];
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
        _mode = RoundingModeNone;
    }
    
    BOOL isValidMode = [mode isEqualToString:RoundingModeNone]
        || [mode isEqualToString:RoundingModeUp]
        || [mode isEqualToString:RoundingModeDown]
        || [mode isEqualToString:RoundingModeNear];
    if ( ! isValidMode)
    {
        return;
    }
    
    _mode = [mode copy];
}

- (NSNumber *)roundNumber:(NSNumber *)number
{
    double const f = number.doubleValue;
    double roundedFloat = [self roundFloat:f];
    NSNumber *roundedNumber = [NSNumber numberWithFloat:roundedFloat];
    return roundedNumber;
}
- (double)roundFloat:(double)f
{
    if ([_mode isEqualToString:RoundingModeNone])
    {
        return f;
    }
    else if ([_mode isEqualToString:RoundingModeUp])
    {
        return ceil(f);
    }
    else if ([_mode isEqualToString:RoundingModeDown])
    {
        return floor(f);
    }
    else if ([_mode isEqualToString:RoundingModeNear])
    {
        return round(f);
    }
    return f;
}

- (NSString *)printableName
{
    return [MARounder printableNameForMode:_mode];
}
+ (NSString *)printableNameForMode:(NSString *)mode
{
    if ([mode isEqualToString:RoundingModeNone])
    {
        return Localize(@"None");
    }
    else if ([mode isEqualToString:RoundingModeUp])
    {
        return Localize(@"Up");
    }
    else if ([mode isEqualToString:RoundingModeDown])
    {
        return Localize(@"Down");
    }
    else if ([mode isEqualToString:RoundingModeNear])
    {
        return Localize(@"Nearest");
    }
    return Localize(@"None");
}

+ (void)roundGrandTotalInBill:(MABill *)bill
{
    // Check if rounding is enabled.
    if ( ! [[MAUserUtil sharedInstance] enableRounding])
    {
        return;
    }
    
    // Must first reset the tip percent to the last selected rating.
    // Otherwise, would use the previous tip %, which might have already been rounded up, so rounding again would pull the tip % even further away from the user's selected tip %. For example, the user selects 20 %, and the first time they tip, the tip % gets rounded up to 21%. After entering a second bill, the tip % might get rounded up further to 22 % unless it was first reset back down to 20 % (after rounding a second time, it might get rounded again up to, say, 20.5 %).
    NSString *lastSelectedServiceRating = [[MAUserUtil sharedInstance] objectForKey:LastSelectedServiceRating];
    if (lastSelectedServiceRating && ! [lastSelectedServiceRating isEqualToString:NoLastSelectedServiceRating])
    {
        NSUInteger const rating =lastSelectedServiceRating.integerValue;
        NSNumber *tipPercent = [MARatingTableViewCell tipPercentForRating:rating];
        bill.tipPercent = tipPercent;
    }
    
    // Round the grand total.
    NSString *roundingMode = [[MAUserUtil sharedInstance] objectForKey:RoundingMode];
    MARounder *rounder = [[MARounder alloc] initWithMode:roundingMode];
    NSNumber *roundedTotal = [rounder roundNumber:bill.total];
    bill.total = roundedTotal;
}

@end
