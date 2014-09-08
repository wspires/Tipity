//
//  MAIAPHelper.h
//  Weight Log
//
//  Created by Wade Spires on 6/16/13.
//  Copyright (c) 2013 Wade Spires. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

UIKIT_EXTERN NSString * const IAPHelperProductPurchasedNotification;

@interface MAIAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)productPurchasedHandler:(NSString *)productIdentifier;

- (void)restoreCompletedTransactions;

@end
