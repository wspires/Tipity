//
//  MARounder.h
//  Tip
//
//  Created by Wade Spires on 5/8/15.
//  Copyright (c) 2015 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MABill.h"

@interface MARounder : NSObject

@property (copy, nonatomic) NSString *mode;

- (instancetype)init;
- (instancetype)initWithMode:(NSString *)mode;

- (NSNumber *)roundNumber:(NSNumber *)number;
- (double)roundFloat:(double)f;

- (NSString *)printableName;
+ (NSString *)printableNameForMode:(NSString *)mode;

+ (void)roundGrandTotalInBill:(MABill *)bill;

@end
