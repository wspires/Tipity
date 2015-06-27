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

@interface MADeviceUtil : NSObject

+ (BOOL)iPad;

@end
