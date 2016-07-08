//
//  MADeviceUtil.h
//  Tip
//
//  Created by Wade Spires on 6/26/15.
//  Copyright © 2015 Minds Aspire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NSUInteger DeviceSystemMajorVersion();

#define BELOW_IOS7 (DeviceSystemMajorVersion() < 7)
#define ABOVE_IOS7 ( ! BELOW_IOS7)

#define BELOW_IOS8 (DeviceSystemMajorVersion() < 8)
#define ABOVE_IOS8 ( ! BELOW_IOS8)

#define BELOW_IOS9 (DeviceSystemMajorVersion() < 9)
#define ABOVE_IOS9 ( ! BELOW_IOS9)

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface MADeviceUtil : NSObject

+ (BOOL)iPad;

@end
