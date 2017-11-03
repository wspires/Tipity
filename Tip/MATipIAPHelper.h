//
//  MATipIAPHelper.h
//  Gym Log
//
//  Created by Wade Spires on 7/3/13.
//
//

#import <Foundation/Foundation.h>

#import "MAIAPHelper.h"
#import "MAUtil.h"
#import "CustomIOS7AlertView.h"

// Flags to enable disable certain features as being part of an IAP.
static BOOL const No_Ads_Iap = YES;
static BOOL const Split_Tip_Iap = NO;
static BOOL const Tax_Iap = NO;
static BOOL const Service_Rating_Iap = YES;
static BOOL const Rounding_Iap = YES;
static BOOL const Fraud_Iap = YES;
static BOOL const Customize_Color_Iap = YES;

DECL_TABLE_IDX(PRO_PRODUCT_IDX, (NSUInteger)0);

// Keys for each feature in the list returned by iapList.
static NSString * const Feature_Title_Key = @"title";
static NSString * const Feature_Description_Key = @"description";
static NSString * const Feature_Image_Key = @"image";

@interface MATipIAPHelper : MAIAPHelper

@property (strong, nonatomic) NSMutableArray *products;

+ (MATipIAPHelper *)sharedInstance;

+ (NSString *)FreeToProProductId;

// Whether exactly this product level has been purchased.
+ (BOOL)ProProductPurchased;

// Whether up to this product level has been purchased, e.g., if Pro has been purchased, then both the Basic and Standard features are enabled, too.
+ (BOOL)UpToProProductPurchased;

- (void)loadProducts:(RequestProductsCompletionHandler)completionHandler;
+ (NSNumberFormatter *)priceFormatter;
- (NSString *)iapPrice;

+ (UIAlertView *)upgradeAlert;
+ (CustomIOS7AlertView *)customUpgradeAlert;
+ (NSString *)iapText;
+ (NSString *)iapListText;
+ (NSArray *)iapList;
+ (NSAttributedString *)iapDetailText;

// Checks for whether IAP has been purchased and possibly show a pop-up.
// Returns YES if IAP has NOT been purchased and a pop-up shown; returns NO if IAP has been purchased.
+ (BOOL)checkForIAP;
+ (BOOL)checkAndAlertForIAP;
+ (BOOL)checkAndAlertForIAPWithProductCount:(NSUInteger)productCount;
+ (void)disableLabelIfNotPurchased:(UILabel *)label;

@end
