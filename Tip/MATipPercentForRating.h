//
//  MATipPercentForRating.h
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MATipPercentForRating : NSObject

+ (NSUInteger)ratingForTipPercent:(NSNumber *)tipPercent;
+ (NSNumber *)tipPercentForRating:(NSUInteger)rating;

@end
