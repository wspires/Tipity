//
//  MAFraudDetector.h
//  Tip
//
//  Created by Wade Spires on 12/7/17.
//  Copyright © 2017 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MABill.h"

@interface MAFraudDetector : NSObject

@property (copy, nonatomic) NSString *mode;

- (instancetype)init;
- (instancetype)initWithMode:(NSString *)mode;

- (NSNumber *)adjustNumber:(NSNumber *)number;
- (double)adjustFloat:(double)f;

- (NSString *)printableName;
+ (NSString *)printableNameForMode:(NSString *)mode;

+ (void)adjustGrandTotalInBill:(MABill *)bill;

@end
