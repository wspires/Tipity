//
//  MAIAPHelper.m
//  Weight Log
//
//  Created by Wade Spires on 6/16/13.
//  Copyright (c) 2013 Wade Spires. All rights reserved.
//

#import "MAIAPHelper.h"

#import "MAUtil.h"

#import <StoreKit/StoreKit.h>

NSString * const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface MAIAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) NSSet *productIdentifiers;
@property (strong, nonatomic) NSMutableSet *purchasedProductIdentifiers;
@property (strong, nonatomic) SKProductsRequest * productsRequest;
@property (strong, nonatomic) RequestProductsCompletionHandler completionHandler;
@end

@implementation MAIAPHelper
@synthesize productIdentifiers = _productIdentifiers;
@synthesize purchasedProductIdentifiers = _purchasedProductIdentifiers;
@synthesize productsRequest = _productsRequest;
@synthesize completionHandler = _completionHandler;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        // Store product identifiers.
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products.
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased)
            {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                DLog(@"Previously purchased: %@", productIdentifier);
            }
            else
            {
                DLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    DLog(@"Loaded list of %d products...", response.products.count);
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    /*
    for (SKProduct * skProduct in skProducts)
    {
        DLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
     */
    
    if (_completionHandler)
    {
        _completionHandler(YES, skProducts);
    }
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    DLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    if (_completionHandler)
    {
        _completionHandler(NO, nil);
        _completionHandler = nil;
    }
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

#pragma mark - SKPaymentTransactionObserver

- (void)buyProduct:(SKProduct *)product
{
    if ( ! product)
    {
        return;
    }
    
    DLog(@"Buying %@", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    [self productPurchasedHandler:transaction.payment.productIdentifier];
}

- (void)productPurchasedHandler:(NSString *)productIdentifier
{
    // TODO: Override in derived class.
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"failedTransaction...");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        DLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
