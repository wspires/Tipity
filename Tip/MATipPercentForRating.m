//
//  MATipPercentForRating.m
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import "MATipPercentForRating.h"

#import "MAUserUtil.h"

@implementation MATipPercentForRating

+ (NSUInteger)ratingForTipPercent:(NSNumber *)tipPercent
{
    NSUInteger rating = 1;
    double tipPercentDouble = tipPercent.doubleValue;
    
    double serviceRatingFair = [[MAUserUtil sharedInstance] serviceRatingFair].doubleValue;
    double serviceRatingGood = [[MAUserUtil sharedInstance] serviceRatingGood].doubleValue;
    double serviceRatingGreat = [[MAUserUtil sharedInstance] serviceRatingGreat].doubleValue;
    
    if (tipPercentDouble < serviceRatingFair)
    {
        rating = 1;
    }
    else if (tipPercentDouble >= serviceRatingFair && tipPercentDouble < serviceRatingGood)
    {
        rating = 2;
    }
    else if (tipPercentDouble >= serviceRatingGood && tipPercentDouble < serviceRatingGreat)
    {
        rating = 3;
    }
    else // if (tipPercentDouble >= serviceRatingGreat)
    {
        rating = 4;
    }
    
    return rating;
}

+ (NSNumber *)tipPercentForRating:(NSUInteger)rating
{
    double tipPercentDouble = 0;
    
    NSNumber *tipPercent = nil;
    if (rating <= 2)
    {
        tipPercent = [[MAUserUtil sharedInstance] serviceRatingFair];
    }
    else if (rating <= 3)
    {
        tipPercent = [[MAUserUtil sharedInstance] serviceRatingGood];
    }
    else // if (rating <= 4)
    {
        tipPercent = [[MAUserUtil sharedInstance] serviceRatingGreat];
    }
    tipPercentDouble = tipPercent.doubleValue;
    
    return [NSNumber numberWithDouble:tipPercentDouble];
}

@end
