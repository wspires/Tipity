//
//  MATipIAPHelper.m
//  Gym Log
//
//  Created by Wade Spires on 7/3/13.
//
//

#import "MATipIAPHelper.h"

#import "MAAppearance.h"
#import "MAFilePaths.h"

#import "CustomIOS7AlertView.h"
#import "MAUpgradeAlertViewController.h"

// Uncomment to unlock all IAP.
// Comment before deploying or else all IAP will be unlocked for free!
#define UNLOCK_ALL_IAP

static NSUInteger const ProductCountThreshold = 3;

@interface MATipIAPHelper ()
@property (strong, nonatomic) UIAlertView *upgradeAlertView;
@property (strong, nonatomic) UIAlertView *noNetworkAlertView;

- (void)productPurchasedHandler:(NSString *)productIdentifier;

@end

@implementation MATipIAPHelper
@synthesize products = _products;

+ (MATipIAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static MATipIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      [MATipIAPHelper FreeToProProductId],
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];

        // Automatically try to load the products when first created.
        [sharedInstance loadProducts:nil];
    });
    return sharedInstance;
}

- (void)productPurchasedHandler:(NSString *)productIdentifier
{
    if ([MATipIAPHelper UpToProProductPurchased])
    {
        // Insert logic here for when the product is purchased.
    }
}

+ (NSString *)FreeToProProductId
{
    return @"com.mindsaspire.Tip.FreeToPro";
}

+ (BOOL)FreeToProProductPurchased
{
#ifdef UNLOCK_ALL_IAP
    TLog(@"Test mode: All IAP unlocked");
    return YES;
#endif
    
    return [[MATipIAPHelper sharedInstance] productPurchased:[MATipIAPHelper FreeToProProductId]];
}

+ (BOOL)ProProductPurchased
{
    return [MATipIAPHelper FreeToProProductPurchased];
}

+ (BOOL)UpToProProductPurchased
{
    return [MATipIAPHelper ProProductPurchased];
}

- (void)loadProducts:(RequestProductsCompletionHandler)completionHandler
{
    [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
     {
         if (!success)
         {
             if (completionHandler)
             {
                 completionHandler(NO, nil);
             }
             return;
         }
         
         //self.products = products;
         
         //BOOL noProductsPurchased = ![MAWeightLogIAPHelper AnyProductPurchased];
         //if (noProductsPurchased)
         {
             // Note: not using products.count since more products might be setup in the store, but we are only interested in certain ones now.
             //NSUInteger const numProducts = 3;
             NSUInteger const numProducts = 1;
             self.products = [[NSMutableArray alloc] initWithCapacity:numProducts];
             //for (SKProduct *skProduct in products)
             for (NSUInteger i = 0; i != products.count; ++i)
             {
                 [self.products addObject:[NSNull null]];
             }
             
             for (SKProduct *skProduct in products)
             {
                 if ([skProduct.productIdentifier isEqualToString:[MATipIAPHelper FreeToProProductId]])
                 {
                     self.products[PRO_PRODUCT_IDX] = skProduct;
                 }
             }
         }
         /*
         else if ([MATipIAPHelper BasicProductPurchased])
         {
         }
         else if ([MATipIAPHelper StandardProductPurchased])
         {
         }
         else if ([MATipIAPHelper ProProductPurchased])
         {
         }
          */

         if (completionHandler)
         {
             completionHandler(YES, self.products);
         }
     }];
}

+ (NSNumberFormatter *)priceFormatter
{
    static dispatch_once_t once;
    static NSNumberFormatter * sharedInstance = nil;
    dispatch_once(&once, ^{
        sharedInstance = [[NSNumberFormatter alloc] init];
        [sharedInstance setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [sharedInstance setNumberStyle:NSNumberFormatterCurrencyStyle];
    });
    return sharedInstance;
}

- (NSString *)iapPrice
{
    NSString *price = nil;
    if (self.products && self.products.count > 0)
    {
        NSNumberFormatter *priceFormatter = [MATipIAPHelper priceFormatter];
        
        SKProduct *product = self.products[PRO_PRODUCT_IDX];
        if (product)
        {
            [priceFormatter setLocale:product.priceLocale];
            price = [priceFormatter stringFromNumber:product.price];
        }
    }
    return price;
}

+ (UIAlertView *)upgradeAlert
{
    static dispatch_once_t once;
    static UIAlertView * sharedInstance;
    dispatch_once(&once, ^{
        NSString *message = [MATipIAPHelper iapText];
        
        NSString *buttonTitle = Localize(@"Upgrade");
        NSString *price = [[MATipIAPHelper sharedInstance] iapPrice];
        if (price && price.length != 0)
        {
            buttonTitle = SFmt(@"%@ (%@)", buttonTitle, price);
        }
        
        sharedInstance = [[UIAlertView alloc]
                          initWithTitle:Localize(@"Upgrade Required")
                          message:message
                          delegate:[MATipIAPHelper sharedInstance]
                          cancelButtonTitle:Localize(@"Cancel")
                          otherButtonTitles:buttonTitle, nil];
    });
    return sharedInstance;
}

+ (MAUpgradeAlertViewController *)upgradeAlertViewController
{
    static dispatch_once_t once;
    static MAUpgradeAlertViewController * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[MAUpgradeAlertViewController alloc] initWithNibName:@"MAUpgradeAlertViewController" bundle:nil];
    });
    return sharedInstance;
}

+ (CustomIOS7AlertView *)customUpgradeAlert
{
    return [MATipIAPHelper customUpgradeAlert:YES];
}
+ (CustomIOS7AlertView *)customUpgradeAlert:(BOOL)upgradeRequired
{
    static dispatch_once_t once;
    static CustomIOS7AlertView * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[CustomIOS7AlertView alloc] init];
        
        NSString *buttonTitle = Localize(@"Upgrade");
        NSString *price = [[MATipIAPHelper sharedInstance] iapPrice];
        if (price && price.length != 0)
        {
            buttonTitle = SFmt(@"%@ (%@)", buttonTitle, price);
        }
        
        // Modify the parameters
        [sharedInstance setButtonTitles:[NSMutableArray arrayWithObjects:Localize(@"Cancel"), buttonTitle, nil]];
        
        //[alertView setDelegate:self];
        // You may use a completion rather than a delegate.
        [sharedInstance setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, NSInteger buttonIndex)
         {
             if (buttonIndex == 0)
             {
                 return;
             }
             
             [[MATipIAPHelper sharedInstance] buyProduct];
             
             //NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
             [alertView close];
         }];
        
        [sharedInstance setUseMotionEffects:true];
    });
    
    // Add custom content to the alert view.
    // Note: Must reset the frame each time it's called or else the alert view will not appear right and will be huge (I think it's because it gets internally resized for the different views it appears on, like the Settings tab versus custom exercise view).
    MAUpgradeAlertViewController *upgradeAlertViewController = [MATipIAPHelper upgradeAlertViewController];
    
    CGRect frame = CGRectMake(0, 0, 300, 440);
    upgradeAlertViewController.view.frame = frame;
    upgradeAlertViewController.view.layer.cornerRadius = kCustomIOS7AlertViewCornerRadius; // Round the view's corners; otherwise, it'll look weird and square.
    [sharedInstance setContainerView:upgradeAlertViewController.view];

    if (upgradeRequired)
    {
        upgradeAlertViewController.titleLabel.text = Localize(@"Upgrade Required");
        upgradeAlertViewController.descriptionLabel.text = Localize(@"Upgrade to unlock all features.");
    }
    else
    {
        upgradeAlertViewController.titleLabel.text = Localize(@"Upgrade Today");
        upgradeAlertViewController.descriptionLabel.text = Localize(SFmt(@"Make the most of your workout with these features."));
        upgradeAlertViewController.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    }

    return sharedInstance;
}

+ (NSString *)iapText
{
    static dispatch_once_t once;
    static NSString * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = SFmt(@"%@\n%@"
                              , Localize(@"Upgrade to unlock all features:")
                              , [MATipIAPHelper iapListText]
                              );
    });
    return sharedInstance;
}

// List of all features constructed as a single, formatted string.
+ (NSString *)iapListText
{
    static dispatch_once_t once;
    static NSString * sharedInstance;
    dispatch_once(&once, ^{
        NSArray *features = [MATipIAPHelper iapList];

        NSMutableString *featuresString = [[NSMutableString alloc] init];
        for (NSDictionary *feature in features)
        {
            NSString *title = [feature objectForKey:Feature_Title_Key];
            NSString *string = SFmt(@"• %@\n", title);
            [featuresString appendString:string];
        }
        
        sharedInstance = [MAUtil trimWhitespace:featuresString];
    });
    return sharedInstance;
}

// List of all features. Each feature is a dictionary with a key such as Feature_Title_Key found in the header file.
+ (NSArray *)iapList
{
    static dispatch_once_t once;
    static NSArray * sharedInstance;
    dispatch_once(&once, ^{
        NSMutableArray *features = [[NSMutableArray alloc] init];
        NSMutableDictionary *feature = nil;

        // Add each IAP that's enabled.
        if (No_Ads_Iap)
        {
            feature = [NSMutableDictionary dictionary];
            [feature setObject:Localize(@"No Ads") forKey:Feature_Title_Key];
            [feature setObject:Localize(@"No advertisements") forKey:Feature_Description_Key];
            [feature setObject:[MAFilePaths noAdImage] forKey:Feature_Image_Key];
            [features addObject:feature];
        }
        if (Split_Tip_Iap)
        {
            feature = [NSMutableDictionary dictionary];
            [feature setObject:Localize(@"Split Tip") forKey:Feature_Title_Key];
            [feature setObject:Localize(@"Split the tip among multiple people") forKey:Feature_Description_Key];
            [feature setObject:[MAFilePaths peopleImage] forKey:Feature_Image_Key];
            [features addObject:feature];
        }
        if (Tax_Iap)
        {
            feature = [NSMutableDictionary dictionary];
            [feature setObject:Localize(@"Exclude Tax") forKey:Feature_Title_Key];
            [feature setObject:Localize(@"Exclude taxes when calculating tip") forKey:Feature_Description_Key];
            [feature setObject:[MAFilePaths taxAmountImage] forKey:Feature_Image_Key];
            [features addObject:feature];
        }
        if (Service_Rating_Iap)
        {
            feature = [NSMutableDictionary dictionary];
            [feature setObject:Localize(@"Service Rating") forKey:Feature_Title_Key];
            [feature setObject:Localize(@"Customize the service rating buttons") forKey:Feature_Description_Key];
            [feature setObject:[MAFilePaths emptyStarImage] forKey:Feature_Image_Key];
            [features addObject:feature];
        }
        if (Customize_Color_Iap)
        {
            feature = [NSMutableDictionary dictionary];
            [feature setObject:Localize(@"Customize Color") forKey:Feature_Title_Key];
            [feature setObject:Localize(@"Change background and foreground colors, or set your own wallpaper") forKey:Feature_Description_Key];
            [feature setObject:[MAFilePaths appearanceImage] forKey:Feature_Image_Key];
            [features addObject:feature];
        }

        sharedInstance = features;
    });
    return sharedInstance;
}

+ (NSAttributedString *)iapDetailText
{
    static dispatch_once_t once;
    static NSMutableAttributedString * string;
    dispatch_once(&once, ^{
        // Create the attributed string
        string = [[NSMutableAttributedString alloc] initWithString:[MATipIAPHelper iapListText]];
        
        // Declare the fonts
        UIFont *stringFont1 = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        
        // Declare the paragraph styles
        NSMutableParagraphStyle *stringParaStyle1 = [[NSMutableParagraphStyle alloc]init];
        
        
        // Create the attributes and add them to the string
        [string addAttribute:NSLigatureAttributeName value:[NSNumber numberWithInteger:0] range:NSMakeRange(0, string.length)];
        [string addAttribute:NSParagraphStyleAttributeName value:stringParaStyle1 range:NSMakeRange(0, string.length)];
        [string addAttribute:NSFontAttributeName value:stringFont1 range:NSMakeRange(0, string.length)];
    });
    return string;

}

+ (BOOL)checkForIAP
{
    // Block free version unless paid for IAP.
    if ( ! [MATipIAPHelper UpToProProductPurchased])
    {
#ifndef MA_DEBUG_MODE
        return YES;
#endif
    }
    
    return NO;
}

+ (BOOL)checkAndAlertForIAP
{
    // Block free version unless paid for IAP.
    if ( ! [MATipIAPHelper UpToProProductPurchased])
    {
        // Always show the pop-up, but only return YES if NOT debugging.
        //UIAlertView *alert = [MATipIAPHelper upgradeAlert];
        CustomIOS7AlertView *alert = [MATipIAPHelper customUpgradeAlert];
        [alert show];
#ifndef MA_DEBUG_MODE
        return YES;
#endif
    }
    
    return NO;
}

+ (BOOL)checkAndAlertForIAPWithProductCount:(NSUInteger)productCount
{
    // Block free version unless paid for IAP.
    if ( ! [MATipIAPHelper UpToProProductPurchased])
    {
        // Always show the pop-up, but only return YES if NOT debugging.
        if (productCount >= ProductCountThreshold)
        {
            static BOOL const upgradeRequired = YES;
            CustomIOS7AlertView *alert = [MATipIAPHelper customUpgradeAlert:upgradeRequired];
            [alert show];
            
#ifndef MA_DEBUG_MODE
            return YES;
#endif
        }
    }
    
    return NO;
}

+ (void)disableLabelIfNotPurchased:(UILabel *)label
{
    if ([MATipIAPHelper checkForIAP])
    {
        // Disable if not purchased.
        label.enabled = NO;
    }
}

+ (UIAlertView *)noNetworkAlert
{
    static dispatch_once_t once;
    static UIAlertView * sharedInstance;
    dispatch_once(&once, ^{
        NSString *message = [[NSString alloc]initWithFormat:@"%@",
                             Localize(@"Connect to a Wifi or Cellular data network to upgrade.")];
        sharedInstance = [[UIAlertView alloc]
                          initWithTitle:Localize(@"Network Required")
                          message:message
                          delegate:nil
                          cancelButtonTitle:Localize(@"OK")
                          otherButtonTitles:nil];
        
    });
    return sharedInstance;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView != [MATipIAPHelper upgradeAlert])
    {
        return;
    }
    
    if (buttonIndex == 0)
    {
        return;
    }
    
    [self buyProduct];
}

- (void)buyProduct
{
    if (!self.products || self.products.count == 0)
    {
        UIAlertView *alert = [MATipIAPHelper noNetworkAlert];
        [alert show];
        return;
    }
    
    SKProduct *product = self.products[PRO_PRODUCT_IDX];
    
    DLog(@"Buying %@...", product.productIdentifier);
    [[MATipIAPHelper sharedInstance] buyProduct:product];
}

@end
